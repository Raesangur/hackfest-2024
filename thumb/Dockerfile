FROM debian:latest AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-arm-linux-gnueabihf \
    qemu-user-static \
    socat \
    && apt-get clean

WORKDIR /app

COPY shellcode_exec.c /app/
COPY flag.txt /app/

RUN arm-linux-gnueabihf-gcc -o shellcode_exec shellcode_exec.c

FROM arm32v7/debian:latest

RUN apt-get update && apt-get install -y \
    qemu-user-static \
    socat \
    && apt-get clean

COPY --from=builder /app/shellcode_exec /shellcode_exec
COPY --from=builder /app/flag.txt /flag.txt

RUN chmod +x /shellcode_exec

EXPOSE 1337

CMD ["socat", "TCP-LISTEN:1337,reuseaddr,fork", "EXEC:/shellcode_exec,pty,stderr,setsid,sigint,sane"]
