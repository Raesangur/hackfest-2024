#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <signal.h>
#include <stdbool.h>

// terminate shell
void terminate_shell(pid_t pid) {
    kill(pid, SIGKILL);
}

// hex to bytes
void hex_to_bytes(const char *hex, unsigned char *bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        sscanf(hex + 2 * i, "%2hhx", &bytes[i]);
    }
}

int validate_shellcode(const unsigned char *shellcode, size_t length) {

    // Check for /bin/
    for (size_t i = 0; i < length - 2; i++) {
        if (shellcode[i] == 0x2f && shellcode[i + 1] == 0x62 && shellcode[i + 2] == 0x69 && shellcode[i + 3] == 0x6e && shellcode[i + 4] == 0x2f) {
	    return 0;
        }
    }

    // thumb mode please...
    int found_add = 0, found_bx = 0;
    int bx_count = 0;

    for (size_t i = 0; i < length - 4; i++) {
        // Check for "add r1, pc, #1" (hex: 01 10 8f e2)
        if (shellcode[i] == 0x01 && shellcode[i + 1] == 0x10 && shellcode[i + 2] == 0x8f && shellcode[i + 3] == 0xe2) {
            // Ensure no null or "0b" bytes are in the shellcode
            bool hasBadBytes = false;

            for (size_t j = 0; j < length; j++) {
                if (shellcode[j] == 0x00 || shellcode[j] == 0x0b) {
                   hasBadBytes = true;
                   break;
                }
            }

            if (hasBadBytes) {
                return 0;  // Null or 0x0b byte found, exit
            }

            found_add = 1;  // No bad bytes found, set found_add
        }

        // Check for "bx r1" (hex: 11 ff 2f e1)
        if (shellcode[i] == 0x11 && shellcode[i + 1] == 0xff && shellcode[i + 2] == 0x2f && shellcode[i + 3] == 0xe1) {
            bx_count++;
	    found_bx = 1;
        }
    }
    
    if (found_add && found_bx && bx_count == 1 && length <= 128) {
        return 1;  // Valid shellcode
    }

    printf("Invalid shellcode!");
    return 0;  // Invalid shellcode
}


int main() {
    char hex_shellcode[113];
    printf("Enter the shellcode in hex format (eg. 001122334455...): ");
    if (fgets(hex_shellcode, sizeof(hex_shellcode), stdin) == NULL) {
        perror("fgets");
        return 1;
    }

    size_t input_len = strlen(hex_shellcode);
    if (hex_shellcode[input_len - 1] == '\n') {
        hex_shellcode[input_len - 1] = '\0';
    }

    size_t shellcode_len = strlen(hex_shellcode) / 2;

    unsigned char *shellcode = (unsigned char *)malloc(shellcode_len);
    if (shellcode == NULL) {
        perror("malloc");
        return 1;
    }

    hex_to_bytes(hex_shellcode, shellcode, shellcode_len);

    if (!validate_shellcode(shellcode, shellcode_len)) {
        free(shellcode);
        return 1;
    }

    void *exec = mmap(0, shellcode_len, PROT_READ | PROT_WRITE | PROT_EXEC, 
                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (exec == MAP_FAILED) {
        perror("mmap");
        free(shellcode);
        return 1;
    }

    memcpy(exec, shellcode, shellcode_len);
    
    ((void (*)())exec)();

    free(shellcode);
    return 0;
}
