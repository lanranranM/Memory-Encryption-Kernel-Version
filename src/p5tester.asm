
_p5tester:     file format elf32-i386


Disassembly of section .text:

00000000 <err>:
#include "ptentry.h"
#define PGSIZE 4096


static int 
err(char *msg, ...) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    printf(1, "XV6_TEST_OUTPUT %s\n", msg);
   a:	83 ec 04             	sub    $0x4,%esp
   d:	ff 75 08             	pushl  0x8(%ebp)
  10:	68 9c 0d 00 00       	push   $0xd9c
  15:	6a 01                	push   $0x1
  17:	e8 b7 09 00 00       	call   9d3 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 1b 08 00 00       	call   83f <exit>

00000024 <main>:
}

int 
main(void){
  24:	f3 0f 1e fb          	endbr32 
  28:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  2c:	83 e4 f0             	and    $0xfffffff0,%esp
  2f:	ff 71 fc             	pushl  -0x4(%ecx)
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	57                   	push   %edi
  36:	56                   	push   %esi
  37:	53                   	push   %ebx
  38:	51                   	push   %ecx
  39:	83 ec 68             	sub    $0x68,%esp
    const uint PAGES_NUM = 4096;
  3c:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
  43:	83 ec 0c             	sub    $0xc,%esp
  46:	68 00 10 00 00       	push   $0x1000
  4b:	e8 77 08 00 00       	call   8c7 <sbrk>
  50:	83 c4 10             	add    $0x10,%esp
  53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while ((uint)buffer != 0x6000)
  56:	eb 13                	jmp    6b <main+0x47>
        buffer = sbrk(PGSIZE * sizeof(char));
  58:	83 ec 0c             	sub    $0xc,%esp
  5b:	68 00 10 00 00       	push   $0x1000
  60:	e8 62 08 00 00       	call   8c7 <sbrk>
  65:	83 c4 10             	add    $0x10,%esp
  68:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while ((uint)buffer != 0x6000)
  6b:	81 7d d4 00 60 00 00 	cmpl   $0x6000,-0x2c(%ebp)
  72:	75 e4                	jne    58 <main+0x34>
    // Allocate NUM pages of space
    char *ptr = sbrk(PAGES_NUM * PGSIZE);
  74:	8b 45 b0             	mov    -0x50(%ebp),%eax
  77:	c1 e0 0c             	shl    $0xc,%eax
  7a:	83 ec 0c             	sub    $0xc,%esp
  7d:	50                   	push   %eax
  7e:	e8 44 08 00 00       	call   8c7 <sbrk>
  83:	83 c4 10             	add    $0x10,%esp
  86:	89 45 ac             	mov    %eax,-0x54(%ebp)
    const int entries_num = 128;
  89:	c7 45 a8 80 00 00 00 	movl   $0x80,-0x58(%ebp)
    struct pt_entry pt_entries[entries_num];
  90:	8b 45 a8             	mov    -0x58(%ebp),%eax
  93:	83 e8 01             	sub    $0x1,%eax
  96:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  99:	8b 45 a8             	mov    -0x58(%ebp),%eax
  9c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  a3:	b8 10 00 00 00       	mov    $0x10,%eax
  a8:	83 e8 01             	sub    $0x1,%eax
  ab:	01 d0                	add    %edx,%eax
  ad:	bb 10 00 00 00       	mov    $0x10,%ebx
  b2:	ba 00 00 00 00       	mov    $0x0,%edx
  b7:	f7 f3                	div    %ebx
  b9:	6b c0 10             	imul   $0x10,%eax,%eax
  bc:	89 c2                	mov    %eax,%edx
  be:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  c4:	89 e1                	mov    %esp,%ecx
  c6:	29 d1                	sub    %edx,%ecx
  c8:	89 ca                	mov    %ecx,%edx
  ca:	39 d4                	cmp    %edx,%esp
  cc:	74 10                	je     de <main+0xba>
  ce:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  d4:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  db:	00 
  dc:	eb ec                	jmp    ca <main+0xa6>
  de:	89 c2                	mov    %eax,%edx
  e0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  e6:	29 d4                	sub    %edx,%esp
  e8:	89 c2                	mov    %eax,%edx
  ea:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  f0:	85 d2                	test   %edx,%edx
  f2:	74 0d                	je     101 <main+0xdd>
  f4:	25 ff 0f 00 00       	and    $0xfff,%eax
  f9:	83 e8 04             	sub    $0x4,%eax
  fc:	01 e0                	add    %esp,%eax
  fe:	83 08 00             	orl    $0x0,(%eax)
 101:	89 e0                	mov    %esp,%eax
 103:	83 c0 03             	add    $0x3,%eax
 106:	c1 e8 02             	shr    $0x2,%eax
 109:	c1 e0 02             	shl    $0x2,%eax
 10c:	89 45 a0             	mov    %eax,-0x60(%ebp)
    // Initialize the pages
    for (int i = 0; i < PAGES_NUM * PGSIZE; i++)
 10f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 116:	eb 0f                	jmp    127 <main+0x103>
        ptr[i] = 0xAA;
 118:	8b 55 d8             	mov    -0x28(%ebp),%edx
 11b:	8b 45 ac             	mov    -0x54(%ebp),%eax
 11e:	01 d0                	add    %edx,%eax
 120:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int i = 0; i < PAGES_NUM * PGSIZE; i++)
 123:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 127:	8b 45 b0             	mov    -0x50(%ebp),%eax
 12a:	c1 e0 0c             	shl    $0xc,%eax
 12d:	89 c2                	mov    %eax,%edx
 12f:	8b 45 d8             	mov    -0x28(%ebp),%eax
 132:	39 c2                	cmp    %eax,%edx
 134:	77 e2                	ja     118 <main+0xf4>
    
    if (mencrypt(ptr, PAGES_NUM) != 0)
 136:	8b 45 b0             	mov    -0x50(%ebp),%eax
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	50                   	push   %eax
 13d:	ff 75 ac             	pushl  -0x54(%ebp)
 140:	e8 9a 07 00 00       	call   8df <mencrypt>
 145:	83 c4 10             	add    $0x10,%esp
 148:	85 c0                	test   %eax,%eax
 14a:	74 10                	je     15c <main+0x138>
        err("mencrypt return non-zero value when mencrypt is called on valid range\n");
 14c:	83 ec 0c             	sub    $0xc,%esp
 14f:	68 b0 0d 00 00       	push   $0xdb0
 154:	e8 a7 fe ff ff       	call   0 <err>
 159:	83 c4 10             	add    $0x10,%esp

    int retval = getpgtable(pt_entries, entries_num);
 15c:	83 ec 08             	sub    $0x8,%esp
 15f:	ff 75 a8             	pushl  -0x58(%ebp)
 162:	ff 75 a0             	pushl  -0x60(%ebp)
 165:	e8 7d 07 00 00       	call   8e7 <getpgtable>
 16a:	83 c4 10             	add    $0x10,%esp
 16d:	89 45 9c             	mov    %eax,-0x64(%ebp)
    if (retval == entries_num) {
 170:	8b 45 9c             	mov    -0x64(%ebp),%eax
 173:	3b 45 a8             	cmp    -0x58(%ebp),%eax
 176:	0f 85 e8 01 00 00    	jne    364 <main+0x340>
        for (int i = 0; i < entries_num; i++) {
 17c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 183:	e9 ce 01 00 00       	jmp    356 <main+0x332>
                i,
                pt_entries[i].pdx,
                pt_entries[i].ptx,
                pt_entries[i].present,
                pt_entries[i].writable,
                pt_entries[i].encrypted
 188:	8b 45 a0             	mov    -0x60(%ebp),%eax
 18b:	8b 55 dc             	mov    -0x24(%ebp),%edx
 18e:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 193:	c0 e8 06             	shr    $0x6,%al
 196:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n",  
 199:	0f b6 f0             	movzbl %al,%esi
                pt_entries[i].writable,
 19c:	8b 45 a0             	mov    -0x60(%ebp),%eax
 19f:	8b 55 dc             	mov    -0x24(%ebp),%edx
 1a2:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 1a7:	c0 e8 05             	shr    $0x5,%al
 1aa:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n",  
 1ad:	0f b6 d8             	movzbl %al,%ebx
                pt_entries[i].present,
 1b0:	8b 45 a0             	mov    -0x60(%ebp),%eax
 1b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
 1b6:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 1bb:	c0 e8 04             	shr    $0x4,%al
 1be:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n",  
 1c1:	0f b6 c8             	movzbl %al,%ecx
                pt_entries[i].ptx,
 1c4:	8b 45 a0             	mov    -0x60(%ebp),%eax
 1c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
 1ca:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 1cd:	c1 e8 0a             	shr    $0xa,%eax
 1d0:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n",  
 1d4:	0f b7 d0             	movzwl %ax,%edx
                pt_entries[i].pdx,
 1d7:	8b 45 a0             	mov    -0x60(%ebp),%eax
 1da:	8b 7d dc             	mov    -0x24(%ebp),%edi
 1dd:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 1e1:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n",  
 1e5:	0f b7 c0             	movzwl %ax,%eax
 1e8:	56                   	push   %esi
 1e9:	53                   	push   %ebx
 1ea:	51                   	push   %ecx
 1eb:	52                   	push   %edx
 1ec:	50                   	push   %eax
 1ed:	ff 75 dc             	pushl  -0x24(%ebp)
 1f0:	68 f8 0d 00 00       	push   $0xdf8
 1f5:	6a 01                	push   $0x1
 1f7:	e8 d7 07 00 00       	call   9d3 <printf>
 1fc:	83 c4 20             	add    $0x20,%esp
            );

            if (dump_rawphymem((uint)(pt_entries[i].ppage * PGSIZE), buffer) != 0)
 1ff:	8b 45 a0             	mov    -0x60(%ebp),%eax
 202:	8b 55 dc             	mov    -0x24(%ebp),%edx
 205:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 209:	25 ff ff 0f 00       	and    $0xfffff,%eax
 20e:	c1 e0 0c             	shl    $0xc,%eax
 211:	83 ec 08             	sub    $0x8,%esp
 214:	ff 75 d4             	pushl  -0x2c(%ebp)
 217:	50                   	push   %eax
 218:	e8 d2 06 00 00       	call   8ef <dump_rawphymem>
 21d:	83 c4 10             	add    $0x10,%esp
 220:	85 c0                	test   %eax,%eax
 222:	74 10                	je     234 <main+0x210>
                err("dump_rawphymem return non-zero value\n");
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	68 54 0e 00 00       	push   $0xe54
 22c:	e8 cf fd ff ff       	call   0 <err>
 231:	83 c4 10             	add    $0x10,%esp
            
            uint expected = ~0xAA;
 234:	c7 45 98 55 ff ff ff 	movl   $0xffffff55,-0x68(%ebp)
            uint is_failed = 0;
 23b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            for (int j = 0; j < PGSIZE; j ++) {
 242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 249:	eb 1f                	jmp    26a <main+0x246>
                if (buffer[j] != (char)expected) {
 24b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 24e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 251:	01 d0                	add    %edx,%eax
 253:	0f b6 00             	movzbl (%eax),%eax
 256:	8b 55 98             	mov    -0x68(%ebp),%edx
 259:	38 d0                	cmp    %dl,%al
 25b:	74 09                	je     266 <main+0x242>
                    is_failed = 1;
 25d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
                    break;
 264:	eb 0d                	jmp    273 <main+0x24f>
            for (int j = 0; j < PGSIZE; j ++) {
 266:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 26a:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 271:	7e d8                	jle    24b <main+0x227>
                }
            }
            if (is_failed) {
 273:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 277:	0f 84 d5 00 00 00    	je     352 <main+0x32e>
                printf(1, "XV6_TEST_OUTPUT wrong content at physical page 0x%x\n", pt_entries[i].ppage * PGSIZE);
 27d:	8b 45 a0             	mov    -0x60(%ebp),%eax
 280:	8b 55 dc             	mov    -0x24(%ebp),%edx
 283:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 287:	25 ff ff 0f 00       	and    $0xfffff,%eax
 28c:	c1 e0 0c             	shl    $0xc,%eax
 28f:	83 ec 04             	sub    $0x4,%esp
 292:	50                   	push   %eax
 293:	68 7c 0e 00 00       	push   $0xe7c
 298:	6a 01                	push   $0x1
 29a:	e8 34 07 00 00       	call   9d3 <printf>
 29f:	83 c4 10             	add    $0x10,%esp
                for (int j = 0; j < PGSIZE; j +=64) {
 2a2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 2a9:	e9 87 00 00 00       	jmp    335 <main+0x311>
                    printf(1, "XV6_TEST_OUTPUT ");
 2ae:	83 ec 08             	sub    $0x8,%esp
 2b1:	68 b1 0e 00 00       	push   $0xeb1
 2b6:	6a 01                	push   $0x1
 2b8:	e8 16 07 00 00       	call   9d3 <printf>
 2bd:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 2c0:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 2c7:	eb 62                	jmp    32b <main+0x307>
                        if (k < 63) {
 2c9:	83 7d cc 3e          	cmpl   $0x3e,-0x34(%ebp)
 2cd:	7f 2d                	jg     2fc <main+0x2d8>
                            printf(1, "0x%x ", (uint)buffer[j + k] & 0xFF);
 2cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
 2d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
 2d5:	01 d0                	add    %edx,%eax
 2d7:	89 c2                	mov    %eax,%edx
 2d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2dc:	01 d0                	add    %edx,%eax
 2de:	0f b6 00             	movzbl (%eax),%eax
 2e1:	0f be c0             	movsbl %al,%eax
 2e4:	0f b6 c0             	movzbl %al,%eax
 2e7:	83 ec 04             	sub    $0x4,%esp
 2ea:	50                   	push   %eax
 2eb:	68 c2 0e 00 00       	push   $0xec2
 2f0:	6a 01                	push   $0x1
 2f2:	e8 dc 06 00 00       	call   9d3 <printf>
 2f7:	83 c4 10             	add    $0x10,%esp
 2fa:	eb 2b                	jmp    327 <main+0x303>
                        } else {
                            printf(1, "0x%x\n", (uint)buffer[j + k] & 0xFF);
 2fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
 2ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
 302:	01 d0                	add    %edx,%eax
 304:	89 c2                	mov    %eax,%edx
 306:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 309:	01 d0                	add    %edx,%eax
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	0f b6 c0             	movzbl %al,%eax
 314:	83 ec 04             	sub    $0x4,%esp
 317:	50                   	push   %eax
 318:	68 c8 0e 00 00       	push   $0xec8
 31d:	6a 01                	push   $0x1
 31f:	e8 af 06 00 00       	call   9d3 <printf>
 324:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 327:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 32b:	83 7d cc 3f          	cmpl   $0x3f,-0x34(%ebp)
 32f:	7e 98                	jle    2c9 <main+0x2a5>
                for (int j = 0; j < PGSIZE; j +=64) {
 331:	83 45 d0 40          	addl   $0x40,-0x30(%ebp)
 335:	81 7d d0 ff 0f 00 00 	cmpl   $0xfff,-0x30(%ebp)
 33c:	0f 8e 6c ff ff ff    	jle    2ae <main+0x28a>
                        }
                    }
                }
                err("physical memory is encrypted incorrectly\n");
 342:	83 ec 0c             	sub    $0xc,%esp
 345:	68 d0 0e 00 00       	push   $0xed0
 34a:	e8 b1 fc ff ff       	call   0 <err>
 34f:	83 c4 10             	add    $0x10,%esp
        for (int i = 0; i < entries_num; i++) {
 352:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 356:	8b 45 dc             	mov    -0x24(%ebp),%eax
 359:	3b 45 a8             	cmp    -0x58(%ebp),%eax
 35c:	0f 8c 26 fe ff ff    	jl     188 <main+0x164>
 362:	eb 15                	jmp    379 <main+0x355>
            }
        }
    }
    else {
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", entries_num, retval);
 364:	ff 75 9c             	pushl  -0x64(%ebp)
 367:	ff 75 a8             	pushl  -0x58(%ebp)
 36a:	68 fc 0e 00 00       	push   $0xefc
 36f:	6a 01                	push   $0x1
 371:	e8 5d 06 00 00       	call   9d3 <printf>
 376:	83 c4 10             	add    $0x10,%esp
    }

    for (int i = 0; i < PAGES_NUM; i++) {
 379:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 380:	eb 18                	jmp    39a <main+0x376>
        ptr[(i + 1) * PGSIZE - 1] = 0xAA;
 382:	8b 45 c8             	mov    -0x38(%ebp),%eax
 385:	83 c0 01             	add    $0x1,%eax
 388:	c1 e0 0c             	shl    $0xc,%eax
 38b:	8d 50 ff             	lea    -0x1(%eax),%edx
 38e:	8b 45 ac             	mov    -0x54(%ebp),%eax
 391:	01 d0                	add    %edx,%eax
 393:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int i = 0; i < PAGES_NUM; i++) {
 396:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
 39a:	8b 45 c8             	mov    -0x38(%ebp),%eax
 39d:	39 45 b0             	cmp    %eax,-0x50(%ebp)
 3a0:	77 e0                	ja     382 <main+0x35e>
    }

    retval = getpgtable(pt_entries, entries_num);
 3a2:	83 ec 08             	sub    $0x8,%esp
 3a5:	ff 75 a8             	pushl  -0x58(%ebp)
 3a8:	ff 75 a0             	pushl  -0x60(%ebp)
 3ab:	e8 37 05 00 00       	call   8e7 <getpgtable>
 3b0:	83 c4 10             	add    $0x10,%esp
 3b3:	89 45 9c             	mov    %eax,-0x64(%ebp)
    if (retval == entries_num) {
 3b6:	8b 45 9c             	mov    -0x64(%ebp),%eax
 3b9:	3b 45 a8             	cmp    -0x58(%ebp),%eax
 3bc:	0f 85 e8 01 00 00    	jne    5aa <main+0x586>
        for (int i = 0; i < entries_num; i++) {
 3c2:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 3c9:	e9 ce 01 00 00       	jmp    59c <main+0x578>
                pt_entries[i].pdx,
                pt_entries[i].ptx,
                //pt_entries[i].ppage,
                pt_entries[i].present,
                pt_entries[i].writable,
                pt_entries[i].encrypted
 3ce:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3d1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 3d4:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 3d9:	c0 e8 06             	shr    $0x6,%al
 3dc:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 3df:	0f b6 f0             	movzbl %al,%esi
                pt_entries[i].writable,
 3e2:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3e5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 3e8:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 3ed:	c0 e8 05             	shr    $0x5,%al
 3f0:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 3f3:	0f b6 d8             	movzbl %al,%ebx
                pt_entries[i].present,
 3f6:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3f9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 3fc:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 401:	c0 e8 04             	shr    $0x4,%al
 404:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 407:	0f b6 c8             	movzbl %al,%ecx
                pt_entries[i].ptx,
 40a:	8b 45 a0             	mov    -0x60(%ebp),%eax
 40d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 410:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 413:	c1 e8 0a             	shr    $0xa,%eax
 416:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 41a:	0f b7 d0             	movzwl %ax,%edx
                pt_entries[i].pdx,
 41d:	8b 45 a0             	mov    -0x60(%ebp),%eax
 420:	8b 7d c4             	mov    -0x3c(%ebp),%edi
 423:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 427:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, present: %d, writable: %d, encrypted: %d\n", 
 42b:	0f b7 c0             	movzwl %ax,%eax
 42e:	56                   	push   %esi
 42f:	53                   	push   %ebx
 430:	51                   	push   %ecx
 431:	52                   	push   %edx
 432:	50                   	push   %eax
 433:	ff 75 c4             	pushl  -0x3c(%ebp)
 436:	68 f8 0d 00 00       	push   $0xdf8
 43b:	6a 01                	push   $0x1
 43d:	e8 91 05 00 00       	call   9d3 <printf>
 442:	83 c4 20             	add    $0x20,%esp
            );

            if (dump_rawphymem((uint)(pt_entries[i].ppage * PGSIZE), buffer) != 0)
 445:	8b 45 a0             	mov    -0x60(%ebp),%eax
 448:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 44b:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 44f:	25 ff ff 0f 00       	and    $0xfffff,%eax
 454:	c1 e0 0c             	shl    $0xc,%eax
 457:	83 ec 08             	sub    $0x8,%esp
 45a:	ff 75 d4             	pushl  -0x2c(%ebp)
 45d:	50                   	push   %eax
 45e:	e8 8c 04 00 00       	call   8ef <dump_rawphymem>
 463:	83 c4 10             	add    $0x10,%esp
 466:	85 c0                	test   %eax,%eax
 468:	74 10                	je     47a <main+0x456>
                err("dump_rawphymem return non-zero value\n");
 46a:	83 ec 0c             	sub    $0xc,%esp
 46d:	68 54 0e 00 00       	push   $0xe54
 472:	e8 89 fb ff ff       	call   0 <err>
 477:	83 c4 10             	add    $0x10,%esp
            
            uint expected = 0xAA;
 47a:	c7 45 94 aa 00 00 00 	movl   $0xaa,-0x6c(%ebp)
            uint is_failed = 0;
 481:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
            for (int j = 0; j < PGSIZE; j ++) {
 488:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
 48f:	eb 1f                	jmp    4b0 <main+0x48c>
                if (buffer[j] != (char)expected) {
 491:	8b 55 bc             	mov    -0x44(%ebp),%edx
 494:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 497:	01 d0                	add    %edx,%eax
 499:	0f b6 00             	movzbl (%eax),%eax
 49c:	8b 55 94             	mov    -0x6c(%ebp),%edx
 49f:	38 d0                	cmp    %dl,%al
 4a1:	74 09                	je     4ac <main+0x488>
                    is_failed = 1;
 4a3:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
                    break;
 4aa:	eb 0d                	jmp    4b9 <main+0x495>
            for (int j = 0; j < PGSIZE; j ++) {
 4ac:	83 45 bc 01          	addl   $0x1,-0x44(%ebp)
 4b0:	81 7d bc ff 0f 00 00 	cmpl   $0xfff,-0x44(%ebp)
 4b7:	7e d8                	jle    491 <main+0x46d>
                }
            }
            if (is_failed) {
 4b9:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
 4bd:	0f 84 d5 00 00 00    	je     598 <main+0x574>
                printf(1, "XV6_TEST_OUTPUT wrong content at physical page 0x%x\n", pt_entries[i].ppage * PGSIZE);
 4c3:	8b 45 a0             	mov    -0x60(%ebp),%eax
 4c6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 4c9:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 4cd:	25 ff ff 0f 00       	and    $0xfffff,%eax
 4d2:	c1 e0 0c             	shl    $0xc,%eax
 4d5:	83 ec 04             	sub    $0x4,%esp
 4d8:	50                   	push   %eax
 4d9:	68 7c 0e 00 00       	push   $0xe7c
 4de:	6a 01                	push   $0x1
 4e0:	e8 ee 04 00 00       	call   9d3 <printf>
 4e5:	83 c4 10             	add    $0x10,%esp
                for (int j = 0; j < PGSIZE; j +=64) {
 4e8:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
 4ef:	e9 87 00 00 00       	jmp    57b <main+0x557>
                    printf(1, "XV6_TEST_OUTPUT ");
 4f4:	83 ec 08             	sub    $0x8,%esp
 4f7:	68 b1 0e 00 00       	push   $0xeb1
 4fc:	6a 01                	push   $0x1
 4fe:	e8 d0 04 00 00       	call   9d3 <printf>
 503:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 506:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
 50d:	eb 62                	jmp    571 <main+0x54d>
                        if (k < 63) {
 50f:	83 7d b4 3e          	cmpl   $0x3e,-0x4c(%ebp)
 513:	7f 2d                	jg     542 <main+0x51e>
                            printf(1, "0x%x ", (uint)buffer[j + k] & 0xFF);
 515:	8b 55 b8             	mov    -0x48(%ebp),%edx
 518:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 51b:	01 d0                	add    %edx,%eax
 51d:	89 c2                	mov    %eax,%edx
 51f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 522:	01 d0                	add    %edx,%eax
 524:	0f b6 00             	movzbl (%eax),%eax
 527:	0f be c0             	movsbl %al,%eax
 52a:	0f b6 c0             	movzbl %al,%eax
 52d:	83 ec 04             	sub    $0x4,%esp
 530:	50                   	push   %eax
 531:	68 c2 0e 00 00       	push   $0xec2
 536:	6a 01                	push   $0x1
 538:	e8 96 04 00 00       	call   9d3 <printf>
 53d:	83 c4 10             	add    $0x10,%esp
 540:	eb 2b                	jmp    56d <main+0x549>
                        } else {
                            printf(1, "0x%x\n", (uint)buffer[j + k] & 0xFF);
 542:	8b 55 b8             	mov    -0x48(%ebp),%edx
 545:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 548:	01 d0                	add    %edx,%eax
 54a:	89 c2                	mov    %eax,%edx
 54c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 54f:	01 d0                	add    %edx,%eax
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	0f b6 c0             	movzbl %al,%eax
 55a:	83 ec 04             	sub    $0x4,%esp
 55d:	50                   	push   %eax
 55e:	68 c8 0e 00 00       	push   $0xec8
 563:	6a 01                	push   $0x1
 565:	e8 69 04 00 00       	call   9d3 <printf>
 56a:	83 c4 10             	add    $0x10,%esp
                    for (int k = 0; k < 64; k ++) {
 56d:	83 45 b4 01          	addl   $0x1,-0x4c(%ebp)
 571:	83 7d b4 3f          	cmpl   $0x3f,-0x4c(%ebp)
 575:	7e 98                	jle    50f <main+0x4eb>
                for (int j = 0; j < PGSIZE; j +=64) {
 577:	83 45 b8 40          	addl   $0x40,-0x48(%ebp)
 57b:	81 7d b8 ff 0f 00 00 	cmpl   $0xfff,-0x48(%ebp)
 582:	0f 8e 6c ff ff ff    	jle    4f4 <main+0x4d0>
                        }
                    }
                }
                err("physical memory is decrypted incorrectly\n");
 588:	83 ec 0c             	sub    $0xc,%esp
 58b:	68 48 0f 00 00       	push   $0xf48
 590:	e8 6b fa ff ff       	call   0 <err>
 595:	83 c4 10             	add    $0x10,%esp
        for (int i = 0; i < entries_num; i++) {
 598:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
 59c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 59f:	3b 45 a8             	cmp    -0x58(%ebp),%eax
 5a2:	0f 8c 26 fe ff ff    	jl     3ce <main+0x3aa>
 5a8:	eb 15                	jmp    5bf <main+0x59b>
            }
        }
    }
    else {
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", entries_num, retval);
 5aa:	ff 75 9c             	pushl  -0x64(%ebp)
 5ad:	ff 75 a8             	pushl  -0x58(%ebp)
 5b0:	68 fc 0e 00 00       	push   $0xefc
 5b5:	6a 01                	push   $0x1
 5b7:	e8 17 04 00 00       	call   9d3 <printf>
 5bc:	83 c4 10             	add    $0x10,%esp
    }
    exit();
 5bf:	e8 7b 02 00 00       	call   83f <exit>

000005c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	57                   	push   %edi
 5c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5cc:	8b 55 10             	mov    0x10(%ebp),%edx
 5cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d2:	89 cb                	mov    %ecx,%ebx
 5d4:	89 df                	mov    %ebx,%edi
 5d6:	89 d1                	mov    %edx,%ecx
 5d8:	fc                   	cld    
 5d9:	f3 aa                	rep stos %al,%es:(%edi)
 5db:	89 ca                	mov    %ecx,%edx
 5dd:	89 fb                	mov    %edi,%ebx
 5df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 5e5:	90                   	nop
 5e6:	5b                   	pop    %ebx
 5e7:	5f                   	pop    %edi
 5e8:	5d                   	pop    %ebp
 5e9:	c3                   	ret    

000005ea <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 5ea:	f3 0f 1e fb          	endbr32 
 5ee:	55                   	push   %ebp
 5ef:	89 e5                	mov    %esp,%ebp
 5f1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 5fa:	90                   	nop
 5fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fe:	8d 42 01             	lea    0x1(%edx),%eax
 601:	89 45 0c             	mov    %eax,0xc(%ebp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	8d 48 01             	lea    0x1(%eax),%ecx
 60a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 60d:	0f b6 12             	movzbl (%edx),%edx
 610:	88 10                	mov    %dl,(%eax)
 612:	0f b6 00             	movzbl (%eax),%eax
 615:	84 c0                	test   %al,%al
 617:	75 e2                	jne    5fb <strcpy+0x11>
    ;
  return os;
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 61c:	c9                   	leave  
 61d:	c3                   	ret    

0000061e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 61e:	f3 0f 1e fb          	endbr32 
 622:	55                   	push   %ebp
 623:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 625:	eb 08                	jmp    62f <strcmp+0x11>
    p++, q++;
 627:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 62b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 62f:	8b 45 08             	mov    0x8(%ebp),%eax
 632:	0f b6 00             	movzbl (%eax),%eax
 635:	84 c0                	test   %al,%al
 637:	74 10                	je     649 <strcmp+0x2b>
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	0f b6 10             	movzbl (%eax),%edx
 63f:	8b 45 0c             	mov    0xc(%ebp),%eax
 642:	0f b6 00             	movzbl (%eax),%eax
 645:	38 c2                	cmp    %al,%dl
 647:	74 de                	je     627 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 649:	8b 45 08             	mov    0x8(%ebp),%eax
 64c:	0f b6 00             	movzbl (%eax),%eax
 64f:	0f b6 d0             	movzbl %al,%edx
 652:	8b 45 0c             	mov    0xc(%ebp),%eax
 655:	0f b6 00             	movzbl (%eax),%eax
 658:	0f b6 c0             	movzbl %al,%eax
 65b:	29 c2                	sub    %eax,%edx
 65d:	89 d0                	mov    %edx,%eax
}
 65f:	5d                   	pop    %ebp
 660:	c3                   	ret    

00000661 <strlen>:

uint
strlen(const char *s)
{
 661:	f3 0f 1e fb          	endbr32 
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 66b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 672:	eb 04                	jmp    678 <strlen+0x17>
 674:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 678:	8b 55 fc             	mov    -0x4(%ebp),%edx
 67b:	8b 45 08             	mov    0x8(%ebp),%eax
 67e:	01 d0                	add    %edx,%eax
 680:	0f b6 00             	movzbl (%eax),%eax
 683:	84 c0                	test   %al,%al
 685:	75 ed                	jne    674 <strlen+0x13>
    ;
  return n;
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <memset>:

void*
memset(void *dst, int c, uint n)
{
 68c:	f3 0f 1e fb          	endbr32 
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 693:	8b 45 10             	mov    0x10(%ebp),%eax
 696:	50                   	push   %eax
 697:	ff 75 0c             	pushl  0xc(%ebp)
 69a:	ff 75 08             	pushl  0x8(%ebp)
 69d:	e8 22 ff ff ff       	call   5c4 <stosb>
 6a2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 6a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6a8:	c9                   	leave  
 6a9:	c3                   	ret    

000006aa <strchr>:

char*
strchr(const char *s, char c)
{
 6aa:	f3 0f 1e fb          	endbr32 
 6ae:	55                   	push   %ebp
 6af:	89 e5                	mov    %esp,%ebp
 6b1:	83 ec 04             	sub    $0x4,%esp
 6b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6ba:	eb 14                	jmp    6d0 <strchr+0x26>
    if(*s == c)
 6bc:	8b 45 08             	mov    0x8(%ebp),%eax
 6bf:	0f b6 00             	movzbl (%eax),%eax
 6c2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 6c5:	75 05                	jne    6cc <strchr+0x22>
      return (char*)s;
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	eb 13                	jmp    6df <strchr+0x35>
  for(; *s; s++)
 6cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6d0:	8b 45 08             	mov    0x8(%ebp),%eax
 6d3:	0f b6 00             	movzbl (%eax),%eax
 6d6:	84 c0                	test   %al,%al
 6d8:	75 e2                	jne    6bc <strchr+0x12>
  return 0;
 6da:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6df:	c9                   	leave  
 6e0:	c3                   	ret    

000006e1 <gets>:

char*
gets(char *buf, int max)
{
 6e1:	f3 0f 1e fb          	endbr32 
 6e5:	55                   	push   %ebp
 6e6:	89 e5                	mov    %esp,%ebp
 6e8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6f2:	eb 42                	jmp    736 <gets+0x55>
    cc = read(0, &c, 1);
 6f4:	83 ec 04             	sub    $0x4,%esp
 6f7:	6a 01                	push   $0x1
 6f9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 6fc:	50                   	push   %eax
 6fd:	6a 00                	push   $0x0
 6ff:	e8 53 01 00 00       	call   857 <read>
 704:	83 c4 10             	add    $0x10,%esp
 707:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 70a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70e:	7e 33                	jle    743 <gets+0x62>
      break;
    buf[i++] = c;
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	8d 50 01             	lea    0x1(%eax),%edx
 716:	89 55 f4             	mov    %edx,-0xc(%ebp)
 719:	89 c2                	mov    %eax,%edx
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	01 c2                	add    %eax,%edx
 720:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 724:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 726:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 72a:	3c 0a                	cmp    $0xa,%al
 72c:	74 16                	je     744 <gets+0x63>
 72e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 732:	3c 0d                	cmp    $0xd,%al
 734:	74 0e                	je     744 <gets+0x63>
  for(i=0; i+1 < max; ){
 736:	8b 45 f4             	mov    -0xc(%ebp),%eax
 739:	83 c0 01             	add    $0x1,%eax
 73c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 73f:	7f b3                	jg     6f4 <gets+0x13>
 741:	eb 01                	jmp    744 <gets+0x63>
      break;
 743:	90                   	nop
      break;
  }
  buf[i] = '\0';
 744:	8b 55 f4             	mov    -0xc(%ebp),%edx
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	01 d0                	add    %edx,%eax
 74c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 74f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 752:	c9                   	leave  
 753:	c3                   	ret    

00000754 <stat>:

int
stat(const char *n, struct stat *st)
{
 754:	f3 0f 1e fb          	endbr32 
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 75e:	83 ec 08             	sub    $0x8,%esp
 761:	6a 00                	push   $0x0
 763:	ff 75 08             	pushl  0x8(%ebp)
 766:	e8 14 01 00 00       	call   87f <open>
 76b:	83 c4 10             	add    $0x10,%esp
 76e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 775:	79 07                	jns    77e <stat+0x2a>
    return -1;
 777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 77c:	eb 25                	jmp    7a3 <stat+0x4f>
  r = fstat(fd, st);
 77e:	83 ec 08             	sub    $0x8,%esp
 781:	ff 75 0c             	pushl  0xc(%ebp)
 784:	ff 75 f4             	pushl  -0xc(%ebp)
 787:	e8 0b 01 00 00       	call   897 <fstat>
 78c:	83 c4 10             	add    $0x10,%esp
 78f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 792:	83 ec 0c             	sub    $0xc,%esp
 795:	ff 75 f4             	pushl  -0xc(%ebp)
 798:	e8 ca 00 00 00       	call   867 <close>
 79d:	83 c4 10             	add    $0x10,%esp
  return r;
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7a3:	c9                   	leave  
 7a4:	c3                   	ret    

000007a5 <atoi>:

int
atoi(const char *s)
{
 7a5:	f3 0f 1e fb          	endbr32 
 7a9:	55                   	push   %ebp
 7aa:	89 e5                	mov    %esp,%ebp
 7ac:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7b6:	eb 25                	jmp    7dd <atoi+0x38>
    n = n*10 + *s++ - '0';
 7b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7bb:	89 d0                	mov    %edx,%eax
 7bd:	c1 e0 02             	shl    $0x2,%eax
 7c0:	01 d0                	add    %edx,%eax
 7c2:	01 c0                	add    %eax,%eax
 7c4:	89 c1                	mov    %eax,%ecx
 7c6:	8b 45 08             	mov    0x8(%ebp),%eax
 7c9:	8d 50 01             	lea    0x1(%eax),%edx
 7cc:	89 55 08             	mov    %edx,0x8(%ebp)
 7cf:	0f b6 00             	movzbl (%eax),%eax
 7d2:	0f be c0             	movsbl %al,%eax
 7d5:	01 c8                	add    %ecx,%eax
 7d7:	83 e8 30             	sub    $0x30,%eax
 7da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7dd:	8b 45 08             	mov    0x8(%ebp),%eax
 7e0:	0f b6 00             	movzbl (%eax),%eax
 7e3:	3c 2f                	cmp    $0x2f,%al
 7e5:	7e 0a                	jle    7f1 <atoi+0x4c>
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	0f b6 00             	movzbl (%eax),%eax
 7ed:	3c 39                	cmp    $0x39,%al
 7ef:	7e c7                	jle    7b8 <atoi+0x13>
  return n;
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7f4:	c9                   	leave  
 7f5:	c3                   	ret    

000007f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 7f6:	f3 0f 1e fb          	endbr32 
 7fa:	55                   	push   %ebp
 7fb:	89 e5                	mov    %esp,%ebp
 7fd:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 800:	8b 45 08             	mov    0x8(%ebp),%eax
 803:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 806:	8b 45 0c             	mov    0xc(%ebp),%eax
 809:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 80c:	eb 17                	jmp    825 <memmove+0x2f>
    *dst++ = *src++;
 80e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 811:	8d 42 01             	lea    0x1(%edx),%eax
 814:	89 45 f8             	mov    %eax,-0x8(%ebp)
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	8d 48 01             	lea    0x1(%eax),%ecx
 81d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 820:	0f b6 12             	movzbl (%edx),%edx
 823:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 825:	8b 45 10             	mov    0x10(%ebp),%eax
 828:	8d 50 ff             	lea    -0x1(%eax),%edx
 82b:	89 55 10             	mov    %edx,0x10(%ebp)
 82e:	85 c0                	test   %eax,%eax
 830:	7f dc                	jg     80e <memmove+0x18>
  return vdst;
 832:	8b 45 08             	mov    0x8(%ebp),%eax
}
 835:	c9                   	leave  
 836:	c3                   	ret    

00000837 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 837:	b8 01 00 00 00       	mov    $0x1,%eax
 83c:	cd 40                	int    $0x40
 83e:	c3                   	ret    

0000083f <exit>:
SYSCALL(exit)
 83f:	b8 02 00 00 00       	mov    $0x2,%eax
 844:	cd 40                	int    $0x40
 846:	c3                   	ret    

00000847 <wait>:
SYSCALL(wait)
 847:	b8 03 00 00 00       	mov    $0x3,%eax
 84c:	cd 40                	int    $0x40
 84e:	c3                   	ret    

0000084f <pipe>:
SYSCALL(pipe)
 84f:	b8 04 00 00 00       	mov    $0x4,%eax
 854:	cd 40                	int    $0x40
 856:	c3                   	ret    

00000857 <read>:
SYSCALL(read)
 857:	b8 05 00 00 00       	mov    $0x5,%eax
 85c:	cd 40                	int    $0x40
 85e:	c3                   	ret    

0000085f <write>:
SYSCALL(write)
 85f:	b8 10 00 00 00       	mov    $0x10,%eax
 864:	cd 40                	int    $0x40
 866:	c3                   	ret    

00000867 <close>:
SYSCALL(close)
 867:	b8 15 00 00 00       	mov    $0x15,%eax
 86c:	cd 40                	int    $0x40
 86e:	c3                   	ret    

0000086f <kill>:
SYSCALL(kill)
 86f:	b8 06 00 00 00       	mov    $0x6,%eax
 874:	cd 40                	int    $0x40
 876:	c3                   	ret    

00000877 <exec>:
SYSCALL(exec)
 877:	b8 07 00 00 00       	mov    $0x7,%eax
 87c:	cd 40                	int    $0x40
 87e:	c3                   	ret    

0000087f <open>:
SYSCALL(open)
 87f:	b8 0f 00 00 00       	mov    $0xf,%eax
 884:	cd 40                	int    $0x40
 886:	c3                   	ret    

00000887 <mknod>:
SYSCALL(mknod)
 887:	b8 11 00 00 00       	mov    $0x11,%eax
 88c:	cd 40                	int    $0x40
 88e:	c3                   	ret    

0000088f <unlink>:
SYSCALL(unlink)
 88f:	b8 12 00 00 00       	mov    $0x12,%eax
 894:	cd 40                	int    $0x40
 896:	c3                   	ret    

00000897 <fstat>:
SYSCALL(fstat)
 897:	b8 08 00 00 00       	mov    $0x8,%eax
 89c:	cd 40                	int    $0x40
 89e:	c3                   	ret    

0000089f <link>:
SYSCALL(link)
 89f:	b8 13 00 00 00       	mov    $0x13,%eax
 8a4:	cd 40                	int    $0x40
 8a6:	c3                   	ret    

000008a7 <mkdir>:
SYSCALL(mkdir)
 8a7:	b8 14 00 00 00       	mov    $0x14,%eax
 8ac:	cd 40                	int    $0x40
 8ae:	c3                   	ret    

000008af <chdir>:
SYSCALL(chdir)
 8af:	b8 09 00 00 00       	mov    $0x9,%eax
 8b4:	cd 40                	int    $0x40
 8b6:	c3                   	ret    

000008b7 <dup>:
SYSCALL(dup)
 8b7:	b8 0a 00 00 00       	mov    $0xa,%eax
 8bc:	cd 40                	int    $0x40
 8be:	c3                   	ret    

000008bf <getpid>:
SYSCALL(getpid)
 8bf:	b8 0b 00 00 00       	mov    $0xb,%eax
 8c4:	cd 40                	int    $0x40
 8c6:	c3                   	ret    

000008c7 <sbrk>:
SYSCALL(sbrk)
 8c7:	b8 0c 00 00 00       	mov    $0xc,%eax
 8cc:	cd 40                	int    $0x40
 8ce:	c3                   	ret    

000008cf <sleep>:
SYSCALL(sleep)
 8cf:	b8 0d 00 00 00       	mov    $0xd,%eax
 8d4:	cd 40                	int    $0x40
 8d6:	c3                   	ret    

000008d7 <uptime>:
SYSCALL(uptime)
 8d7:	b8 0e 00 00 00       	mov    $0xe,%eax
 8dc:	cd 40                	int    $0x40
 8de:	c3                   	ret    

000008df <mencrypt>:
SYSCALL(mencrypt)
 8df:	b8 16 00 00 00       	mov    $0x16,%eax
 8e4:	cd 40                	int    $0x40
 8e6:	c3                   	ret    

000008e7 <getpgtable>:
SYSCALL(getpgtable)
 8e7:	b8 17 00 00 00       	mov    $0x17,%eax
 8ec:	cd 40                	int    $0x40
 8ee:	c3                   	ret    

000008ef <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 8ef:	b8 18 00 00 00       	mov    $0x18,%eax
 8f4:	cd 40                	int    $0x40
 8f6:	c3                   	ret    

000008f7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 8f7:	f3 0f 1e fb          	endbr32 
 8fb:	55                   	push   %ebp
 8fc:	89 e5                	mov    %esp,%ebp
 8fe:	83 ec 18             	sub    $0x18,%esp
 901:	8b 45 0c             	mov    0xc(%ebp),%eax
 904:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 907:	83 ec 04             	sub    $0x4,%esp
 90a:	6a 01                	push   $0x1
 90c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 90f:	50                   	push   %eax
 910:	ff 75 08             	pushl  0x8(%ebp)
 913:	e8 47 ff ff ff       	call   85f <write>
 918:	83 c4 10             	add    $0x10,%esp
}
 91b:	90                   	nop
 91c:	c9                   	leave  
 91d:	c3                   	ret    

0000091e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 91e:	f3 0f 1e fb          	endbr32 
 922:	55                   	push   %ebp
 923:	89 e5                	mov    %esp,%ebp
 925:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 928:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 92f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 933:	74 17                	je     94c <printint+0x2e>
 935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 939:	79 11                	jns    94c <printint+0x2e>
    neg = 1;
 93b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 942:	8b 45 0c             	mov    0xc(%ebp),%eax
 945:	f7 d8                	neg    %eax
 947:	89 45 ec             	mov    %eax,-0x14(%ebp)
 94a:	eb 06                	jmp    952 <printint+0x34>
  } else {
    x = xx;
 94c:	8b 45 0c             	mov    0xc(%ebp),%eax
 94f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 952:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 959:	8b 4d 10             	mov    0x10(%ebp),%ecx
 95c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 95f:	ba 00 00 00 00       	mov    $0x0,%edx
 964:	f7 f1                	div    %ecx
 966:	89 d1                	mov    %edx,%ecx
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8d 50 01             	lea    0x1(%eax),%edx
 96e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 971:	0f b6 91 e8 11 00 00 	movzbl 0x11e8(%ecx),%edx
 978:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 97c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 97f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 982:	ba 00 00 00 00       	mov    $0x0,%edx
 987:	f7 f1                	div    %ecx
 989:	89 45 ec             	mov    %eax,-0x14(%ebp)
 98c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 990:	75 c7                	jne    959 <printint+0x3b>
  if(neg)
 992:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 996:	74 2d                	je     9c5 <printint+0xa7>
    buf[i++] = '-';
 998:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99b:	8d 50 01             	lea    0x1(%eax),%edx
 99e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9a1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 9a6:	eb 1d                	jmp    9c5 <printint+0xa7>
    putc(fd, buf[i]);
 9a8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 9ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ae:	01 d0                	add    %edx,%eax
 9b0:	0f b6 00             	movzbl (%eax),%eax
 9b3:	0f be c0             	movsbl %al,%eax
 9b6:	83 ec 08             	sub    $0x8,%esp
 9b9:	50                   	push   %eax
 9ba:	ff 75 08             	pushl  0x8(%ebp)
 9bd:	e8 35 ff ff ff       	call   8f7 <putc>
 9c2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 9c5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 9c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9cd:	79 d9                	jns    9a8 <printint+0x8a>
}
 9cf:	90                   	nop
 9d0:	90                   	nop
 9d1:	c9                   	leave  
 9d2:	c3                   	ret    

000009d3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 9d3:	f3 0f 1e fb          	endbr32 
 9d7:	55                   	push   %ebp
 9d8:	89 e5                	mov    %esp,%ebp
 9da:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9e4:	8d 45 0c             	lea    0xc(%ebp),%eax
 9e7:	83 c0 04             	add    $0x4,%eax
 9ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9f4:	e9 59 01 00 00       	jmp    b52 <printf+0x17f>
    c = fmt[i] & 0xff;
 9f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 9fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ff:	01 d0                	add    %edx,%eax
 a01:	0f b6 00             	movzbl (%eax),%eax
 a04:	0f be c0             	movsbl %al,%eax
 a07:	25 ff 00 00 00       	and    $0xff,%eax
 a0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a13:	75 2c                	jne    a41 <printf+0x6e>
      if(c == '%'){
 a15:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a19:	75 0c                	jne    a27 <printf+0x54>
        state = '%';
 a1b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a22:	e9 27 01 00 00       	jmp    b4e <printf+0x17b>
      } else {
        putc(fd, c);
 a27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2a:	0f be c0             	movsbl %al,%eax
 a2d:	83 ec 08             	sub    $0x8,%esp
 a30:	50                   	push   %eax
 a31:	ff 75 08             	pushl  0x8(%ebp)
 a34:	e8 be fe ff ff       	call   8f7 <putc>
 a39:	83 c4 10             	add    $0x10,%esp
 a3c:	e9 0d 01 00 00       	jmp    b4e <printf+0x17b>
      }
    } else if(state == '%'){
 a41:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a45:	0f 85 03 01 00 00    	jne    b4e <printf+0x17b>
      if(c == 'd'){
 a4b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a4f:	75 1e                	jne    a6f <printf+0x9c>
        printint(fd, *ap, 10, 1);
 a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a54:	8b 00                	mov    (%eax),%eax
 a56:	6a 01                	push   $0x1
 a58:	6a 0a                	push   $0xa
 a5a:	50                   	push   %eax
 a5b:	ff 75 08             	pushl  0x8(%ebp)
 a5e:	e8 bb fe ff ff       	call   91e <printint>
 a63:	83 c4 10             	add    $0x10,%esp
        ap++;
 a66:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a6a:	e9 d8 00 00 00       	jmp    b47 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 a6f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a73:	74 06                	je     a7b <printf+0xa8>
 a75:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a79:	75 1e                	jne    a99 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 a7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a7e:	8b 00                	mov    (%eax),%eax
 a80:	6a 00                	push   $0x0
 a82:	6a 10                	push   $0x10
 a84:	50                   	push   %eax
 a85:	ff 75 08             	pushl  0x8(%ebp)
 a88:	e8 91 fe ff ff       	call   91e <printint>
 a8d:	83 c4 10             	add    $0x10,%esp
        ap++;
 a90:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a94:	e9 ae 00 00 00       	jmp    b47 <printf+0x174>
      } else if(c == 's'){
 a99:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a9d:	75 43                	jne    ae2 <printf+0x10f>
        s = (char*)*ap;
 a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aa2:	8b 00                	mov    (%eax),%eax
 aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 aa7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 aab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aaf:	75 25                	jne    ad6 <printf+0x103>
          s = "(null)";
 ab1:	c7 45 f4 72 0f 00 00 	movl   $0xf72,-0xc(%ebp)
        while(*s != 0){
 ab8:	eb 1c                	jmp    ad6 <printf+0x103>
          putc(fd, *s);
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	0f b6 00             	movzbl (%eax),%eax
 ac0:	0f be c0             	movsbl %al,%eax
 ac3:	83 ec 08             	sub    $0x8,%esp
 ac6:	50                   	push   %eax
 ac7:	ff 75 08             	pushl  0x8(%ebp)
 aca:	e8 28 fe ff ff       	call   8f7 <putc>
 acf:	83 c4 10             	add    $0x10,%esp
          s++;
 ad2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad9:	0f b6 00             	movzbl (%eax),%eax
 adc:	84 c0                	test   %al,%al
 ade:	75 da                	jne    aba <printf+0xe7>
 ae0:	eb 65                	jmp    b47 <printf+0x174>
        }
      } else if(c == 'c'){
 ae2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 ae6:	75 1d                	jne    b05 <printf+0x132>
        putc(fd, *ap);
 ae8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aeb:	8b 00                	mov    (%eax),%eax
 aed:	0f be c0             	movsbl %al,%eax
 af0:	83 ec 08             	sub    $0x8,%esp
 af3:	50                   	push   %eax
 af4:	ff 75 08             	pushl  0x8(%ebp)
 af7:	e8 fb fd ff ff       	call   8f7 <putc>
 afc:	83 c4 10             	add    $0x10,%esp
        ap++;
 aff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b03:	eb 42                	jmp    b47 <printf+0x174>
      } else if(c == '%'){
 b05:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b09:	75 17                	jne    b22 <printf+0x14f>
        putc(fd, c);
 b0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b0e:	0f be c0             	movsbl %al,%eax
 b11:	83 ec 08             	sub    $0x8,%esp
 b14:	50                   	push   %eax
 b15:	ff 75 08             	pushl  0x8(%ebp)
 b18:	e8 da fd ff ff       	call   8f7 <putc>
 b1d:	83 c4 10             	add    $0x10,%esp
 b20:	eb 25                	jmp    b47 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b22:	83 ec 08             	sub    $0x8,%esp
 b25:	6a 25                	push   $0x25
 b27:	ff 75 08             	pushl  0x8(%ebp)
 b2a:	e8 c8 fd ff ff       	call   8f7 <putc>
 b2f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 b32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b35:	0f be c0             	movsbl %al,%eax
 b38:	83 ec 08             	sub    $0x8,%esp
 b3b:	50                   	push   %eax
 b3c:	ff 75 08             	pushl  0x8(%ebp)
 b3f:	e8 b3 fd ff ff       	call   8f7 <putc>
 b44:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 b47:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 b4e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b52:	8b 55 0c             	mov    0xc(%ebp),%edx
 b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b58:	01 d0                	add    %edx,%eax
 b5a:	0f b6 00             	movzbl (%eax),%eax
 b5d:	84 c0                	test   %al,%al
 b5f:	0f 85 94 fe ff ff    	jne    9f9 <printf+0x26>
    }
  }
}
 b65:	90                   	nop
 b66:	90                   	nop
 b67:	c9                   	leave  
 b68:	c3                   	ret    

00000b69 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b69:	f3 0f 1e fb          	endbr32 
 b6d:	55                   	push   %ebp
 b6e:	89 e5                	mov    %esp,%ebp
 b70:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b73:	8b 45 08             	mov    0x8(%ebp),%eax
 b76:	83 e8 08             	sub    $0x8,%eax
 b79:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b7c:	a1 04 12 00 00       	mov    0x1204,%eax
 b81:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b84:	eb 24                	jmp    baa <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b89:	8b 00                	mov    (%eax),%eax
 b8b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b8e:	72 12                	jb     ba2 <free+0x39>
 b90:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b93:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b96:	77 24                	ja     bbc <free+0x53>
 b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9b:	8b 00                	mov    (%eax),%eax
 b9d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ba0:	72 1a                	jb     bbc <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ba2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba5:	8b 00                	mov    (%eax),%eax
 ba7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 baa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bad:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bb0:	76 d4                	jbe    b86 <free+0x1d>
 bb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb5:	8b 00                	mov    (%eax),%eax
 bb7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 bba:	73 ca                	jae    b86 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 bbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bbf:	8b 40 04             	mov    0x4(%eax),%eax
 bc2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 bc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bcc:	01 c2                	add    %eax,%edx
 bce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd1:	8b 00                	mov    (%eax),%eax
 bd3:	39 c2                	cmp    %eax,%edx
 bd5:	75 24                	jne    bfb <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 bd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bda:	8b 50 04             	mov    0x4(%eax),%edx
 bdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 be0:	8b 00                	mov    (%eax),%eax
 be2:	8b 40 04             	mov    0x4(%eax),%eax
 be5:	01 c2                	add    %eax,%edx
 be7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bea:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf0:	8b 00                	mov    (%eax),%eax
 bf2:	8b 10                	mov    (%eax),%edx
 bf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bf7:	89 10                	mov    %edx,(%eax)
 bf9:	eb 0a                	jmp    c05 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 bfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bfe:	8b 10                	mov    (%eax),%edx
 c00:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c03:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c08:	8b 40 04             	mov    0x4(%eax),%eax
 c0b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c12:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c15:	01 d0                	add    %edx,%eax
 c17:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 c1a:	75 20                	jne    c3c <free+0xd3>
    p->s.size += bp->s.size;
 c1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1f:	8b 50 04             	mov    0x4(%eax),%edx
 c22:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c25:	8b 40 04             	mov    0x4(%eax),%eax
 c28:	01 c2                	add    %eax,%edx
 c2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c2d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c30:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c33:	8b 10                	mov    (%eax),%edx
 c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c38:	89 10                	mov    %edx,(%eax)
 c3a:	eb 08                	jmp    c44 <free+0xdb>
  } else
    p->s.ptr = bp;
 c3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c42:	89 10                	mov    %edx,(%eax)
  freep = p;
 c44:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c47:	a3 04 12 00 00       	mov    %eax,0x1204
}
 c4c:	90                   	nop
 c4d:	c9                   	leave  
 c4e:	c3                   	ret    

00000c4f <morecore>:

static Header*
morecore(uint nu)
{
 c4f:	f3 0f 1e fb          	endbr32 
 c53:	55                   	push   %ebp
 c54:	89 e5                	mov    %esp,%ebp
 c56:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c59:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c60:	77 07                	ja     c69 <morecore+0x1a>
    nu = 4096;
 c62:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c69:	8b 45 08             	mov    0x8(%ebp),%eax
 c6c:	c1 e0 03             	shl    $0x3,%eax
 c6f:	83 ec 0c             	sub    $0xc,%esp
 c72:	50                   	push   %eax
 c73:	e8 4f fc ff ff       	call   8c7 <sbrk>
 c78:	83 c4 10             	add    $0x10,%esp
 c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c7e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c82:	75 07                	jne    c8b <morecore+0x3c>
    return 0;
 c84:	b8 00 00 00 00       	mov    $0x0,%eax
 c89:	eb 26                	jmp    cb1 <morecore+0x62>
  hp = (Header*)p;
 c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c94:	8b 55 08             	mov    0x8(%ebp),%edx
 c97:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c9d:	83 c0 08             	add    $0x8,%eax
 ca0:	83 ec 0c             	sub    $0xc,%esp
 ca3:	50                   	push   %eax
 ca4:	e8 c0 fe ff ff       	call   b69 <free>
 ca9:	83 c4 10             	add    $0x10,%esp
  return freep;
 cac:	a1 04 12 00 00       	mov    0x1204,%eax
}
 cb1:	c9                   	leave  
 cb2:	c3                   	ret    

00000cb3 <malloc>:

void*
malloc(uint nbytes)
{
 cb3:	f3 0f 1e fb          	endbr32 
 cb7:	55                   	push   %ebp
 cb8:	89 e5                	mov    %esp,%ebp
 cba:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cbd:	8b 45 08             	mov    0x8(%ebp),%eax
 cc0:	83 c0 07             	add    $0x7,%eax
 cc3:	c1 e8 03             	shr    $0x3,%eax
 cc6:	83 c0 01             	add    $0x1,%eax
 cc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ccc:	a1 04 12 00 00       	mov    0x1204,%eax
 cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 cd8:	75 23                	jne    cfd <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 cda:	c7 45 f0 fc 11 00 00 	movl   $0x11fc,-0x10(%ebp)
 ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ce4:	a3 04 12 00 00       	mov    %eax,0x1204
 ce9:	a1 04 12 00 00       	mov    0x1204,%eax
 cee:	a3 fc 11 00 00       	mov    %eax,0x11fc
    base.s.size = 0;
 cf3:	c7 05 00 12 00 00 00 	movl   $0x0,0x1200
 cfa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d00:	8b 00                	mov    (%eax),%eax
 d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d08:	8b 40 04             	mov    0x4(%eax),%eax
 d0b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 d0e:	77 4d                	ja     d5d <malloc+0xaa>
      if(p->s.size == nunits)
 d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d13:	8b 40 04             	mov    0x4(%eax),%eax
 d16:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 d19:	75 0c                	jne    d27 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d1e:	8b 10                	mov    (%eax),%edx
 d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d23:	89 10                	mov    %edx,(%eax)
 d25:	eb 26                	jmp    d4d <malloc+0x9a>
      else {
        p->s.size -= nunits;
 d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d2a:	8b 40 04             	mov    0x4(%eax),%eax
 d2d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d30:	89 c2                	mov    %eax,%edx
 d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d35:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d3b:	8b 40 04             	mov    0x4(%eax),%eax
 d3e:	c1 e0 03             	shl    $0x3,%eax
 d41:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d47:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d4a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d50:	a3 04 12 00 00       	mov    %eax,0x1204
      return (void*)(p + 1);
 d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d58:	83 c0 08             	add    $0x8,%eax
 d5b:	eb 3b                	jmp    d98 <malloc+0xe5>
    }
    if(p == freep)
 d5d:	a1 04 12 00 00       	mov    0x1204,%eax
 d62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d65:	75 1e                	jne    d85 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 d67:	83 ec 0c             	sub    $0xc,%esp
 d6a:	ff 75 ec             	pushl  -0x14(%ebp)
 d6d:	e8 dd fe ff ff       	call   c4f <morecore>
 d72:	83 c4 10             	add    $0x10,%esp
 d75:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d7c:	75 07                	jne    d85 <malloc+0xd2>
        return 0;
 d7e:	b8 00 00 00 00       	mov    $0x0,%eax
 d83:	eb 13                	jmp    d98 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d8e:	8b 00                	mov    (%eax),%eax
 d90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d93:	e9 6d ff ff ff       	jmp    d05 <malloc+0x52>
  }
}
 d98:	c9                   	leave  
 d99:	c3                   	ret    
