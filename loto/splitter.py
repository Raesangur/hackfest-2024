import random

# Read the file with all the flags
with open('flags.txt', 'r') as file:
    data = file.read()

# Split the flags (each flag starts with 'HF-')
flags = data.split('HF-')
# Add back the 'HF-' prefix since it was removed by the split
flags = [f'HF-{flag}' for flag in flags if flag]  # Ignore empty strings

# Split the flags into groups of 50
group_size = 50
flag_groups = [flags[i:i + group_size] for i in range(0, len(flags), group_size)]

# Randomly select 6 groups
random_groups = random.sample(flag_groups, 6)

# Print or save the randomly selected groups
for i, group in enumerate(random_groups):
    print(f"Group {i+1}:")
    print("\n".join(group))
    print("\n" + "="*50 + "\n")
