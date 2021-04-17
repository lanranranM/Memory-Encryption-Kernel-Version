
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
  10:	68 c0 0c 00 00       	push   $0xcc0
  15:	6a 01                	push   $0x1
  17:	e8 dd 08 00 00       	call   8f9 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 41 07 00 00       	call   765 <exit>

00000024 <access_all_dummy_pages>:
}


void access_all_dummy_pages(char **dummy_pages, uint len) {
  24:	f3 0f 1e fb          	endbr32 
  28:	55                   	push   %ebp
  29:	89 e5                	mov    %esp,%ebp
  2b:	83 ec 18             	sub    $0x18,%esp
    for (int i = 0; i < len; i++) {
  2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  35:	eb 1b                	jmp    52 <access_all_dummy_pages+0x2e>
        char temp = dummy_pages[i][0];
  37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  41:	8b 45 08             	mov    0x8(%ebp),%eax
  44:	01 d0                	add    %edx,%eax
  46:	8b 00                	mov    (%eax),%eax
  48:	0f b6 00             	movzbl (%eax),%eax
  4b:	88 45 f3             	mov    %al,-0xd(%ebp)
    for (int i = 0; i < len; i++) {
  4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  55:	39 45 0c             	cmp    %eax,0xc(%ebp)
  58:	77 dd                	ja     37 <access_all_dummy_pages+0x13>
        temp = temp;
        // printf(1, "0x%x ", dummy_pages[i]);
    }
    printf(1, "\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 d4 0c 00 00       	push   $0xcd4
  62:	6a 01                	push   $0x1
  64:	e8 90 08 00 00       	call   8f9 <printf>
  69:	83 c4 10             	add    $0x10,%esp
}
  6c:	90                   	nop
  6d:	c9                   	leave  
  6e:	c3                   	ret    

0000006f <main>:

int main(void) {
  6f:	f3 0f 1e fb          	endbr32 
  73:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  77:	83 e4 f0             	and    $0xfffffff0,%esp
  7a:	ff 71 fc             	pushl  -0x4(%ecx)
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  80:	57                   	push   %edi
  81:	56                   	push   %esi
  82:	53                   	push   %ebx
  83:	51                   	push   %ecx
  84:	83 ec 68             	sub    $0x68,%esp
    const uint PAGES_NUM = 32;
  87:	c7 45 c4 20 00 00 00 	movl   $0x20,-0x3c(%ebp)
    const uint expected_dummy_pages_num = 4;
  8e:	c7 45 c0 04 00 00 00 	movl   $0x4,-0x40(%ebp)
    // These pages are used to make sure the test result is consistent for different text pages number
    char *dummy_pages[expected_dummy_pages_num];
  95:	8b 45 c0             	mov    -0x40(%ebp),%eax
  98:	83 e8 01             	sub    $0x1,%eax
  9b:	89 45 bc             	mov    %eax,-0x44(%ebp)
  9e:	8b 45 c0             	mov    -0x40(%ebp),%eax
  a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  a8:	b8 10 00 00 00       	mov    $0x10,%eax
  ad:	83 e8 01             	sub    $0x1,%eax
  b0:	01 d0                	add    %edx,%eax
  b2:	bf 10 00 00 00       	mov    $0x10,%edi
  b7:	ba 00 00 00 00       	mov    $0x0,%edx
  bc:	f7 f7                	div    %edi
  be:	6b c0 10             	imul   $0x10,%eax,%eax
  c1:	89 c2                	mov    %eax,%edx
  c3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  c9:	89 e7                	mov    %esp,%edi
  cb:	29 d7                	sub    %edx,%edi
  cd:	89 fa                	mov    %edi,%edx
  cf:	39 d4                	cmp    %edx,%esp
  d1:	74 10                	je     e3 <main+0x74>
  d3:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  d9:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  e0:	00 
  e1:	eb ec                	jmp    cf <main+0x60>
  e3:	89 c2                	mov    %eax,%edx
  e5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  eb:	29 d4                	sub    %edx,%esp
  ed:	89 c2                	mov    %eax,%edx
  ef:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  f5:	85 d2                	test   %edx,%edx
  f7:	74 0d                	je     106 <main+0x97>
  f9:	25 ff 0f 00 00       	and    $0xfff,%eax
  fe:	83 e8 04             	sub    $0x4,%eax
 101:	01 e0                	add    %esp,%eax
 103:	83 08 00             	orl    $0x0,(%eax)
 106:	89 e0                	mov    %esp,%eax
 108:	83 c0 03             	add    $0x3,%eax
 10b:	c1 e8 02             	shr    $0x2,%eax
 10e:	c1 e0 02             	shl    $0x2,%eax
 111:	89 45 b8             	mov    %eax,-0x48(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	68 00 10 00 00       	push   $0x1000
 11c:	e8 cc 06 00 00       	call   7ed <sbrk>
 121:	83 c4 10             	add    $0x10,%esp
 124:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    char *sp = buffer - PGSIZE;
 127:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 12a:	2d 00 10 00 00       	sub    $0x1000,%eax
 12f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
 132:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 135:	2d 00 20 00 00       	sub    $0x2000,%eax
 13a:	89 45 ac             	mov    %eax,-0x54(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
 13d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 140:	83 e8 01             	sub    $0x1,%eax
 143:	89 45 a8             	mov    %eax,-0x58(%ebp)
 146:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 149:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 150:	b8 10 00 00 00       	mov    $0x10,%eax
 155:	83 e8 01             	sub    $0x1,%eax
 158:	01 d0                	add    %edx,%eax
 15a:	bf 10 00 00 00       	mov    $0x10,%edi
 15f:	ba 00 00 00 00       	mov    $0x0,%edx
 164:	f7 f7                	div    %edi
 166:	6b c0 10             	imul   $0x10,%eax,%eax
 169:	89 c2                	mov    %eax,%edx
 16b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
 171:	89 e6                	mov    %esp,%esi
 173:	29 d6                	sub    %edx,%esi
 175:	89 f2                	mov    %esi,%edx
 177:	39 d4                	cmp    %edx,%esp
 179:	74 10                	je     18b <main+0x11c>
 17b:	81 ec 00 10 00 00    	sub    $0x1000,%esp
 181:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
 188:	00 
 189:	eb ec                	jmp    177 <main+0x108>
 18b:	89 c2                	mov    %eax,%edx
 18d:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 193:	29 d4                	sub    %edx,%esp
 195:	89 c2                	mov    %eax,%edx
 197:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 19d:	85 d2                	test   %edx,%edx
 19f:	74 0d                	je     1ae <main+0x13f>
 1a1:	25 ff 0f 00 00       	and    $0xfff,%eax
 1a6:	83 e8 04             	sub    $0x4,%eax
 1a9:	01 e0                	add    %esp,%eax
 1ab:	83 08 00             	orl    $0x0,(%eax)
 1ae:	89 e0                	mov    %esp,%eax
 1b0:	83 c0 03             	add    $0x3,%eax
 1b3:	c1 e8 02             	shr    $0x2,%eax
 1b6:	c1 e0 02             	shl    $0x2,%eax
 1b9:	89 45 a4             	mov    %eax,-0x5c(%ebp)

    uint text_pages = (uint) boundary / PGSIZE;
 1bc:	8b 45 ac             	mov    -0x54(%ebp),%eax
 1bf:	c1 e8 0c             	shr    $0xc,%eax
 1c2:	89 45 a0             	mov    %eax,-0x60(%ebp)
    if (text_pages > expected_dummy_pages_num - 1)
 1c5:	8b 45 c0             	mov    -0x40(%ebp),%eax
 1c8:	83 e8 01             	sub    $0x1,%eax
 1cb:	39 45 a0             	cmp    %eax,-0x60(%ebp)
 1ce:	76 10                	jbe    1e0 <main+0x171>
        err("XV6_TEST_OUTPUT: program size exceeds the maximum allowed size. Please let us know if this case happens\n");
 1d0:	83 ec 0c             	sub    $0xc,%esp
 1d3:	68 d8 0c 00 00       	push   $0xcd8
 1d8:	e8 23 fe ff ff       	call   0 <err>
 1dd:	83 c4 10             	add    $0x10,%esp
    
    for (int i = 0; i < text_pages; i++)
 1e0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 1e7:	eb 15                	jmp    1fe <main+0x18f>
        dummy_pages[i] = (char *)(i * PGSIZE);
 1e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
 1ec:	c1 e0 0c             	shl    $0xc,%eax
 1ef:	89 c1                	mov    %eax,%ecx
 1f1:	8b 45 b8             	mov    -0x48(%ebp),%eax
 1f4:	8b 55 c8             	mov    -0x38(%ebp),%edx
 1f7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int i = 0; i < text_pages; i++)
 1fa:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
 1fe:	8b 45 c8             	mov    -0x38(%ebp),%eax
 201:	39 45 a0             	cmp    %eax,-0x60(%ebp)
 204:	77 e3                	ja     1e9 <main+0x17a>
    dummy_pages[text_pages] = sp;
 206:	8b 45 b8             	mov    -0x48(%ebp),%eax
 209:	8b 55 a0             	mov    -0x60(%ebp),%edx
 20c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
 20f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 212:	8b 45 a0             	mov    -0x60(%ebp),%eax
 215:	83 c0 01             	add    $0x1,%eax
 218:	89 45 cc             	mov    %eax,-0x34(%ebp)
 21b:	eb 1d                	jmp    23a <main+0x1cb>
        dummy_pages[i] = sbrk(PGSIZE * sizeof(char));
 21d:	83 ec 0c             	sub    $0xc,%esp
 220:	68 00 10 00 00       	push   $0x1000
 225:	e8 c3 05 00 00       	call   7ed <sbrk>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	8b 55 b8             	mov    -0x48(%ebp),%edx
 230:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 233:	89 04 8a             	mov    %eax,(%edx,%ecx,4)
    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 236:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 23a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 23d:	39 45 c0             	cmp    %eax,-0x40(%ebp)
 240:	77 db                	ja     21d <main+0x1ae>
    

    // After this call, all the dummy pages including text pages and stack pages
    // should be resident in the clock queue.
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 242:	83 ec 08             	sub    $0x8,%esp
 245:	ff 75 c0             	pushl  -0x40(%ebp)
 248:	ff 75 b8             	pushl  -0x48(%ebp)
 24b:	e8 d4 fd ff ff       	call   24 <access_all_dummy_pages>
 250:	83 c4 10             	add    $0x10,%esp

    // Bring the buffer page into the clock queue
    buffer[0] = buffer[0];
 253:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 256:	0f b6 10             	movzbl (%eax),%edx
 259:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 25c:	88 10                	mov    %dl,(%eax)

    // Now we should have expected_dummy_pages_num + 1 (buffer) pages in the clock queue
    // Fill up the remainig slot with heap-allocated page
    // and bring all of them into the clock queue
    int heap_pages_num = CLOCKSIZE - expected_dummy_pages_num - 1;
 25e:	b8 07 00 00 00       	mov    $0x7,%eax
 263:	2b 45 c0             	sub    -0x40(%ebp),%eax
 266:	89 45 9c             	mov    %eax,-0x64(%ebp)
    char *ptr = sbrk(heap_pages_num * PGSIZE * sizeof(char));
 269:	8b 45 9c             	mov    -0x64(%ebp),%eax
 26c:	c1 e0 0c             	shl    $0xc,%eax
 26f:	83 ec 0c             	sub    $0xc,%esp
 272:	50                   	push   %eax
 273:	e8 75 05 00 00       	call   7ed <sbrk>
 278:	83 c4 10             	add    $0x10,%esp
 27b:	89 45 98             	mov    %eax,-0x68(%ebp)
    ptr[heap_pages_num / 2 * PGSIZE] = 0xAA;
 27e:	8b 45 9c             	mov    -0x64(%ebp),%eax
 281:	89 c2                	mov    %eax,%edx
 283:	c1 ea 1f             	shr    $0x1f,%edx
 286:	01 d0                	add    %edx,%eax
 288:	d1 f8                	sar    %eax
 28a:	c1 e0 0c             	shl    $0xc,%eax
 28d:	89 c2                	mov    %eax,%edx
 28f:	8b 45 98             	mov    -0x68(%ebp),%eax
 292:	01 d0                	add    %edx,%eax
 294:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int i = 0; i < heap_pages_num; i++) {
 297:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 29e:	eb 31                	jmp    2d1 <main+0x262>
      for (int j = 0; j < PGSIZE; j++) {
 2a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2a7:	eb 1b                	jmp    2c4 <main+0x255>
        ptr[i * PGSIZE + j] = 0xAA;
 2a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
 2ac:	c1 e0 0c             	shl    $0xc,%eax
 2af:	89 c2                	mov    %eax,%edx
 2b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2b4:	01 d0                	add    %edx,%eax
 2b6:	89 c2                	mov    %eax,%edx
 2b8:	8b 45 98             	mov    -0x68(%ebp),%eax
 2bb:	01 d0                	add    %edx,%eax
 2bd:	c6 00 aa             	movb   $0xaa,(%eax)
      for (int j = 0; j < PGSIZE; j++) {
 2c0:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
 2c4:	81 7d d4 ff 0f 00 00 	cmpl   $0xfff,-0x2c(%ebp)
 2cb:	7e dc                	jle    2a9 <main+0x23a>
    for (int i = 0; i < heap_pages_num; i++) {
 2cd:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 2d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
 2d4:	3b 45 9c             	cmp    -0x64(%ebp),%eax
 2d7:	7c c7                	jl     2a0 <main+0x231>
      }
    }
    
    // An extra page which will trigger the page eviction
    // This eviction will evict page 0
    char* extra_pages = sbrk(PGSIZE * sizeof(char));
 2d9:	83 ec 0c             	sub    $0xc,%esp
 2dc:	68 00 10 00 00       	push   $0x1000
 2e1:	e8 07 05 00 00       	call   7ed <sbrk>
 2e6:	83 c4 10             	add    $0x10,%esp
 2e9:	89 45 94             	mov    %eax,-0x6c(%ebp)
    for (int j = 0; j < PGSIZE; j++) {
 2ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 2f3:	eb 0f                	jmp    304 <main+0x295>
      extra_pages[j] = 0xAA;
 2f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
 2f8:	8b 45 94             	mov    -0x6c(%ebp),%eax
 2fb:	01 d0                	add    %edx,%eax
 2fd:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int j = 0; j < PGSIZE; j++) {
 300:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 304:	81 7d d8 ff 0f 00 00 	cmpl   $0xfff,-0x28(%ebp)
 30b:	7e e8                	jle    2f5 <main+0x286>
    }

    // Bring all the dummy pages and buffer back to the 
    // clock queue and reset their ref to 1
    // At this time, the first heap-allocated page is ensured to be evicted
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 30d:	83 ec 08             	sub    $0x8,%esp
 310:	ff 75 c0             	pushl  -0x40(%ebp)
 313:	ff 75 b8             	pushl  -0x48(%ebp)
 316:	e8 09 fd ff ff       	call   24 <access_all_dummy_pages>
 31b:	83 c4 10             	add    $0x10,%esp
    buffer[0] = buffer[0];
 31e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 321:	0f b6 10             	movzbl (%eax),%edx
 324:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 327:	88 10                	mov    %dl,(%eax)

    // Verify that the pages pointed by the ptr is evicted
    int retval = getpgtable(pt_entries, heap_pages_num + 1, 0);
 329:	8b 45 9c             	mov    -0x64(%ebp),%eax
 32c:	83 c0 01             	add    $0x1,%eax
 32f:	83 ec 04             	sub    $0x4,%esp
 332:	6a 00                	push   $0x0
 334:	50                   	push   %eax
 335:	ff 75 a4             	pushl  -0x5c(%ebp)
 338:	e8 d0 04 00 00       	call   80d <getpgtable>
 33d:	83 c4 10             	add    $0x10,%esp
 340:	89 45 90             	mov    %eax,-0x70(%ebp)
    if (retval == heap_pages_num + 1) {
 343:	8b 45 9c             	mov    -0x64(%ebp),%eax
 346:	83 c0 01             	add    $0x1,%eax
 349:	39 45 90             	cmp    %eax,-0x70(%ebp)
 34c:	0f 85 7e 01 00 00    	jne    4d0 <main+0x461>
      for (int i = 0; i < retval; i++) {
 352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 359:	e9 64 01 00 00       	jmp    4c2 <main+0x453>
              i,
              pt_entries[i].pdx,
              pt_entries[i].ptx,
              pt_entries[i].writable,
              pt_entries[i].encrypted,
              pt_entries[i].ref
 35e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 361:	8b 55 dc             	mov    -0x24(%ebp),%edx
 364:	0f b6 44 d0 07       	movzbl 0x7(%eax,%edx,8),%eax
 369:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 36c:	0f b6 f0             	movzbl %al,%esi
              pt_entries[i].encrypted,
 36f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 372:	8b 55 dc             	mov    -0x24(%ebp),%edx
 375:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 37a:	c0 e8 06             	shr    $0x6,%al
 37d:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 380:	0f b6 d8             	movzbl %al,%ebx
              pt_entries[i].writable,
 383:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 386:	8b 55 dc             	mov    -0x24(%ebp),%edx
 389:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 38e:	c0 e8 05             	shr    $0x5,%al
 391:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 394:	0f b6 c8             	movzbl %al,%ecx
              pt_entries[i].ptx,
 397:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 39a:	8b 55 dc             	mov    -0x24(%ebp),%edx
 39d:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 3a0:	c1 e8 0a             	shr    $0xa,%eax
 3a3:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3a7:	0f b7 d0             	movzwl %ax,%edx
              pt_entries[i].pdx,
 3aa:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3ad:	8b 7d dc             	mov    -0x24(%ebp),%edi
 3b0:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 3b4:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3b8:	0f b7 c0             	movzwl %ax,%eax
 3bb:	56                   	push   %esi
 3bc:	53                   	push   %ebx
 3bd:	51                   	push   %ecx
 3be:	52                   	push   %edx
 3bf:	50                   	push   %eax
 3c0:	ff 75 dc             	pushl  -0x24(%ebp)
 3c3:	68 44 0d 00 00       	push   $0xd44
 3c8:	6a 01                	push   $0x1
 3ca:	e8 2a 05 00 00       	call   8f9 <printf>
 3cf:	83 c4 20             	add    $0x20,%esp
          ); 
          
          uint expected = 0xAA;
 3d2:	c7 45 e0 aa 00 00 00 	movl   $0xaa,-0x20(%ebp)
          if (pt_entries[i].encrypted)
 3d9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3df:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 3e4:	c0 e8 06             	shr    $0x6,%al
 3e7:	83 e0 01             	and    $0x1,%eax
 3ea:	84 c0                	test   %al,%al
 3ec:	74 07                	je     3f5 <main+0x386>
            expected = ~0xAA;
 3ee:	c7 45 e0 55 ff ff ff 	movl   $0xffffff55,-0x20(%ebp)

          if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
 3f5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3fb:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 3ff:	25 ff ff 0f 00       	and    $0xfffff,%eax
 404:	c1 e0 0c             	shl    $0xc,%eax
 407:	83 ec 08             	sub    $0x8,%esp
 40a:	ff 75 b4             	pushl  -0x4c(%ebp)
 40d:	50                   	push   %eax
 40e:	e8 02 04 00 00       	call   815 <dump_rawphymem>
 413:	83 c4 10             	add    $0x10,%esp
 416:	85 c0                	test   %eax,%eax
 418:	74 10                	je     42a <main+0x3bb>
              err("dump_rawphymem return non-zero value\n");
 41a:	83 ec 0c             	sub    $0xc,%esp
 41d:	68 a0 0d 00 00       	push   $0xda0
 422:	e8 d9 fb ff ff       	call   0 <err>
 427:	83 c4 10             	add    $0x10,%esp
          
          for (int j = 0; j < PGSIZE; j++) {
 42a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 431:	eb 7e                	jmp    4b1 <main+0x442>
              if (buffer[j] != (char)expected) {
 433:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 436:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 439:	01 d0                	add    %edx,%eax
 43b:	0f b6 00             	movzbl (%eax),%eax
 43e:	8b 55 e0             	mov    -0x20(%ebp),%edx
 441:	38 d0                	cmp    %dl,%al
 443:	74 68                	je     4ad <main+0x43e>
                  // err("physical memory is dumped incorrectly\n");
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j ,expected & 0xFF, buffer[j] & 0xFF);
 445:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 448:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 44b:	01 d0                	add    %edx,%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	0f be c0             	movsbl %al,%eax
 453:	0f b6 d0             	movzbl %al,%edx
 456:	8b 45 e0             	mov    -0x20(%ebp),%eax
 459:	0f b6 c0             	movzbl %al,%eax
 45c:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
 45f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 462:	0f b7 0c d9          	movzwl (%ecx,%ebx,8),%ecx
 466:	66 81 e1 ff 03       	and    $0x3ff,%cx
 46b:	0f b7 c9             	movzwl %cx,%ecx
 46e:	89 ce                	mov    %ecx,%esi
 470:	c1 e6 16             	shl    $0x16,%esi
 473:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
 476:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 479:	8b 0c d9             	mov    (%ecx,%ebx,8),%ecx
 47c:	c1 e9 0a             	shr    $0xa,%ecx
 47f:	66 81 e1 ff 03       	and    $0x3ff,%cx
 484:	0f b7 c9             	movzwl %cx,%ecx
 487:	c1 e1 0c             	shl    $0xc,%ecx
 48a:	89 f3                	mov    %esi,%ebx
 48c:	09 cb                	or     %ecx,%ebx
 48e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 491:	01 d9                	add    %ebx,%ecx
 493:	83 ec 0c             	sub    $0xc,%esp
 496:	52                   	push   %edx
 497:	50                   	push   %eax
 498:	51                   	push   %ecx
 499:	68 c8 0d 00 00       	push   $0xdc8
 49e:	6a 01                	push   $0x1
 4a0:	e8 54 04 00 00       	call   8f9 <printf>
 4a5:	83 c4 20             	add    $0x20,%esp
                    exit();
 4a8:	e8 b8 02 00 00       	call   765 <exit>
          for (int j = 0; j < PGSIZE; j++) {
 4ad:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 4b1:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 4b8:	0f 8e 75 ff ff ff    	jle    433 <main+0x3c4>
      for (int i = 0; i < retval; i++) {
 4be:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 4c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
 4c5:	3b 45 90             	cmp    -0x70(%ebp),%eax
 4c8:	0f 8c 90 fe ff ff    	jl     35e <main+0x2ef>
 4ce:	eb 15                	jmp    4e5 <main+0x476>
              }
          }

      }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", heap_pages_num, retval);
 4d0:	ff 75 90             	pushl  -0x70(%ebp)
 4d3:	ff 75 9c             	pushl  -0x64(%ebp)
 4d6:	68 18 0e 00 00       	push   $0xe18
 4db:	6a 01                	push   $0x1
 4dd:	e8 17 04 00 00       	call   8f9 <printf>
 4e2:	83 c4 10             	add    $0x10,%esp
    
    exit();
 4e5:	e8 7b 02 00 00       	call   765 <exit>

000004ea <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4ea:	55                   	push   %ebp
 4eb:	89 e5                	mov    %esp,%ebp
 4ed:	57                   	push   %edi
 4ee:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4f2:	8b 55 10             	mov    0x10(%ebp),%edx
 4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f8:	89 cb                	mov    %ecx,%ebx
 4fa:	89 df                	mov    %ebx,%edi
 4fc:	89 d1                	mov    %edx,%ecx
 4fe:	fc                   	cld    
 4ff:	f3 aa                	rep stos %al,%es:(%edi)
 501:	89 ca                	mov    %ecx,%edx
 503:	89 fb                	mov    %edi,%ebx
 505:	89 5d 08             	mov    %ebx,0x8(%ebp)
 508:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 50b:	90                   	nop
 50c:	5b                   	pop    %ebx
 50d:	5f                   	pop    %edi
 50e:	5d                   	pop    %ebp
 50f:	c3                   	ret    

00000510 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 510:	f3 0f 1e fb          	endbr32 
 514:	55                   	push   %ebp
 515:	89 e5                	mov    %esp,%ebp
 517:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
 51d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 520:	90                   	nop
 521:	8b 55 0c             	mov    0xc(%ebp),%edx
 524:	8d 42 01             	lea    0x1(%edx),%eax
 527:	89 45 0c             	mov    %eax,0xc(%ebp)
 52a:	8b 45 08             	mov    0x8(%ebp),%eax
 52d:	8d 48 01             	lea    0x1(%eax),%ecx
 530:	89 4d 08             	mov    %ecx,0x8(%ebp)
 533:	0f b6 12             	movzbl (%edx),%edx
 536:	88 10                	mov    %dl,(%eax)
 538:	0f b6 00             	movzbl (%eax),%eax
 53b:	84 c0                	test   %al,%al
 53d:	75 e2                	jne    521 <strcpy+0x11>
    ;
  return os;
 53f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 542:	c9                   	leave  
 543:	c3                   	ret    

00000544 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 544:	f3 0f 1e fb          	endbr32 
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 54b:	eb 08                	jmp    555 <strcmp+0x11>
    p++, q++;
 54d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 551:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	84 c0                	test   %al,%al
 55d:	74 10                	je     56f <strcmp+0x2b>
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 10             	movzbl (%eax),%edx
 565:	8b 45 0c             	mov    0xc(%ebp),%eax
 568:	0f b6 00             	movzbl (%eax),%eax
 56b:	38 c2                	cmp    %al,%dl
 56d:	74 de                	je     54d <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	0f b6 00             	movzbl (%eax),%eax
 575:	0f b6 d0             	movzbl %al,%edx
 578:	8b 45 0c             	mov    0xc(%ebp),%eax
 57b:	0f b6 00             	movzbl (%eax),%eax
 57e:	0f b6 c0             	movzbl %al,%eax
 581:	29 c2                	sub    %eax,%edx
 583:	89 d0                	mov    %edx,%eax
}
 585:	5d                   	pop    %ebp
 586:	c3                   	ret    

00000587 <strlen>:

uint
strlen(const char *s)
{
 587:	f3 0f 1e fb          	endbr32 
 58b:	55                   	push   %ebp
 58c:	89 e5                	mov    %esp,%ebp
 58e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 591:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 598:	eb 04                	jmp    59e <strlen+0x17>
 59a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 59e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	01 d0                	add    %edx,%eax
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	84 c0                	test   %al,%al
 5ab:	75 ed                	jne    59a <strlen+0x13>
    ;
  return n;
 5ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5b0:	c9                   	leave  
 5b1:	c3                   	ret    

000005b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5b2:	f3 0f 1e fb          	endbr32 
 5b6:	55                   	push   %ebp
 5b7:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 5b9:	8b 45 10             	mov    0x10(%ebp),%eax
 5bc:	50                   	push   %eax
 5bd:	ff 75 0c             	pushl  0xc(%ebp)
 5c0:	ff 75 08             	pushl  0x8(%ebp)
 5c3:	e8 22 ff ff ff       	call   4ea <stosb>
 5c8:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ce:	c9                   	leave  
 5cf:	c3                   	ret    

000005d0 <strchr>:

char*
strchr(const char *s, char c)
{
 5d0:	f3 0f 1e fb          	endbr32 
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	83 ec 04             	sub    $0x4,%esp
 5da:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5e0:	eb 14                	jmp    5f6 <strchr+0x26>
    if(*s == c)
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	0f b6 00             	movzbl (%eax),%eax
 5e8:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5eb:	75 05                	jne    5f2 <strchr+0x22>
      return (char*)s;
 5ed:	8b 45 08             	mov    0x8(%ebp),%eax
 5f0:	eb 13                	jmp    605 <strchr+0x35>
  for(; *s; s++)
 5f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	84 c0                	test   %al,%al
 5fe:	75 e2                	jne    5e2 <strchr+0x12>
  return 0;
 600:	b8 00 00 00 00       	mov    $0x0,%eax
}
 605:	c9                   	leave  
 606:	c3                   	ret    

00000607 <gets>:

char*
gets(char *buf, int max)
{
 607:	f3 0f 1e fb          	endbr32 
 60b:	55                   	push   %ebp
 60c:	89 e5                	mov    %esp,%ebp
 60e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 611:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 618:	eb 42                	jmp    65c <gets+0x55>
    cc = read(0, &c, 1);
 61a:	83 ec 04             	sub    $0x4,%esp
 61d:	6a 01                	push   $0x1
 61f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 622:	50                   	push   %eax
 623:	6a 00                	push   $0x0
 625:	e8 53 01 00 00       	call   77d <read>
 62a:	83 c4 10             	add    $0x10,%esp
 62d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 630:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 634:	7e 33                	jle    669 <gets+0x62>
      break;
    buf[i++] = c;
 636:	8b 45 f4             	mov    -0xc(%ebp),%eax
 639:	8d 50 01             	lea    0x1(%eax),%edx
 63c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 63f:	89 c2                	mov    %eax,%edx
 641:	8b 45 08             	mov    0x8(%ebp),%eax
 644:	01 c2                	add    %eax,%edx
 646:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 64a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 64c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 650:	3c 0a                	cmp    $0xa,%al
 652:	74 16                	je     66a <gets+0x63>
 654:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 658:	3c 0d                	cmp    $0xd,%al
 65a:	74 0e                	je     66a <gets+0x63>
  for(i=0; i+1 < max; ){
 65c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65f:	83 c0 01             	add    $0x1,%eax
 662:	39 45 0c             	cmp    %eax,0xc(%ebp)
 665:	7f b3                	jg     61a <gets+0x13>
 667:	eb 01                	jmp    66a <gets+0x63>
      break;
 669:	90                   	nop
      break;
  }
  buf[i] = '\0';
 66a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 66d:	8b 45 08             	mov    0x8(%ebp),%eax
 670:	01 d0                	add    %edx,%eax
 672:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 675:	8b 45 08             	mov    0x8(%ebp),%eax
}
 678:	c9                   	leave  
 679:	c3                   	ret    

0000067a <stat>:

int
stat(const char *n, struct stat *st)
{
 67a:	f3 0f 1e fb          	endbr32 
 67e:	55                   	push   %ebp
 67f:	89 e5                	mov    %esp,%ebp
 681:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 684:	83 ec 08             	sub    $0x8,%esp
 687:	6a 00                	push   $0x0
 689:	ff 75 08             	pushl  0x8(%ebp)
 68c:	e8 14 01 00 00       	call   7a5 <open>
 691:	83 c4 10             	add    $0x10,%esp
 694:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 697:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69b:	79 07                	jns    6a4 <stat+0x2a>
    return -1;
 69d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6a2:	eb 25                	jmp    6c9 <stat+0x4f>
  r = fstat(fd, st);
 6a4:	83 ec 08             	sub    $0x8,%esp
 6a7:	ff 75 0c             	pushl  0xc(%ebp)
 6aa:	ff 75 f4             	pushl  -0xc(%ebp)
 6ad:	e8 0b 01 00 00       	call   7bd <fstat>
 6b2:	83 c4 10             	add    $0x10,%esp
 6b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6b8:	83 ec 0c             	sub    $0xc,%esp
 6bb:	ff 75 f4             	pushl  -0xc(%ebp)
 6be:	e8 ca 00 00 00       	call   78d <close>
 6c3:	83 c4 10             	add    $0x10,%esp
  return r;
 6c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6c9:	c9                   	leave  
 6ca:	c3                   	ret    

000006cb <atoi>:

int
atoi(const char *s)
{
 6cb:	f3 0f 1e fb          	endbr32 
 6cf:	55                   	push   %ebp
 6d0:	89 e5                	mov    %esp,%ebp
 6d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6dc:	eb 25                	jmp    703 <atoi+0x38>
    n = n*10 + *s++ - '0';
 6de:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6e1:	89 d0                	mov    %edx,%eax
 6e3:	c1 e0 02             	shl    $0x2,%eax
 6e6:	01 d0                	add    %edx,%eax
 6e8:	01 c0                	add    %eax,%eax
 6ea:	89 c1                	mov    %eax,%ecx
 6ec:	8b 45 08             	mov    0x8(%ebp),%eax
 6ef:	8d 50 01             	lea    0x1(%eax),%edx
 6f2:	89 55 08             	mov    %edx,0x8(%ebp)
 6f5:	0f b6 00             	movzbl (%eax),%eax
 6f8:	0f be c0             	movsbl %al,%eax
 6fb:	01 c8                	add    %ecx,%eax
 6fd:	83 e8 30             	sub    $0x30,%eax
 700:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	0f b6 00             	movzbl (%eax),%eax
 709:	3c 2f                	cmp    $0x2f,%al
 70b:	7e 0a                	jle    717 <atoi+0x4c>
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	0f b6 00             	movzbl (%eax),%eax
 713:	3c 39                	cmp    $0x39,%al
 715:	7e c7                	jle    6de <atoi+0x13>
  return n;
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 71a:	c9                   	leave  
 71b:	c3                   	ret    

0000071c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 71c:	f3 0f 1e fb          	endbr32 
 720:	55                   	push   %ebp
 721:	89 e5                	mov    %esp,%ebp
 723:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 72c:	8b 45 0c             	mov    0xc(%ebp),%eax
 72f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 732:	eb 17                	jmp    74b <memmove+0x2f>
    *dst++ = *src++;
 734:	8b 55 f8             	mov    -0x8(%ebp),%edx
 737:	8d 42 01             	lea    0x1(%edx),%eax
 73a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8d 48 01             	lea    0x1(%eax),%ecx
 743:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 746:	0f b6 12             	movzbl (%edx),%edx
 749:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 74b:	8b 45 10             	mov    0x10(%ebp),%eax
 74e:	8d 50 ff             	lea    -0x1(%eax),%edx
 751:	89 55 10             	mov    %edx,0x10(%ebp)
 754:	85 c0                	test   %eax,%eax
 756:	7f dc                	jg     734 <memmove+0x18>
  return vdst;
 758:	8b 45 08             	mov    0x8(%ebp),%eax
}
 75b:	c9                   	leave  
 75c:	c3                   	ret    

0000075d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 75d:	b8 01 00 00 00       	mov    $0x1,%eax
 762:	cd 40                	int    $0x40
 764:	c3                   	ret    

00000765 <exit>:
SYSCALL(exit)
 765:	b8 02 00 00 00       	mov    $0x2,%eax
 76a:	cd 40                	int    $0x40
 76c:	c3                   	ret    

0000076d <wait>:
SYSCALL(wait)
 76d:	b8 03 00 00 00       	mov    $0x3,%eax
 772:	cd 40                	int    $0x40
 774:	c3                   	ret    

00000775 <pipe>:
SYSCALL(pipe)
 775:	b8 04 00 00 00       	mov    $0x4,%eax
 77a:	cd 40                	int    $0x40
 77c:	c3                   	ret    

0000077d <read>:
SYSCALL(read)
 77d:	b8 05 00 00 00       	mov    $0x5,%eax
 782:	cd 40                	int    $0x40
 784:	c3                   	ret    

00000785 <write>:
SYSCALL(write)
 785:	b8 10 00 00 00       	mov    $0x10,%eax
 78a:	cd 40                	int    $0x40
 78c:	c3                   	ret    

0000078d <close>:
SYSCALL(close)
 78d:	b8 15 00 00 00       	mov    $0x15,%eax
 792:	cd 40                	int    $0x40
 794:	c3                   	ret    

00000795 <kill>:
SYSCALL(kill)
 795:	b8 06 00 00 00       	mov    $0x6,%eax
 79a:	cd 40                	int    $0x40
 79c:	c3                   	ret    

0000079d <exec>:
SYSCALL(exec)
 79d:	b8 07 00 00 00       	mov    $0x7,%eax
 7a2:	cd 40                	int    $0x40
 7a4:	c3                   	ret    

000007a5 <open>:
SYSCALL(open)
 7a5:	b8 0f 00 00 00       	mov    $0xf,%eax
 7aa:	cd 40                	int    $0x40
 7ac:	c3                   	ret    

000007ad <mknod>:
SYSCALL(mknod)
 7ad:	b8 11 00 00 00       	mov    $0x11,%eax
 7b2:	cd 40                	int    $0x40
 7b4:	c3                   	ret    

000007b5 <unlink>:
SYSCALL(unlink)
 7b5:	b8 12 00 00 00       	mov    $0x12,%eax
 7ba:	cd 40                	int    $0x40
 7bc:	c3                   	ret    

000007bd <fstat>:
SYSCALL(fstat)
 7bd:	b8 08 00 00 00       	mov    $0x8,%eax
 7c2:	cd 40                	int    $0x40
 7c4:	c3                   	ret    

000007c5 <link>:
SYSCALL(link)
 7c5:	b8 13 00 00 00       	mov    $0x13,%eax
 7ca:	cd 40                	int    $0x40
 7cc:	c3                   	ret    

000007cd <mkdir>:
SYSCALL(mkdir)
 7cd:	b8 14 00 00 00       	mov    $0x14,%eax
 7d2:	cd 40                	int    $0x40
 7d4:	c3                   	ret    

000007d5 <chdir>:
SYSCALL(chdir)
 7d5:	b8 09 00 00 00       	mov    $0x9,%eax
 7da:	cd 40                	int    $0x40
 7dc:	c3                   	ret    

000007dd <dup>:
SYSCALL(dup)
 7dd:	b8 0a 00 00 00       	mov    $0xa,%eax
 7e2:	cd 40                	int    $0x40
 7e4:	c3                   	ret    

000007e5 <getpid>:
SYSCALL(getpid)
 7e5:	b8 0b 00 00 00       	mov    $0xb,%eax
 7ea:	cd 40                	int    $0x40
 7ec:	c3                   	ret    

000007ed <sbrk>:
SYSCALL(sbrk)
 7ed:	b8 0c 00 00 00       	mov    $0xc,%eax
 7f2:	cd 40                	int    $0x40
 7f4:	c3                   	ret    

000007f5 <sleep>:
SYSCALL(sleep)
 7f5:	b8 0d 00 00 00       	mov    $0xd,%eax
 7fa:	cd 40                	int    $0x40
 7fc:	c3                   	ret    

000007fd <uptime>:
SYSCALL(uptime)
 7fd:	b8 0e 00 00 00       	mov    $0xe,%eax
 802:	cd 40                	int    $0x40
 804:	c3                   	ret    

00000805 <mencrypt>:
SYSCALL(mencrypt)
 805:	b8 16 00 00 00       	mov    $0x16,%eax
 80a:	cd 40                	int    $0x40
 80c:	c3                   	ret    

0000080d <getpgtable>:
SYSCALL(getpgtable)
 80d:	b8 17 00 00 00       	mov    $0x17,%eax
 812:	cd 40                	int    $0x40
 814:	c3                   	ret    

00000815 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 815:	b8 18 00 00 00       	mov    $0x18,%eax
 81a:	cd 40                	int    $0x40
 81c:	c3                   	ret    

0000081d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 81d:	f3 0f 1e fb          	endbr32 
 821:	55                   	push   %ebp
 822:	89 e5                	mov    %esp,%ebp
 824:	83 ec 18             	sub    $0x18,%esp
 827:	8b 45 0c             	mov    0xc(%ebp),%eax
 82a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 82d:	83 ec 04             	sub    $0x4,%esp
 830:	6a 01                	push   $0x1
 832:	8d 45 f4             	lea    -0xc(%ebp),%eax
 835:	50                   	push   %eax
 836:	ff 75 08             	pushl  0x8(%ebp)
 839:	e8 47 ff ff ff       	call   785 <write>
 83e:	83 c4 10             	add    $0x10,%esp
}
 841:	90                   	nop
 842:	c9                   	leave  
 843:	c3                   	ret    

00000844 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 844:	f3 0f 1e fb          	endbr32 
 848:	55                   	push   %ebp
 849:	89 e5                	mov    %esp,%ebp
 84b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 84e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 855:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 859:	74 17                	je     872 <printint+0x2e>
 85b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 85f:	79 11                	jns    872 <printint+0x2e>
    neg = 1;
 861:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 868:	8b 45 0c             	mov    0xc(%ebp),%eax
 86b:	f7 d8                	neg    %eax
 86d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 870:	eb 06                	jmp    878 <printint+0x34>
  } else {
    x = xx;
 872:	8b 45 0c             	mov    0xc(%ebp),%eax
 875:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 87f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 882:	8b 45 ec             	mov    -0x14(%ebp),%eax
 885:	ba 00 00 00 00       	mov    $0x0,%edx
 88a:	f7 f1                	div    %ecx
 88c:	89 d1                	mov    %edx,%ecx
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	8d 50 01             	lea    0x1(%eax),%edx
 894:	89 55 f4             	mov    %edx,-0xc(%ebp)
 897:	0f b6 91 f8 10 00 00 	movzbl 0x10f8(%ecx),%edx
 89e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a8:	ba 00 00 00 00       	mov    $0x0,%edx
 8ad:	f7 f1                	div    %ecx
 8af:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8b6:	75 c7                	jne    87f <printint+0x3b>
  if(neg)
 8b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8bc:	74 2d                	je     8eb <printint+0xa7>
    buf[i++] = '-';
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	8d 50 01             	lea    0x1(%eax),%edx
 8c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8c7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8cc:	eb 1d                	jmp    8eb <printint+0xa7>
    putc(fd, buf[i]);
 8ce:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d4:	01 d0                	add    %edx,%eax
 8d6:	0f b6 00             	movzbl (%eax),%eax
 8d9:	0f be c0             	movsbl %al,%eax
 8dc:	83 ec 08             	sub    $0x8,%esp
 8df:	50                   	push   %eax
 8e0:	ff 75 08             	pushl  0x8(%ebp)
 8e3:	e8 35 ff ff ff       	call   81d <putc>
 8e8:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 8eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8f3:	79 d9                	jns    8ce <printint+0x8a>
}
 8f5:	90                   	nop
 8f6:	90                   	nop
 8f7:	c9                   	leave  
 8f8:	c3                   	ret    

000008f9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 8f9:	f3 0f 1e fb          	endbr32 
 8fd:	55                   	push   %ebp
 8fe:	89 e5                	mov    %esp,%ebp
 900:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 903:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 90a:	8d 45 0c             	lea    0xc(%ebp),%eax
 90d:	83 c0 04             	add    $0x4,%eax
 910:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 913:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 91a:	e9 59 01 00 00       	jmp    a78 <printf+0x17f>
    c = fmt[i] & 0xff;
 91f:	8b 55 0c             	mov    0xc(%ebp),%edx
 922:	8b 45 f0             	mov    -0x10(%ebp),%eax
 925:	01 d0                	add    %edx,%eax
 927:	0f b6 00             	movzbl (%eax),%eax
 92a:	0f be c0             	movsbl %al,%eax
 92d:	25 ff 00 00 00       	and    $0xff,%eax
 932:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 935:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 939:	75 2c                	jne    967 <printf+0x6e>
      if(c == '%'){
 93b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 93f:	75 0c                	jne    94d <printf+0x54>
        state = '%';
 941:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 948:	e9 27 01 00 00       	jmp    a74 <printf+0x17b>
      } else {
        putc(fd, c);
 94d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 950:	0f be c0             	movsbl %al,%eax
 953:	83 ec 08             	sub    $0x8,%esp
 956:	50                   	push   %eax
 957:	ff 75 08             	pushl  0x8(%ebp)
 95a:	e8 be fe ff ff       	call   81d <putc>
 95f:	83 c4 10             	add    $0x10,%esp
 962:	e9 0d 01 00 00       	jmp    a74 <printf+0x17b>
      }
    } else if(state == '%'){
 967:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 96b:	0f 85 03 01 00 00    	jne    a74 <printf+0x17b>
      if(c == 'd'){
 971:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 975:	75 1e                	jne    995 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 977:	8b 45 e8             	mov    -0x18(%ebp),%eax
 97a:	8b 00                	mov    (%eax),%eax
 97c:	6a 01                	push   $0x1
 97e:	6a 0a                	push   $0xa
 980:	50                   	push   %eax
 981:	ff 75 08             	pushl  0x8(%ebp)
 984:	e8 bb fe ff ff       	call   844 <printint>
 989:	83 c4 10             	add    $0x10,%esp
        ap++;
 98c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 990:	e9 d8 00 00 00       	jmp    a6d <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 995:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 999:	74 06                	je     9a1 <printf+0xa8>
 99b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 99f:	75 1e                	jne    9bf <printf+0xc6>
        printint(fd, *ap, 16, 0);
 9a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9a4:	8b 00                	mov    (%eax),%eax
 9a6:	6a 00                	push   $0x0
 9a8:	6a 10                	push   $0x10
 9aa:	50                   	push   %eax
 9ab:	ff 75 08             	pushl  0x8(%ebp)
 9ae:	e8 91 fe ff ff       	call   844 <printint>
 9b3:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ba:	e9 ae 00 00 00       	jmp    a6d <printf+0x174>
      } else if(c == 's'){
 9bf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9c3:	75 43                	jne    a08 <printf+0x10f>
        s = (char*)*ap;
 9c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c8:	8b 00                	mov    (%eax),%eax
 9ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d5:	75 25                	jne    9fc <printf+0x103>
          s = "(null)";
 9d7:	c7 45 f4 63 0e 00 00 	movl   $0xe63,-0xc(%ebp)
        while(*s != 0){
 9de:	eb 1c                	jmp    9fc <printf+0x103>
          putc(fd, *s);
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	0f b6 00             	movzbl (%eax),%eax
 9e6:	0f be c0             	movsbl %al,%eax
 9e9:	83 ec 08             	sub    $0x8,%esp
 9ec:	50                   	push   %eax
 9ed:	ff 75 08             	pushl  0x8(%ebp)
 9f0:	e8 28 fe ff ff       	call   81d <putc>
 9f5:	83 c4 10             	add    $0x10,%esp
          s++;
 9f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	0f b6 00             	movzbl (%eax),%eax
 a02:	84 c0                	test   %al,%al
 a04:	75 da                	jne    9e0 <printf+0xe7>
 a06:	eb 65                	jmp    a6d <printf+0x174>
        }
      } else if(c == 'c'){
 a08:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a0c:	75 1d                	jne    a2b <printf+0x132>
        putc(fd, *ap);
 a0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a11:	8b 00                	mov    (%eax),%eax
 a13:	0f be c0             	movsbl %al,%eax
 a16:	83 ec 08             	sub    $0x8,%esp
 a19:	50                   	push   %eax
 a1a:	ff 75 08             	pushl  0x8(%ebp)
 a1d:	e8 fb fd ff ff       	call   81d <putc>
 a22:	83 c4 10             	add    $0x10,%esp
        ap++;
 a25:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a29:	eb 42                	jmp    a6d <printf+0x174>
      } else if(c == '%'){
 a2b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a2f:	75 17                	jne    a48 <printf+0x14f>
        putc(fd, c);
 a31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a34:	0f be c0             	movsbl %al,%eax
 a37:	83 ec 08             	sub    $0x8,%esp
 a3a:	50                   	push   %eax
 a3b:	ff 75 08             	pushl  0x8(%ebp)
 a3e:	e8 da fd ff ff       	call   81d <putc>
 a43:	83 c4 10             	add    $0x10,%esp
 a46:	eb 25                	jmp    a6d <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a48:	83 ec 08             	sub    $0x8,%esp
 a4b:	6a 25                	push   $0x25
 a4d:	ff 75 08             	pushl  0x8(%ebp)
 a50:	e8 c8 fd ff ff       	call   81d <putc>
 a55:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a5b:	0f be c0             	movsbl %al,%eax
 a5e:	83 ec 08             	sub    $0x8,%esp
 a61:	50                   	push   %eax
 a62:	ff 75 08             	pushl  0x8(%ebp)
 a65:	e8 b3 fd ff ff       	call   81d <putc>
 a6a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a74:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a78:	8b 55 0c             	mov    0xc(%ebp),%edx
 a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7e:	01 d0                	add    %edx,%eax
 a80:	0f b6 00             	movzbl (%eax),%eax
 a83:	84 c0                	test   %al,%al
 a85:	0f 85 94 fe ff ff    	jne    91f <printf+0x26>
    }
  }
}
 a8b:	90                   	nop
 a8c:	90                   	nop
 a8d:	c9                   	leave  
 a8e:	c3                   	ret    

00000a8f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a8f:	f3 0f 1e fb          	endbr32 
 a93:	55                   	push   %ebp
 a94:	89 e5                	mov    %esp,%ebp
 a96:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a99:	8b 45 08             	mov    0x8(%ebp),%eax
 a9c:	83 e8 08             	sub    $0x8,%eax
 a9f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aa2:	a1 14 11 00 00       	mov    0x1114,%eax
 aa7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aaa:	eb 24                	jmp    ad0 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aaf:	8b 00                	mov    (%eax),%eax
 ab1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 ab4:	72 12                	jb     ac8 <free+0x39>
 ab6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 abc:	77 24                	ja     ae2 <free+0x53>
 abe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac1:	8b 00                	mov    (%eax),%eax
 ac3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ac6:	72 1a                	jb     ae2 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 acb:	8b 00                	mov    (%eax),%eax
 acd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ad0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ad6:	76 d4                	jbe    aac <free+0x1d>
 ad8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 adb:	8b 00                	mov    (%eax),%eax
 add:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ae0:	73 ca                	jae    aac <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ae2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae5:	8b 40 04             	mov    0x4(%eax),%eax
 ae8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 aef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af2:	01 c2                	add    %eax,%edx
 af4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af7:	8b 00                	mov    (%eax),%eax
 af9:	39 c2                	cmp    %eax,%edx
 afb:	75 24                	jne    b21 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 afd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b00:	8b 50 04             	mov    0x4(%eax),%edx
 b03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b06:	8b 00                	mov    (%eax),%eax
 b08:	8b 40 04             	mov    0x4(%eax),%eax
 b0b:	01 c2                	add    %eax,%edx
 b0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b10:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b13:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b16:	8b 00                	mov    (%eax),%eax
 b18:	8b 10                	mov    (%eax),%edx
 b1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1d:	89 10                	mov    %edx,(%eax)
 b1f:	eb 0a                	jmp    b2b <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 b21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b24:	8b 10                	mov    (%eax),%edx
 b26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b29:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2e:	8b 40 04             	mov    0x4(%eax),%eax
 b31:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3b:	01 d0                	add    %edx,%eax
 b3d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b40:	75 20                	jne    b62 <free+0xd3>
    p->s.size += bp->s.size;
 b42:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b45:	8b 50 04             	mov    0x4(%eax),%edx
 b48:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4b:	8b 40 04             	mov    0x4(%eax),%eax
 b4e:	01 c2                	add    %eax,%edx
 b50:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b53:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b56:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b59:	8b 10                	mov    (%eax),%edx
 b5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5e:	89 10                	mov    %edx,(%eax)
 b60:	eb 08                	jmp    b6a <free+0xdb>
  } else
    p->s.ptr = bp;
 b62:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b65:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b68:	89 10                	mov    %edx,(%eax)
  freep = p;
 b6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b6d:	a3 14 11 00 00       	mov    %eax,0x1114
}
 b72:	90                   	nop
 b73:	c9                   	leave  
 b74:	c3                   	ret    

00000b75 <morecore>:

static Header*
morecore(uint nu)
{
 b75:	f3 0f 1e fb          	endbr32 
 b79:	55                   	push   %ebp
 b7a:	89 e5                	mov    %esp,%ebp
 b7c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b7f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b86:	77 07                	ja     b8f <morecore+0x1a>
    nu = 4096;
 b88:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b8f:	8b 45 08             	mov    0x8(%ebp),%eax
 b92:	c1 e0 03             	shl    $0x3,%eax
 b95:	83 ec 0c             	sub    $0xc,%esp
 b98:	50                   	push   %eax
 b99:	e8 4f fc ff ff       	call   7ed <sbrk>
 b9e:	83 c4 10             	add    $0x10,%esp
 ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ba4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ba8:	75 07                	jne    bb1 <morecore+0x3c>
    return 0;
 baa:	b8 00 00 00 00       	mov    $0x0,%eax
 baf:	eb 26                	jmp    bd7 <morecore+0x62>
  hp = (Header*)p;
 bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bba:	8b 55 08             	mov    0x8(%ebp),%edx
 bbd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc3:	83 c0 08             	add    $0x8,%eax
 bc6:	83 ec 0c             	sub    $0xc,%esp
 bc9:	50                   	push   %eax
 bca:	e8 c0 fe ff ff       	call   a8f <free>
 bcf:	83 c4 10             	add    $0x10,%esp
  return freep;
 bd2:	a1 14 11 00 00       	mov    0x1114,%eax
}
 bd7:	c9                   	leave  
 bd8:	c3                   	ret    

00000bd9 <malloc>:

void*
malloc(uint nbytes)
{
 bd9:	f3 0f 1e fb          	endbr32 
 bdd:	55                   	push   %ebp
 bde:	89 e5                	mov    %esp,%ebp
 be0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 be3:	8b 45 08             	mov    0x8(%ebp),%eax
 be6:	83 c0 07             	add    $0x7,%eax
 be9:	c1 e8 03             	shr    $0x3,%eax
 bec:	83 c0 01             	add    $0x1,%eax
 bef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bf2:	a1 14 11 00 00       	mov    0x1114,%eax
 bf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bfa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bfe:	75 23                	jne    c23 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 c00:	c7 45 f0 0c 11 00 00 	movl   $0x110c,-0x10(%ebp)
 c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c0a:	a3 14 11 00 00       	mov    %eax,0x1114
 c0f:	a1 14 11 00 00       	mov    0x1114,%eax
 c14:	a3 0c 11 00 00       	mov    %eax,0x110c
    base.s.size = 0;
 c19:	c7 05 10 11 00 00 00 	movl   $0x0,0x1110
 c20:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c26:	8b 00                	mov    (%eax),%eax
 c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2e:	8b 40 04             	mov    0x4(%eax),%eax
 c31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c34:	77 4d                	ja     c83 <malloc+0xaa>
      if(p->s.size == nunits)
 c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c39:	8b 40 04             	mov    0x4(%eax),%eax
 c3c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c3f:	75 0c                	jne    c4d <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c44:	8b 10                	mov    (%eax),%edx
 c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c49:	89 10                	mov    %edx,(%eax)
 c4b:	eb 26                	jmp    c73 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c50:	8b 40 04             	mov    0x4(%eax),%eax
 c53:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c56:	89 c2                	mov    %eax,%edx
 c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c61:	8b 40 04             	mov    0x4(%eax),%eax
 c64:	c1 e0 03             	shl    $0x3,%eax
 c67:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c70:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c76:	a3 14 11 00 00       	mov    %eax,0x1114
      return (void*)(p + 1);
 c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7e:	83 c0 08             	add    $0x8,%eax
 c81:	eb 3b                	jmp    cbe <malloc+0xe5>
    }
    if(p == freep)
 c83:	a1 14 11 00 00       	mov    0x1114,%eax
 c88:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c8b:	75 1e                	jne    cab <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c8d:	83 ec 0c             	sub    $0xc,%esp
 c90:	ff 75 ec             	pushl  -0x14(%ebp)
 c93:	e8 dd fe ff ff       	call   b75 <morecore>
 c98:	83 c4 10             	add    $0x10,%esp
 c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ca2:	75 07                	jne    cab <malloc+0xd2>
        return 0;
 ca4:	b8 00 00 00 00       	mov    $0x0,%eax
 ca9:	eb 13                	jmp    cbe <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb4:	8b 00                	mov    (%eax),%eax
 cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cb9:	e9 6d ff ff ff       	jmp    c2b <malloc+0x52>
  }
}
 cbe:	c9                   	leave  
 cbf:	c3                   	ret    
