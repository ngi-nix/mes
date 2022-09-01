    /nix/store/rn77jp3d27iqhyy944xqnr1dagbybvvm-m2-minimal --architecture amd64 \
      -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/sys/types.h -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/stddef.h -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/string.c -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/amd64/linux/unistd.c -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/stdlib.c -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/amd64/linux/fcntl.c -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/stdio.c -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/bootstrappable.c \
      -f ../mescc-tools/Kaem/kaem.h \
      -f ../mescc-tools/Kaem/variable.c \
      -f ../mescc-tools/Kaem/kaem_globals.c \
	    -f ../mescc-tools/Kaem/kaem.c \
      --debug \
      -o ./kaem.M1

    /nix/store/riqbvcnx66z7hd6jk339jcnw38sd2a6x-blood-elf-0 --64 -f ./kaem.M1 -o ./kaem_footer.M1

    /nix/store/04jvbv19visppgh3yg1qzwz6s6qs3qaj-m1-0 --architecture amd64 \
      --little-endian \
      -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/amd64/amd64_defs.M1 -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/amd64/libc-full.M1 \
      -f ./kaem.M1 \
      -f ./kaem_footer.M1 \
     	-o ./kaem.hex2

    /nix/store/2ch0w7gs78sky87x843j9l2pzaxg742j-hex2-1 --architecture amd64 \
      --little-endian \
      --base-address 0x00600000 \
      -f /nix/store/ind2yfndjd5sffx9ndcb55f6f73pmrlv-source/POSIX/M2libc/amd64/ELF-amd64-debug.hex2 \
      -f ./kaem.hex2 \
     	-o ./kaem
