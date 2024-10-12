import struct

def read_bin_file(filename):
    """Read the contents of a binary file."""
    with open(filename, 'rb') as f:
        return f.read()

def find_all_offsets(binary_data, encoded_value):
    """Find all offsets of the encoded value in the binary data."""
    offsets = []
    offset = 0
    
    while True:
        try:
            # Search for the next occurrence
            offset = binary_data.index(encoded_value, offset)
            offsets.append(offset)
            offset += 1  # Move to the next byte after the found match
        except ValueError:
            break  # No more occurrences
    
    return offsets

def encode_values(value):
    """Generate possible encodings for the 4-digit code."""
    value_str = f"{value:04d}"  # 4-digit code as a string
    
    # ASCII encoding
    ascii_encoding = value_str.encode('ascii')

    # BCD encoding (Binary Coded Decimal)
    bcd_encoding = bytes(int(value_str[i:i+2]) for i in range(0, 4, 2))

    # Little-endian and Big-endian encoding (16-bit integers)
    little_endian = struct.pack('<H', value)
    big_endian = struct.pack('>H', value)
    
    # Return all encoding variations
    return [ascii_encoding, bcd_encoding, little_endian, big_endian]

def find_code_offsets(files, values):
    """Find offsets of the encoded values in each binary file."""
    offsets = {}
    
    for i, (file, value) in enumerate(zip(files, values)):
        binary_data = read_bin_file(file)
        encodings = encode_values(value)
        
        file_offsets = []
        for encoding in encodings:
            matches = find_all_offsets(binary_data, encoding)
            if matches:
                file_offsets.append((encoding, matches))
                print(f"File: {file}, Code: {value}, Encoding: {encoding}, Offsets: {matches}")
        
        if file_offsets:
            offsets[file] = (value, file_offsets)
        else:
            print(f"Code {value} not found in {file}")
    
    return offsets

def find_common_overlap(offsets):
    """Find the common overlap of the offsets."""
    # Collect all offsets across all files
    all_offsets = [offset[1] for file_data in offsets.values() for encoding_data in file_data[1] for offset in encoding_data[1]]
    
    # Flatten all offsets into a single list
    all_offsets = sorted(itertools.chain(*all_offsets))
    
    # Check for common overlaps
    if len(set(all_offsets)) == 1:
        print(f"Common offset found at {all_offsets[0]}")
    else:
        print(f"No common overlap found, all offsets: {all_offsets}")

if __name__ == "__main__":
    # List of 16kB binary files
    files = ['1234.bin', '4321.bin', '4564.bin', '7890.bin', '8765.bin']

    # Known 4-digit plaintext codes for each file
    values = [1234, 4321, 4564, 7890, 8765]  # Replace these with actual codes

    # Find the offsets of the codes in the files
    offsets = find_code_offsets(files, values)

    # Find common overlap in the offsets
    if offsets:
        find_common_overlap(offsets)
