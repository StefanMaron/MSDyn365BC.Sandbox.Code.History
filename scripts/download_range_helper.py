#!/usr/bin/env python3
"""Download and extract specific folders from a ZIP archive using HTTP Range requests.

Usage: download_range_helper.py <artifact_url> <total_size> <target_folder_prefix> <output_dir>

Downloads only the portion of a ZIP file containing entries matching the target
folder prefix, then extracts .zip and .app files from it. This avoids downloading
the entire artifact (1GB+) when only a small portion is needed.

Exits 0 on success, 1 on any failure (triggering fallback to full download).
"""

import struct
import sys
import os
import subprocess
import zlib
import tempfile


def download(url, output_path, byte_range=None):
    """Download a URL (or byte range) to a file. Returns True on success."""
    cmd = ['curl', '-s', '-f', '-o', output_path]
    if byte_range:
        cmd.extend(['-r', byte_range])
    cmd.append(url)
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        print(f"ERROR: curl failed (exit {result.returncode}): {result.stderr.decode()}")
        return False
    return True


def parse_central_directory(data, cd_start, entry_count):
    """Parse ZIP central directory entries. Returns list of entry dicts."""
    entries = []
    pos = cd_start
    for _ in range(entry_count):
        if pos + 46 > len(data):
            print("WARNING: Truncated central directory")
            break
        if data[pos:pos+4] != b'\x50\x4b\x01\x02':
            print(f"WARNING: Invalid CD entry signature at pos {pos}")
            break

        comp_method = struct.unpack_from('<H', data, pos + 10)[0]
        comp_size = struct.unpack_from('<I', data, pos + 20)[0]
        uncomp_size = struct.unpack_from('<I', data, pos + 24)[0]
        name_len = struct.unpack_from('<H', data, pos + 28)[0]
        extra_len = struct.unpack_from('<H', data, pos + 30)[0]
        comment_len = struct.unpack_from('<H', data, pos + 32)[0]
        local_offset = struct.unpack_from('<I', data, pos + 42)[0]
        name = data[pos+46:pos+46+name_len].decode('utf-8', errors='replace')

        entries.append({
            'name': name,
            'comp_method': comp_method,
            'comp_size': comp_size,
            'uncomp_size': uncomp_size,
            'offset': local_offset,
        })
        pos += 46 + name_len + extra_len + comment_len

    return entries


def main():
    if len(sys.argv) != 5:
        print("Usage: download_range_helper.py <artifact_url> <total_size> <target_folder_prefix> <output_dir>")
        sys.exit(1)

    url = sys.argv[1]
    total_size = int(sys.argv[2])
    target_prefix = sys.argv[3]
    output_dir = sys.argv[4]

    if not target_prefix.endswith('/'):
        target_prefix += '/'

    os.makedirs(output_dir, exist_ok=True)
    tmp_dir = tempfile.mkdtemp(prefix='range-dl-')

    try:
        # Step 1: Download last 64KB to read ZIP central directory
        tail_size = 65536
        tail_start = total_size - tail_size
        tail_file = os.path.join(tmp_dir, 'tail.bin')

        if not download(url, tail_file, f'{tail_start}-{total_size - 1}'):
            print("ERROR: Failed to download ZIP tail")
            sys.exit(1)

        with open(tail_file, 'rb') as f:
            tail = f.read()

        # Find EOCD signature scanning backwards
        eocd_pos = tail.rfind(b'\x50\x4b\x05\x06')
        if eocd_pos == -1:
            print("ERROR: Could not find EOCD signature")
            sys.exit(1)

        entry_count = struct.unpack_from('<H', tail, eocd_pos + 10)[0]
        cd_size = struct.unpack_from('<I', tail, eocd_pos + 12)[0]
        cd_offset = struct.unpack_from('<I', tail, eocd_pos + 16)[0]
        print(f"Central directory: {entry_count} entries, {cd_size // 1024} KB at offset {cd_offset}")

        # Step 2: Ensure we have the full central directory
        cd_start_in_tail = len(tail) - (total_size - cd_offset)
        if cd_start_in_tail < 0:
            print(f"Central directory not in tail, downloading from offset {cd_offset}")
            cd_file = os.path.join(tmp_dir, 'cd.bin')
            if not download(url, cd_file, f'{cd_offset}-{total_size - 1}'):
                print("ERROR: Failed to download central directory")
                sys.exit(1)
            with open(cd_file, 'rb') as f:
                tail = f.read()
            cd_start_in_tail = 0

        entries = parse_central_directory(tail, cd_start_in_tail, entry_count)
        print(f"Parsed {len(entries)} entries")

        # Step 3: Filter entries matching target prefix (non-empty files only)
        matching = [e for e in entries if e['name'].startswith(target_prefix) and e['comp_size'] > 0]
        print(f"Matching '{target_prefix}': {len(matching)} files")

        if not matching:
            prefixes = sorted(set(e['name'].split('/')[0] for e in entries if '/' in e['name']))
            print(f"Available folders: {prefixes}")
            print("ERROR: No matching entries found")
            sys.exit(1)

        # Step 4: Calculate byte range
        first_offset = min(e['offset'] for e in matching)
        max_matching_offset = max(e['offset'] for e in matching)

        # Include all entries in the range (non-matching may be interleaved)
        all_in_range = sorted(
            [e for e in entries if first_offset <= e['offset'] <= max_matching_offset],
            key=lambda e: e['offset']
        )

        range_end = 0
        for e in all_in_range:
            # local header (30) + name + extra (256 safety margin) + compressed data
            entry_end = e['offset'] + 30 + len(e['name'].encode('utf-8')) + 256 + e['comp_size']
            range_end = max(range_end, entry_end)

        download_size = range_end - first_offset

        # Safety check: if range exceeds 50% of total, fall back
        if download_size > total_size * 0.5:
            print(f"ERROR: Range ({download_size // 1048576} MB) exceeds 50% of total ({total_size // 1048576} MB)")
            sys.exit(1)

        savings = round((1 - download_size / total_size) * 100)
        print(f"Downloading range: {first_offset}-{range_end} ({download_size // 1048576} MB, {savings}% savings)")

        # Step 5: Download the range
        range_file = os.path.join(tmp_dir, 'range.bin')
        if not download(url, range_file, f'{first_offset}-{range_end}'):
            print("ERROR: Failed to download range")
            sys.exit(1)

        with open(range_file, 'rb') as f:
            data = f.read()

        print(f"Downloaded {len(data)} bytes")

        # Step 6: Extract matching .zip and .app files
        extracted = 0
        for entry in matching:
            name = entry['name']
            basename = os.path.basename(name)

            if not (basename.endswith('.zip') or basename.endswith('.app')):
                continue

            pos = entry['offset'] - first_offset
            if pos < 0 or pos + 30 > len(data):
                print(f"  WARNING: {basename} outside range, skipping")
                continue

            # Verify local file header signature
            if data[pos:pos+4] != b'\x50\x4b\x03\x04':
                print(f"  WARNING: Invalid local header for {basename}, skipping")
                continue

            name_len = struct.unpack_from('<H', data, pos + 26)[0]
            extra_len = struct.unpack_from('<H', data, pos + 28)[0]
            comp_method = struct.unpack_from('<H', data, pos + 8)[0]
            data_start = pos + 30 + name_len + extra_len

            if data_start + entry['comp_size'] > len(data):
                print(f"  WARNING: {basename} extends beyond range, skipping")
                continue

            comp_data = data[data_start:data_start + entry['comp_size']]

            if comp_method == 0:  # stored
                file_data = comp_data
            elif comp_method == 8:  # deflated
                try:
                    file_data = zlib.decompress(comp_data, -15)
                except zlib.error as e:
                    print(f"  WARNING: Decompression failed for {basename}: {e}")
                    continue
            else:
                print(f"  WARNING: Unknown compression {comp_method} for {basename}, skipping")
                continue

            out_path = os.path.join(output_dir, basename)
            with open(out_path, 'wb') as f:
                f.write(file_data)

            extracted += 1
            print(f"  Extracted: {basename} ({len(file_data) / 1048576:.1f} MB)")

        print(f"Extracted {extracted} files to {output_dir}")

        if extracted == 0:
            print("ERROR: No files were extracted")
            sys.exit(1)

    finally:
        # Clean up temp files
        import shutil
        shutil.rmtree(tmp_dir, ignore_errors=True)


if __name__ == '__main__':
    main()
