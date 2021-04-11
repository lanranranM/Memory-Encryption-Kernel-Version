
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 28 3a 10 80       	mov    $0x80103a28,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 48 8c 10 80       	push   $0x80108c48
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 d1 51 00 00       	call   80105221 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 4f 8c 10 80       	push   $0x80108c4f
80100094:	50                   	push   %eax
80100095:	e8 f4 4f 00 00       	call   8010508e <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 6b 51 00 00       	call   80105247 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 9e 51 00 00       	call   801052b9 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 a1 4f 00 00       	call   801050ce <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 1d 51 00 00       	call   801052b9 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 20 4f 00 00       	call   801050ce <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 56 8c 10 80       	push   $0x80108c56
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 a1 28 00 00       	call   80102aad <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 5b 4f 00 00       	call   80105188 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 67 8c 10 80       	push   $0x80108c67
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 52 28 00 00       	call   80102aad <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 0e 4f 00 00       	call   80105188 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 6e 8c 10 80       	push   $0x80108c6e
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 99 4e 00 00       	call   80105136 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 9a 4f 00 00       	call   80105247 <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 9c 4f 00 00       	call   801052b9 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 51 4f 00 00       	call   8010538e <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 f6 4d 00 00       	call   80105247 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 78 8c 10 80       	push   $0x80108c78
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 88 8c 10 80 	mov    -0x7fef7378(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 81 8c 10 80 	movl   $0x80108c81,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 b7 4c 00 00       	call   801052b9 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 53 2b 00 00       	call   80103179 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 e0 8c 10 80       	push   $0x80108ce0
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 f4 8c 10 80       	push   $0x80108cf4
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 a9 4c 00 00       	call   8010530f <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 f6 8c 10 80       	push   $0x80108cf6
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 fa 8c 10 80       	push   $0x80108cfa
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 09 4e 00 00       	call   801055ad <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 18 4d 00 00       	call   801054e6 <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 5f 67 00 00       	call   80106fc9 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 52 67 00 00       	call   80106fc9 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 45 67 00 00       	call   80106fc9 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 35 67 00 00       	call   80106fc9 <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 81 49 00 00       	call   80105247 <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 b1 44 00 00       	call   80104ecd <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 7a 48 00 00       	call   801052b9 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 43 45 00 00       	call   80104f90 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 ce 11 00 00       	call   80101c33 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 cc 47 00 00       	call   80105247 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 22 3a 00 00       	call   801044aa <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 1d 48 00 00       	call   801052b9 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 72 10 00 00       	call   80101b1c <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 15 43 00 00       	call   80104dde <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 72 47 00 00       	call   801052b9 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 c7 0f 00 00       	call   80101b1c <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 ba 10 00 00       	call   80101c33 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 be 46 00 00       	call   80105247 <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 ee 46 00 00       	call   801052b9 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 43 0f 00 00       	call   80101b1c <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 0d 8d 10 80       	push   $0x80108d0d
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 24 46 00 00       	call   80105221 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 5c 20 00 00       	call   80102c86 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 68 38 00 00       	call   801044aa <myproc>
80100c42:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c45:	e8 a1 2a 00 00       	call   801036eb <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 32 1a 00 00       	call   80102687 <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 15 2b 00 00       	call   8010377b <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 15 8d 10 80       	push   $0x80108d15
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 32 04 00 00       	jmp    801010b2 <exec+0x482>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 91 0e 00 00       	call   80101b1c <ilock>
80100c8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c95:	6a 34                	push   $0x34
80100c97:	6a 00                	push   $0x0
80100c99:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c9f:	50                   	push   %eax
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 7c 13 00 00       	call   80102024 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 a7 03 00 00    	jne    8010105b <exec+0x42b>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 99 03 00 00    	jne    8010105e <exec+0x42e>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 3b 73 00 00       	call   80108005 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 8a 03 00 00    	je     80101061 <exec+0x431>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce5:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100ceb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cee:	e9 de 00 00 00       	jmp    80100dd1 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf6:	6a 20                	push   $0x20
80100cf8:	50                   	push   %eax
80100cf9:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	pushl  -0x28(%ebp)
80100d03:	e8 1c 13 00 00       	call   80102024 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 50 03 00 00    	jne    80101064 <exec+0x434>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d14:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d1a:	83 f8 01             	cmp    $0x1,%eax
80100d1d:	0f 85 a0 00 00 00    	jne    80100dc3 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100d23:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d29:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d2f:	39 c2                	cmp    %eax,%edx
80100d31:	0f 82 30 03 00 00    	jb     80101067 <exec+0x437>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d3d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 17 03 00 00    	jb     8010106a <exec+0x43a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d59:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 53 76 00 00       	call   801083c3 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 ed 02 00 00    	je     8010106d <exec+0x43d>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 dd 02 00 00    	jne    80101070 <exec+0x440>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d93:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d99:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d9f:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100da5:	83 ec 0c             	sub    $0xc,%esp
80100da8:	52                   	push   %edx
80100da9:	50                   	push   %eax
80100daa:	ff 75 d8             	pushl  -0x28(%ebp)
80100dad:	51                   	push   %ecx
80100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db1:	e8 3c 75 00 00       	call   801082f2 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 b2 02 00 00    	js     80101073 <exec+0x443>
80100dc1:	eb 01                	jmp    80100dc4 <exec+0x194>
      continue;
80100dc3:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dc4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dcb:	83 c0 20             	add    $0x20,%eax
80100dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dd1:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100dd8:	0f b7 c0             	movzwl %ax,%eax
80100ddb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dde:	0f 8c 0f ff ff ff    	jl     80100cf3 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100de4:	83 ec 0c             	sub    $0xc,%esp
80100de7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dea:	e8 6a 0f 00 00       	call   80101d59 <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 84 29 00 00       	call   8010377b <end_op>
  ip = 0;
80100df7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e11:	05 00 20 00 00       	add    $0x2000,%eax
80100e16:	83 ec 04             	sub    $0x4,%esp
80100e19:	50                   	push   %eax
80100e1a:	ff 75 e0             	pushl  -0x20(%ebp)
80100e1d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e20:	e8 9e 75 00 00       	call   801083c3 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 41 02 00 00    	je     80101076 <exec+0x446>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 ea 77 00 00       	call   80108633 <clearpteu>
80100e49:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  //p5-melody-changes
  //int record_sz=sz;
  //ends
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e59:	e9 96 00 00 00       	jmp    80100ef4 <exec+0x2c4>
    if(argc >= MAXARG)
80100e5e:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e62:	0f 87 11 02 00 00    	ja     80101079 <exec+0x449>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 cd 48 00 00       	call   8010574f <strlen>
80100e82:	83 c4 10             	add    $0x10,%esp
80100e85:	89 c2                	mov    %eax,%edx
80100e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8a:	29 d0                	sub    %edx,%eax
80100e8c:	83 e8 01             	sub    $0x1,%eax
80100e8f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea2:	01 d0                	add    %edx,%eax
80100ea4:	8b 00                	mov    (%eax),%eax
80100ea6:	83 ec 0c             	sub    $0xc,%esp
80100ea9:	50                   	push   %eax
80100eaa:	e8 a0 48 00 00       	call   8010574f <strlen>
80100eaf:	83 c4 10             	add    $0x10,%esp
80100eb2:	83 c0 01             	add    $0x1,%eax
80100eb5:	89 c1                	mov    %eax,%ecx
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec4:	01 d0                	add    %edx,%eax
80100ec6:	8b 00                	mov    (%eax),%eax
80100ec8:	51                   	push   %ecx
80100ec9:	50                   	push   %eax
80100eca:	ff 75 dc             	pushl  -0x24(%ebp)
80100ecd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ed0:	e8 1a 79 00 00       	call   801087ef <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 9c 01 00 00    	js     8010107c <exec+0x44c>
      goto bad;
    ustack[3+argc] = sp;
80100ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee3:	8d 50 03             	lea    0x3(%eax),%edx
80100ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee9:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ef0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f01:	01 d0                	add    %edx,%eax
80100f03:	8b 00                	mov    (%eax),%eax
80100f05:	85 c0                	test   %eax,%eax
80100f07:	0f 85 51 ff ff ff    	jne    80100e5e <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	83 c0 03             	add    $0x3,%eax
80100f13:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100f1a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f1e:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100f25:	ff ff ff 
  ustack[1] = argc;
80100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2b:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f34:	83 c0 01             	add    $0x1,%eax
80100f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f41:	29 d0                	sub    %edx,%eax
80100f43:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4c:	83 c0 04             	add    $0x4,%eax
80100f4f:	c1 e0 02             	shl    $0x2,%eax
80100f52:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f58:	83 c0 04             	add    $0x4,%eax
80100f5b:	c1 e0 02             	shl    $0x2,%eax
80100f5e:	50                   	push   %eax
80100f5f:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100f65:	50                   	push   %eax
80100f66:	ff 75 dc             	pushl  -0x24(%ebp)
80100f69:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f6c:	e8 7e 78 00 00       	call   801087ef <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 03 01 00 00    	js     8010107f <exec+0x44f>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f88:	eb 17                	jmp    80100fa1 <exec+0x371>
    if(*s == '/')
80100f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8d:	0f b6 00             	movzbl (%eax),%eax
80100f90:	3c 2f                	cmp    $0x2f,%al
80100f92:	75 09                	jne    80100f9d <exec+0x36d>
      last = s+1;
80100f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f97:	83 c0 01             	add    $0x1,%eax
80100f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	0f b6 00             	movzbl (%eax),%eax
80100fa7:	84 c0                	test   %al,%al
80100fa9:	75 df                	jne    80100f8a <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fab:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fae:	83 c0 6c             	add    $0x6c,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 42 47 00 00       	call   80105701 <safestrcpy>
80100fbf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc5:	8b 40 04             	mov    0x4(%eax),%eax
80100fc8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fcb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd1:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fda:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fdc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fdf:	8b 40 18             	mov    0x18(%eax),%eax
80100fe2:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100fe8:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100feb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fee:	8b 40 18             	mov    0x18(%eax),%eax
80100ff1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ff4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	ff 75 d0             	pushl  -0x30(%ebp)
80100ffd:	e8 d9 70 00 00       	call   801080db <switchuvm>
80101002:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 cc             	pushl  -0x34(%ebp)
8010100b:	e8 86 75 00 00       	call   80108596 <freevm>
80101010:	83 c4 10             	add    $0x10,%esp
  //p5 melody changes
  uint page_num=1;
80101013:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  cprintf("exec-page_num:%d\n",page_num);
8010101a:	83 ec 08             	sub    $0x8,%esp
8010101d:	ff 75 c8             	pushl  -0x38(%ebp)
80101020:	68 21 8d 10 80       	push   $0x80108d21
80101025:	e8 ee f3 ff ff       	call   80100418 <cprintf>
8010102a:	83 c4 10             	add    $0x10,%esp
  if(mencrypt((char*)PGROUNDUP(sz-PGSIZE),page_num)!=0) return -1;
8010102d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101030:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101033:	83 ea 01             	sub    $0x1,%edx
80101036:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010103c:	83 ec 08             	sub    $0x8,%esp
8010103f:	50                   	push   %eax
80101040:	52                   	push   %edx
80101041:	e8 f1 78 00 00       	call   80108937 <mencrypt>
80101046:	83 c4 10             	add    $0x10,%esp
80101049:	85 c0                	test   %eax,%eax
8010104b:	74 07                	je     80101054 <exec+0x424>
8010104d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101052:	eb 5e                	jmp    801010b2 <exec+0x482>
  //ends
  return 0;
80101054:	b8 00 00 00 00       	mov    $0x0,%eax
80101059:	eb 57                	jmp    801010b2 <exec+0x482>
    goto bad;
8010105b:	90                   	nop
8010105c:	eb 22                	jmp    80101080 <exec+0x450>
    goto bad;
8010105e:	90                   	nop
8010105f:	eb 1f                	jmp    80101080 <exec+0x450>
    goto bad;
80101061:	90                   	nop
80101062:	eb 1c                	jmp    80101080 <exec+0x450>
      goto bad;
80101064:	90                   	nop
80101065:	eb 19                	jmp    80101080 <exec+0x450>
      goto bad;
80101067:	90                   	nop
80101068:	eb 16                	jmp    80101080 <exec+0x450>
      goto bad;
8010106a:	90                   	nop
8010106b:	eb 13                	jmp    80101080 <exec+0x450>
      goto bad;
8010106d:	90                   	nop
8010106e:	eb 10                	jmp    80101080 <exec+0x450>
      goto bad;
80101070:	90                   	nop
80101071:	eb 0d                	jmp    80101080 <exec+0x450>
      goto bad;
80101073:	90                   	nop
80101074:	eb 0a                	jmp    80101080 <exec+0x450>
    goto bad;
80101076:	90                   	nop
80101077:	eb 07                	jmp    80101080 <exec+0x450>
      goto bad;
80101079:	90                   	nop
8010107a:	eb 04                	jmp    80101080 <exec+0x450>
      goto bad;
8010107c:	90                   	nop
8010107d:	eb 01                	jmp    80101080 <exec+0x450>
    goto bad;
8010107f:	90                   	nop

 bad:
  if(pgdir)
80101080:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101084:	74 0e                	je     80101094 <exec+0x464>
    freevm(pgdir);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	ff 75 d4             	pushl  -0x2c(%ebp)
8010108c:	e8 05 75 00 00       	call   80108596 <freevm>
80101091:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101094:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101098:	74 13                	je     801010ad <exec+0x47d>
    iunlockput(ip);
8010109a:	83 ec 0c             	sub    $0xc,%esp
8010109d:	ff 75 d8             	pushl  -0x28(%ebp)
801010a0:	e8 b4 0c 00 00       	call   80101d59 <iunlockput>
801010a5:	83 c4 10             	add    $0x10,%esp
    end_op();
801010a8:	e8 ce 26 00 00       	call   8010377b <end_op>
  }
  return -1;
801010ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010b2:	c9                   	leave  
801010b3:	c3                   	ret    

801010b4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010b4:	f3 0f 1e fb          	endbr32 
801010b8:	55                   	push   %ebp
801010b9:	89 e5                	mov    %esp,%ebp
801010bb:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010be:	83 ec 08             	sub    $0x8,%esp
801010c1:	68 33 8d 10 80       	push   $0x80108d33
801010c6:	68 60 20 11 80       	push   $0x80112060
801010cb:	e8 51 41 00 00       	call   80105221 <initlock>
801010d0:	83 c4 10             	add    $0x10,%esp
}
801010d3:	90                   	nop
801010d4:	c9                   	leave  
801010d5:	c3                   	ret    

801010d6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010d6:	f3 0f 1e fb          	endbr32 
801010da:	55                   	push   %ebp
801010db:	89 e5                	mov    %esp,%ebp
801010dd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010e0:	83 ec 0c             	sub    $0xc,%esp
801010e3:	68 60 20 11 80       	push   $0x80112060
801010e8:	e8 5a 41 00 00       	call   80105247 <acquire>
801010ed:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010f0:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010f7:	eb 2d                	jmp    80101126 <filealloc+0x50>
    if(f->ref == 0){
801010f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010fc:	8b 40 04             	mov    0x4(%eax),%eax
801010ff:	85 c0                	test   %eax,%eax
80101101:	75 1f                	jne    80101122 <filealloc+0x4c>
      f->ref = 1;
80101103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101106:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 60 20 11 80       	push   $0x80112060
80101115:	e8 9f 41 00 00       	call   801052b9 <release>
8010111a:	83 c4 10             	add    $0x10,%esp
      return f;
8010111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101120:	eb 23                	jmp    80101145 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101122:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101126:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
8010112b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010112e:	72 c9                	jb     801010f9 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101130:	83 ec 0c             	sub    $0xc,%esp
80101133:	68 60 20 11 80       	push   $0x80112060
80101138:	e8 7c 41 00 00       	call   801052b9 <release>
8010113d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101140:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101145:	c9                   	leave  
80101146:	c3                   	ret    

80101147 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101147:	f3 0f 1e fb          	endbr32 
8010114b:	55                   	push   %ebp
8010114c:	89 e5                	mov    %esp,%ebp
8010114e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101151:	83 ec 0c             	sub    $0xc,%esp
80101154:	68 60 20 11 80       	push   $0x80112060
80101159:	e8 e9 40 00 00       	call   80105247 <acquire>
8010115e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101161:	8b 45 08             	mov    0x8(%ebp),%eax
80101164:	8b 40 04             	mov    0x4(%eax),%eax
80101167:	85 c0                	test   %eax,%eax
80101169:	7f 0d                	jg     80101178 <filedup+0x31>
    panic("filedup");
8010116b:	83 ec 0c             	sub    $0xc,%esp
8010116e:	68 3a 8d 10 80       	push   $0x80108d3a
80101173:	e8 90 f4 ff ff       	call   80100608 <panic>
  f->ref++;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 40 04             	mov    0x4(%eax),%eax
8010117e:	8d 50 01             	lea    0x1(%eax),%edx
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101187:	83 ec 0c             	sub    $0xc,%esp
8010118a:	68 60 20 11 80       	push   $0x80112060
8010118f:	e8 25 41 00 00       	call   801052b9 <release>
80101194:	83 c4 10             	add    $0x10,%esp
  return f;
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010119a:	c9                   	leave  
8010119b:	c3                   	ret    

8010119c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010119c:	f3 0f 1e fb          	endbr32 
801011a0:	55                   	push   %ebp
801011a1:	89 e5                	mov    %esp,%ebp
801011a3:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011a6:	83 ec 0c             	sub    $0xc,%esp
801011a9:	68 60 20 11 80       	push   $0x80112060
801011ae:	e8 94 40 00 00       	call   80105247 <acquire>
801011b3:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 40 04             	mov    0x4(%eax),%eax
801011bc:	85 c0                	test   %eax,%eax
801011be:	7f 0d                	jg     801011cd <fileclose+0x31>
    panic("fileclose");
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	68 42 8d 10 80       	push   $0x80108d42
801011c8:	e8 3b f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 40 04             	mov    0x4(%eax),%eax
801011d3:	8d 50 ff             	lea    -0x1(%eax),%edx
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	89 50 04             	mov    %edx,0x4(%eax)
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 40 04             	mov    0x4(%eax),%eax
801011e2:	85 c0                	test   %eax,%eax
801011e4:	7e 15                	jle    801011fb <fileclose+0x5f>
    release(&ftable.lock);
801011e6:	83 ec 0c             	sub    $0xc,%esp
801011e9:	68 60 20 11 80       	push   $0x80112060
801011ee:	e8 c6 40 00 00       	call   801052b9 <release>
801011f3:	83 c4 10             	add    $0x10,%esp
801011f6:	e9 8b 00 00 00       	jmp    80101286 <fileclose+0xea>
    return;
  }
  ff = *f;
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 10                	mov    (%eax),%edx
80101200:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101203:	8b 50 04             	mov    0x4(%eax),%edx
80101206:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101209:	8b 50 08             	mov    0x8(%eax),%edx
8010120c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010120f:	8b 50 0c             	mov    0xc(%eax),%edx
80101212:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101215:	8b 50 10             	mov    0x10(%eax),%edx
80101218:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010121b:	8b 40 14             	mov    0x14(%eax),%eax
8010121e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101221:	8b 45 08             	mov    0x8(%ebp),%eax
80101224:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101234:	83 ec 0c             	sub    $0xc,%esp
80101237:	68 60 20 11 80       	push   $0x80112060
8010123c:	e8 78 40 00 00       	call   801052b9 <release>
80101241:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101244:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101247:	83 f8 01             	cmp    $0x1,%eax
8010124a:	75 19                	jne    80101265 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
8010124c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101250:	0f be d0             	movsbl %al,%edx
80101253:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101256:	83 ec 08             	sub    $0x8,%esp
80101259:	52                   	push   %edx
8010125a:	50                   	push   %eax
8010125b:	e8 c1 2e 00 00       	call   80104121 <pipeclose>
80101260:	83 c4 10             	add    $0x10,%esp
80101263:	eb 21                	jmp    80101286 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101265:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101268:	83 f8 02             	cmp    $0x2,%eax
8010126b:	75 19                	jne    80101286 <fileclose+0xea>
    begin_op();
8010126d:	e8 79 24 00 00       	call   801036eb <begin_op>
    iput(ff.ip);
80101272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101275:	83 ec 0c             	sub    $0xc,%esp
80101278:	50                   	push   %eax
80101279:	e8 07 0a 00 00       	call   80101c85 <iput>
8010127e:	83 c4 10             	add    $0x10,%esp
    end_op();
80101281:	e8 f5 24 00 00       	call   8010377b <end_op>
  }
}
80101286:	c9                   	leave  
80101287:	c3                   	ret    

80101288 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101288:	f3 0f 1e fb          	endbr32 
8010128c:	55                   	push   %ebp
8010128d:	89 e5                	mov    %esp,%ebp
8010128f:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 00                	mov    (%eax),%eax
80101297:	83 f8 02             	cmp    $0x2,%eax
8010129a:	75 40                	jne    801012dc <filestat+0x54>
    ilock(f->ip);
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	8b 40 10             	mov    0x10(%eax),%eax
801012a2:	83 ec 0c             	sub    $0xc,%esp
801012a5:	50                   	push   %eax
801012a6:	e8 71 08 00 00       	call   80101b1c <ilock>
801012ab:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 40 10             	mov    0x10(%eax),%eax
801012b4:	83 ec 08             	sub    $0x8,%esp
801012b7:	ff 75 0c             	pushl  0xc(%ebp)
801012ba:	50                   	push   %eax
801012bb:	e8 1a 0d 00 00       	call   80101fda <stati>
801012c0:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012c3:	8b 45 08             	mov    0x8(%ebp),%eax
801012c6:	8b 40 10             	mov    0x10(%eax),%eax
801012c9:	83 ec 0c             	sub    $0xc,%esp
801012cc:	50                   	push   %eax
801012cd:	e8 61 09 00 00       	call   80101c33 <iunlock>
801012d2:	83 c4 10             	add    $0x10,%esp
    return 0;
801012d5:	b8 00 00 00 00       	mov    $0x0,%eax
801012da:	eb 05                	jmp    801012e1 <filestat+0x59>
  }
  return -1;
801012dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012e1:	c9                   	leave  
801012e2:	c3                   	ret    

801012e3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012e3:	f3 0f 1e fb          	endbr32 
801012e7:	55                   	push   %ebp
801012e8:	89 e5                	mov    %esp,%ebp
801012ea:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012f4:	84 c0                	test   %al,%al
801012f6:	75 0a                	jne    80101302 <fileread+0x1f>
    return -1;
801012f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012fd:	e9 9b 00 00 00       	jmp    8010139d <fileread+0xba>
  if(f->type == FD_PIPE)
80101302:	8b 45 08             	mov    0x8(%ebp),%eax
80101305:	8b 00                	mov    (%eax),%eax
80101307:	83 f8 01             	cmp    $0x1,%eax
8010130a:	75 1a                	jne    80101326 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 40 0c             	mov    0xc(%eax),%eax
80101312:	83 ec 04             	sub    $0x4,%esp
80101315:	ff 75 10             	pushl  0x10(%ebp)
80101318:	ff 75 0c             	pushl  0xc(%ebp)
8010131b:	50                   	push   %eax
8010131c:	e8 b5 2f 00 00       	call   801042d6 <piperead>
80101321:	83 c4 10             	add    $0x10,%esp
80101324:	eb 77                	jmp    8010139d <fileread+0xba>
  if(f->type == FD_INODE){
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 00                	mov    (%eax),%eax
8010132b:	83 f8 02             	cmp    $0x2,%eax
8010132e:	75 60                	jne    80101390 <fileread+0xad>
    ilock(f->ip);
80101330:	8b 45 08             	mov    0x8(%ebp),%eax
80101333:	8b 40 10             	mov    0x10(%eax),%eax
80101336:	83 ec 0c             	sub    $0xc,%esp
80101339:	50                   	push   %eax
8010133a:	e8 dd 07 00 00       	call   80101b1c <ilock>
8010133f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101342:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101345:	8b 45 08             	mov    0x8(%ebp),%eax
80101348:	8b 50 14             	mov    0x14(%eax),%edx
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 40 10             	mov    0x10(%eax),%eax
80101351:	51                   	push   %ecx
80101352:	52                   	push   %edx
80101353:	ff 75 0c             	pushl  0xc(%ebp)
80101356:	50                   	push   %eax
80101357:	e8 c8 0c 00 00       	call   80102024 <readi>
8010135c:	83 c4 10             	add    $0x10,%esp
8010135f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101362:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101366:	7e 11                	jle    80101379 <fileread+0x96>
      f->off += r;
80101368:	8b 45 08             	mov    0x8(%ebp),%eax
8010136b:	8b 50 14             	mov    0x14(%eax),%edx
8010136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101371:	01 c2                	add    %eax,%edx
80101373:	8b 45 08             	mov    0x8(%ebp),%eax
80101376:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101379:	8b 45 08             	mov    0x8(%ebp),%eax
8010137c:	8b 40 10             	mov    0x10(%eax),%eax
8010137f:	83 ec 0c             	sub    $0xc,%esp
80101382:	50                   	push   %eax
80101383:	e8 ab 08 00 00       	call   80101c33 <iunlock>
80101388:	83 c4 10             	add    $0x10,%esp
    return r;
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	eb 0d                	jmp    8010139d <fileread+0xba>
  }
  panic("fileread");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 4c 8d 10 80       	push   $0x80108d4c
80101398:	e8 6b f2 ff ff       	call   80100608 <panic>
}
8010139d:	c9                   	leave  
8010139e:	c3                   	ret    

8010139f <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010139f:	f3 0f 1e fb          	endbr32 
801013a3:	55                   	push   %ebp
801013a4:	89 e5                	mov    %esp,%ebp
801013a6:	53                   	push   %ebx
801013a7:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013aa:	8b 45 08             	mov    0x8(%ebp),%eax
801013ad:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013b1:	84 c0                	test   %al,%al
801013b3:	75 0a                	jne    801013bf <filewrite+0x20>
    return -1;
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	e9 1b 01 00 00       	jmp    801014da <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 00                	mov    (%eax),%eax
801013c4:	83 f8 01             	cmp    $0x1,%eax
801013c7:	75 1d                	jne    801013e6 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	8b 40 0c             	mov    0xc(%eax),%eax
801013cf:	83 ec 04             	sub    $0x4,%esp
801013d2:	ff 75 10             	pushl  0x10(%ebp)
801013d5:	ff 75 0c             	pushl  0xc(%ebp)
801013d8:	50                   	push   %eax
801013d9:	e8 f2 2d 00 00       	call   801041d0 <pipewrite>
801013de:	83 c4 10             	add    $0x10,%esp
801013e1:	e9 f4 00 00 00       	jmp    801014da <filewrite+0x13b>
  if(f->type == FD_INODE){
801013e6:	8b 45 08             	mov    0x8(%ebp),%eax
801013e9:	8b 00                	mov    (%eax),%eax
801013eb:	83 f8 02             	cmp    $0x2,%eax
801013ee:	0f 85 d9 00 00 00    	jne    801014cd <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013f4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101402:	e9 a3 00 00 00       	jmp    801014aa <filewrite+0x10b>
      int n1 = n - i;
80101407:	8b 45 10             	mov    0x10(%ebp),%eax
8010140a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010140d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101413:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101416:	7e 06                	jle    8010141e <filewrite+0x7f>
        n1 = max;
80101418:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010141b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010141e:	e8 c8 22 00 00       	call   801036eb <begin_op>
      ilock(f->ip);
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	8b 40 10             	mov    0x10(%eax),%eax
80101429:	83 ec 0c             	sub    $0xc,%esp
8010142c:	50                   	push   %eax
8010142d:	e8 ea 06 00 00       	call   80101b1c <ilock>
80101432:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101435:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101438:	8b 45 08             	mov    0x8(%ebp),%eax
8010143b:	8b 50 14             	mov    0x14(%eax),%edx
8010143e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101441:	8b 45 0c             	mov    0xc(%ebp),%eax
80101444:	01 c3                	add    %eax,%ebx
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	8b 40 10             	mov    0x10(%eax),%eax
8010144c:	51                   	push   %ecx
8010144d:	52                   	push   %edx
8010144e:	53                   	push   %ebx
8010144f:	50                   	push   %eax
80101450:	e8 28 0d 00 00       	call   8010217d <writei>
80101455:	83 c4 10             	add    $0x10,%esp
80101458:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010145b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010145f:	7e 11                	jle    80101472 <filewrite+0xd3>
        f->off += r;
80101461:	8b 45 08             	mov    0x8(%ebp),%eax
80101464:	8b 50 14             	mov    0x14(%eax),%edx
80101467:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010146a:	01 c2                	add    %eax,%edx
8010146c:	8b 45 08             	mov    0x8(%ebp),%eax
8010146f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101472:	8b 45 08             	mov    0x8(%ebp),%eax
80101475:	8b 40 10             	mov    0x10(%eax),%eax
80101478:	83 ec 0c             	sub    $0xc,%esp
8010147b:	50                   	push   %eax
8010147c:	e8 b2 07 00 00       	call   80101c33 <iunlock>
80101481:	83 c4 10             	add    $0x10,%esp
      end_op();
80101484:	e8 f2 22 00 00       	call   8010377b <end_op>

      if(r < 0)
80101489:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010148d:	78 29                	js     801014b8 <filewrite+0x119>
        break;
      if(r != n1)
8010148f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101492:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101495:	74 0d                	je     801014a4 <filewrite+0x105>
        panic("short filewrite");
80101497:	83 ec 0c             	sub    $0xc,%esp
8010149a:	68 55 8d 10 80       	push   $0x80108d55
8010149f:	e8 64 f1 ff ff       	call   80100608 <panic>
      i += r;
801014a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014a7:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801014b0:	0f 8c 51 ff ff ff    	jl     80101407 <filewrite+0x68>
801014b6:	eb 01                	jmp    801014b9 <filewrite+0x11a>
        break;
801014b8:	90                   	nop
    }
    return i == n ? n : -1;
801014b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801014bf:	75 05                	jne    801014c6 <filewrite+0x127>
801014c1:	8b 45 10             	mov    0x10(%ebp),%eax
801014c4:	eb 14                	jmp    801014da <filewrite+0x13b>
801014c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014cb:	eb 0d                	jmp    801014da <filewrite+0x13b>
  }
  panic("filewrite");
801014cd:	83 ec 0c             	sub    $0xc,%esp
801014d0:	68 65 8d 10 80       	push   $0x80108d65
801014d5:	e8 2e f1 ff ff       	call   80100608 <panic>
}
801014da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014dd:	c9                   	leave  
801014de:	c3                   	ret    

801014df <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014df:	f3 0f 1e fb          	endbr32 
801014e3:	55                   	push   %ebp
801014e4:	89 e5                	mov    %esp,%ebp
801014e6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014e9:	8b 45 08             	mov    0x8(%ebp),%eax
801014ec:	83 ec 08             	sub    $0x8,%esp
801014ef:	6a 01                	push   $0x1
801014f1:	50                   	push   %eax
801014f2:	e8 e0 ec ff ff       	call   801001d7 <bread>
801014f7:	83 c4 10             	add    $0x10,%esp
801014fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101500:	83 c0 5c             	add    $0x5c,%eax
80101503:	83 ec 04             	sub    $0x4,%esp
80101506:	6a 1c                	push   $0x1c
80101508:	50                   	push   %eax
80101509:	ff 75 0c             	pushl  0xc(%ebp)
8010150c:	e8 9c 40 00 00       	call   801055ad <memmove>
80101511:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101514:	83 ec 0c             	sub    $0xc,%esp
80101517:	ff 75 f4             	pushl  -0xc(%ebp)
8010151a:	e8 42 ed ff ff       	call   80100261 <brelse>
8010151f:	83 c4 10             	add    $0x10,%esp
}
80101522:	90                   	nop
80101523:	c9                   	leave  
80101524:	c3                   	ret    

80101525 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101525:	f3 0f 1e fb          	endbr32 
80101529:	55                   	push   %ebp
8010152a:	89 e5                	mov    %esp,%ebp
8010152c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010152f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101532:	8b 45 08             	mov    0x8(%ebp),%eax
80101535:	83 ec 08             	sub    $0x8,%esp
80101538:	52                   	push   %edx
80101539:	50                   	push   %eax
8010153a:	e8 98 ec ff ff       	call   801001d7 <bread>
8010153f:	83 c4 10             	add    $0x10,%esp
80101542:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101548:	83 c0 5c             	add    $0x5c,%eax
8010154b:	83 ec 04             	sub    $0x4,%esp
8010154e:	68 00 02 00 00       	push   $0x200
80101553:	6a 00                	push   $0x0
80101555:	50                   	push   %eax
80101556:	e8 8b 3f 00 00       	call   801054e6 <memset>
8010155b:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010155e:	83 ec 0c             	sub    $0xc,%esp
80101561:	ff 75 f4             	pushl  -0xc(%ebp)
80101564:	e8 cb 23 00 00       	call   80103934 <log_write>
80101569:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010156c:	83 ec 0c             	sub    $0xc,%esp
8010156f:	ff 75 f4             	pushl  -0xc(%ebp)
80101572:	e8 ea ec ff ff       	call   80100261 <brelse>
80101577:	83 c4 10             	add    $0x10,%esp
}
8010157a:	90                   	nop
8010157b:	c9                   	leave  
8010157c:	c3                   	ret    

8010157d <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010157d:	f3 0f 1e fb          	endbr32 
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101587:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010158e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101595:	e9 13 01 00 00       	jmp    801016ad <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
8010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015a3:	85 c0                	test   %eax,%eax
801015a5:	0f 48 c2             	cmovs  %edx,%eax
801015a8:	c1 f8 0c             	sar    $0xc,%eax
801015ab:	89 c2                	mov    %eax,%edx
801015ad:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015b2:	01 d0                	add    %edx,%eax
801015b4:	83 ec 08             	sub    $0x8,%esp
801015b7:	50                   	push   %eax
801015b8:	ff 75 08             	pushl  0x8(%ebp)
801015bb:	e8 17 ec ff ff       	call   801001d7 <bread>
801015c0:	83 c4 10             	add    $0x10,%esp
801015c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015cd:	e9 a6 00 00 00       	jmp    80101678 <balloc+0xfb>
      m = 1 << (bi % 8);
801015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d5:	99                   	cltd   
801015d6:	c1 ea 1d             	shr    $0x1d,%edx
801015d9:	01 d0                	add    %edx,%eax
801015db:	83 e0 07             	and    $0x7,%eax
801015de:	29 d0                	sub    %edx,%eax
801015e0:	ba 01 00 00 00       	mov    $0x1,%edx
801015e5:	89 c1                	mov    %eax,%ecx
801015e7:	d3 e2                	shl    %cl,%edx
801015e9:	89 d0                	mov    %edx,%eax
801015eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	8d 50 07             	lea    0x7(%eax),%edx
801015f4:	85 c0                	test   %eax,%eax
801015f6:	0f 48 c2             	cmovs  %edx,%eax
801015f9:	c1 f8 03             	sar    $0x3,%eax
801015fc:	89 c2                	mov    %eax,%edx
801015fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101601:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101606:	0f b6 c0             	movzbl %al,%eax
80101609:	23 45 e8             	and    -0x18(%ebp),%eax
8010160c:	85 c0                	test   %eax,%eax
8010160e:	75 64                	jne    80101674 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	8d 50 07             	lea    0x7(%eax),%edx
80101616:	85 c0                	test   %eax,%eax
80101618:	0f 48 c2             	cmovs  %edx,%eax
8010161b:	c1 f8 03             	sar    $0x3,%eax
8010161e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101621:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101626:	89 d1                	mov    %edx,%ecx
80101628:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010162b:	09 ca                	or     %ecx,%edx
8010162d:	89 d1                	mov    %edx,%ecx
8010162f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101632:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	ff 75 ec             	pushl  -0x14(%ebp)
8010163c:	e8 f3 22 00 00       	call   80103934 <log_write>
80101641:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101644:	83 ec 0c             	sub    $0xc,%esp
80101647:	ff 75 ec             	pushl  -0x14(%ebp)
8010164a:	e8 12 ec ff ff       	call   80100261 <brelse>
8010164f:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	01 c2                	add    %eax,%edx
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	83 ec 08             	sub    $0x8,%esp
80101660:	52                   	push   %edx
80101661:	50                   	push   %eax
80101662:	e8 be fe ff ff       	call   80101525 <bzero>
80101667:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101670:	01 d0                	add    %edx,%eax
80101672:	eb 57                	jmp    801016cb <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101674:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101678:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010167f:	7f 17                	jg     80101698 <balloc+0x11b>
80101681:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101687:	01 d0                	add    %edx,%eax
80101689:	89 c2                	mov    %eax,%edx
8010168b:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101690:	39 c2                	cmp    %eax,%edx
80101692:	0f 82 3a ff ff ff    	jb     801015d2 <balloc+0x55>
      }
    }
    brelse(bp);
80101698:	83 ec 0c             	sub    $0xc,%esp
8010169b:	ff 75 ec             	pushl  -0x14(%ebp)
8010169e:	e8 be eb ff ff       	call   80100261 <brelse>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016ad:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b6:	39 c2                	cmp    %eax,%edx
801016b8:	0f 87 dc fe ff ff    	ja     8010159a <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016be:	83 ec 0c             	sub    $0xc,%esp
801016c1:	68 70 8d 10 80       	push   $0x80108d70
801016c6:	e8 3d ef ff ff       	call   80100608 <panic>
}
801016cb:	c9                   	leave  
801016cc:	c3                   	ret    

801016cd <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016cd:	f3 0f 1e fb          	endbr32 
801016d1:	55                   	push   %ebp
801016d2:	89 e5                	mov    %esp,%ebp
801016d4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801016da:	c1 e8 0c             	shr    $0xc,%eax
801016dd:	89 c2                	mov    %eax,%edx
801016df:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016e4:	01 c2                	add    %eax,%edx
801016e6:	8b 45 08             	mov    0x8(%ebp),%eax
801016e9:	83 ec 08             	sub    $0x8,%esp
801016ec:	52                   	push   %edx
801016ed:	50                   	push   %eax
801016ee:	e8 e4 ea ff ff       	call   801001d7 <bread>
801016f3:	83 c4 10             	add    $0x10,%esp
801016f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801016fc:	25 ff 0f 00 00       	and    $0xfff,%eax
80101701:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101707:	99                   	cltd   
80101708:	c1 ea 1d             	shr    $0x1d,%edx
8010170b:	01 d0                	add    %edx,%eax
8010170d:	83 e0 07             	and    $0x7,%eax
80101710:	29 d0                	sub    %edx,%eax
80101712:	ba 01 00 00 00       	mov    $0x1,%edx
80101717:	89 c1                	mov    %eax,%ecx
80101719:	d3 e2                	shl    %cl,%edx
8010171b:	89 d0                	mov    %edx,%eax
8010171d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101723:	8d 50 07             	lea    0x7(%eax),%edx
80101726:	85 c0                	test   %eax,%eax
80101728:	0f 48 c2             	cmovs  %edx,%eax
8010172b:	c1 f8 03             	sar    $0x3,%eax
8010172e:	89 c2                	mov    %eax,%edx
80101730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101733:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101738:	0f b6 c0             	movzbl %al,%eax
8010173b:	23 45 ec             	and    -0x14(%ebp),%eax
8010173e:	85 c0                	test   %eax,%eax
80101740:	75 0d                	jne    8010174f <bfree+0x82>
    panic("freeing free block");
80101742:	83 ec 0c             	sub    $0xc,%esp
80101745:	68 86 8d 10 80       	push   $0x80108d86
8010174a:	e8 b9 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
8010174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101752:	8d 50 07             	lea    0x7(%eax),%edx
80101755:	85 c0                	test   %eax,%eax
80101757:	0f 48 c2             	cmovs  %edx,%eax
8010175a:	c1 f8 03             	sar    $0x3,%eax
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101765:	89 d1                	mov    %edx,%ecx
80101767:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010176a:	f7 d2                	not    %edx
8010176c:	21 ca                	and    %ecx,%edx
8010176e:	89 d1                	mov    %edx,%ecx
80101770:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101773:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101777:	83 ec 0c             	sub    $0xc,%esp
8010177a:	ff 75 f4             	pushl  -0xc(%ebp)
8010177d:	e8 b2 21 00 00       	call   80103934 <log_write>
80101782:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101785:	83 ec 0c             	sub    $0xc,%esp
80101788:	ff 75 f4             	pushl  -0xc(%ebp)
8010178b:	e8 d1 ea ff ff       	call   80100261 <brelse>
80101790:	83 c4 10             	add    $0x10,%esp
}
80101793:	90                   	nop
80101794:	c9                   	leave  
80101795:	c3                   	ret    

80101796 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101796:	f3 0f 1e fb          	endbr32 
8010179a:	55                   	push   %ebp
8010179b:	89 e5                	mov    %esp,%ebp
8010179d:	57                   	push   %edi
8010179e:	56                   	push   %esi
8010179f:	53                   	push   %ebx
801017a0:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017aa:	83 ec 08             	sub    $0x8,%esp
801017ad:	68 99 8d 10 80       	push   $0x80108d99
801017b2:	68 80 2a 11 80       	push   $0x80112a80
801017b7:	e8 65 3a 00 00       	call   80105221 <initlock>
801017bc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017c6:	eb 2d                	jmp    801017f5 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017cb:	89 d0                	mov    %edx,%eax
801017cd:	c1 e0 03             	shl    $0x3,%eax
801017d0:	01 d0                	add    %edx,%eax
801017d2:	c1 e0 04             	shl    $0x4,%eax
801017d5:	83 c0 30             	add    $0x30,%eax
801017d8:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017dd:	83 c0 10             	add    $0x10,%eax
801017e0:	83 ec 08             	sub    $0x8,%esp
801017e3:	68 a0 8d 10 80       	push   $0x80108da0
801017e8:	50                   	push   %eax
801017e9:	e8 a0 38 00 00       	call   8010508e <initsleeplock>
801017ee:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017f1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017f5:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017f9:	7e cd                	jle    801017c8 <iinit+0x32>
  }

  readsb(dev, &sb);
801017fb:	83 ec 08             	sub    $0x8,%esp
801017fe:	68 60 2a 11 80       	push   $0x80112a60
80101803:	ff 75 08             	pushl  0x8(%ebp)
80101806:	e8 d4 fc ff ff       	call   801014df <readsb>
8010180b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010180e:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101813:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101816:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
8010181c:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101822:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101828:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
8010182e:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101834:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101839:	ff 75 d4             	pushl  -0x2c(%ebp)
8010183c:	57                   	push   %edi
8010183d:	56                   	push   %esi
8010183e:	53                   	push   %ebx
8010183f:	51                   	push   %ecx
80101840:	52                   	push   %edx
80101841:	50                   	push   %eax
80101842:	68 a8 8d 10 80       	push   $0x80108da8
80101847:	e8 cc eb ff ff       	call   80100418 <cprintf>
8010184c:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010184f:	90                   	nop
80101850:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101853:	5b                   	pop    %ebx
80101854:	5e                   	pop    %esi
80101855:	5f                   	pop    %edi
80101856:	5d                   	pop    %ebp
80101857:	c3                   	ret    

80101858 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101858:	f3 0f 1e fb          	endbr32 
8010185c:	55                   	push   %ebp
8010185d:	89 e5                	mov    %esp,%ebp
8010185f:	83 ec 28             	sub    $0x28,%esp
80101862:	8b 45 0c             	mov    0xc(%ebp),%eax
80101865:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101869:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101870:	e9 9e 00 00 00       	jmp    80101913 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101878:	c1 e8 03             	shr    $0x3,%eax
8010187b:	89 c2                	mov    %eax,%edx
8010187d:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101882:	01 d0                	add    %edx,%eax
80101884:	83 ec 08             	sub    $0x8,%esp
80101887:	50                   	push   %eax
80101888:	ff 75 08             	pushl  0x8(%ebp)
8010188b:	e8 47 e9 ff ff       	call   801001d7 <bread>
80101890:	83 c4 10             	add    $0x10,%esp
80101893:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189f:	83 e0 07             	and    $0x7,%eax
801018a2:	c1 e0 06             	shl    $0x6,%eax
801018a5:	01 d0                	add    %edx,%eax
801018a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018ad:	0f b7 00             	movzwl (%eax),%eax
801018b0:	66 85 c0             	test   %ax,%ax
801018b3:	75 4c                	jne    80101901 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018b5:	83 ec 04             	sub    $0x4,%esp
801018b8:	6a 40                	push   $0x40
801018ba:	6a 00                	push   $0x0
801018bc:	ff 75 ec             	pushl  -0x14(%ebp)
801018bf:	e8 22 3c 00 00       	call   801054e6 <memset>
801018c4:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018ca:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018ce:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018d1:	83 ec 0c             	sub    $0xc,%esp
801018d4:	ff 75 f0             	pushl  -0x10(%ebp)
801018d7:	e8 58 20 00 00       	call   80103934 <log_write>
801018dc:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018df:	83 ec 0c             	sub    $0xc,%esp
801018e2:	ff 75 f0             	pushl  -0x10(%ebp)
801018e5:	e8 77 e9 ff ff       	call   80100261 <brelse>
801018ea:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f0:	83 ec 08             	sub    $0x8,%esp
801018f3:	50                   	push   %eax
801018f4:	ff 75 08             	pushl  0x8(%ebp)
801018f7:	e8 fc 00 00 00       	call   801019f8 <iget>
801018fc:	83 c4 10             	add    $0x10,%esp
801018ff:	eb 30                	jmp    80101931 <ialloc+0xd9>
    }
    brelse(bp);
80101901:	83 ec 0c             	sub    $0xc,%esp
80101904:	ff 75 f0             	pushl  -0x10(%ebp)
80101907:	e8 55 e9 ff ff       	call   80100261 <brelse>
8010190c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010190f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101913:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
80101919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191c:	39 c2                	cmp    %eax,%edx
8010191e:	0f 87 51 ff ff ff    	ja     80101875 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101924:	83 ec 0c             	sub    $0xc,%esp
80101927:	68 fb 8d 10 80       	push   $0x80108dfb
8010192c:	e8 d7 ec ff ff       	call   80100608 <panic>
}
80101931:	c9                   	leave  
80101932:	c3                   	ret    

80101933 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101933:	f3 0f 1e fb          	endbr32 
80101937:	55                   	push   %ebp
80101938:	89 e5                	mov    %esp,%ebp
8010193a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010193d:	8b 45 08             	mov    0x8(%ebp),%eax
80101940:	8b 40 04             	mov    0x4(%eax),%eax
80101943:	c1 e8 03             	shr    $0x3,%eax
80101946:	89 c2                	mov    %eax,%edx
80101948:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010194d:	01 c2                	add    %eax,%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	8b 00                	mov    (%eax),%eax
80101954:	83 ec 08             	sub    $0x8,%esp
80101957:	52                   	push   %edx
80101958:	50                   	push   %eax
80101959:	e8 79 e8 ff ff       	call   801001d7 <bread>
8010195e:	83 c4 10             	add    $0x10,%esp
80101961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101967:	8d 50 5c             	lea    0x5c(%eax),%edx
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 04             	mov    0x4(%eax),%eax
80101970:	83 e0 07             	and    $0x7,%eax
80101973:	c1 e0 06             	shl    $0x6,%eax
80101976:	01 d0                	add    %edx,%eax
80101978:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010197b:	8b 45 08             	mov    0x8(%ebp),%eax
8010197e:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101985:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101988:	8b 45 08             	mov    0x8(%ebp),%eax
8010198b:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101992:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010199d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a0:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019a4:	8b 45 08             	mov    0x8(%ebp),%eax
801019a7:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ae:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 50 58             	mov    0x58(%eax),%edx
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019be:	8b 45 08             	mov    0x8(%ebp),%eax
801019c1:	8d 50 5c             	lea    0x5c(%eax),%edx
801019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c7:	83 c0 0c             	add    $0xc,%eax
801019ca:	83 ec 04             	sub    $0x4,%esp
801019cd:	6a 34                	push   $0x34
801019cf:	52                   	push   %edx
801019d0:	50                   	push   %eax
801019d1:	e8 d7 3b 00 00       	call   801055ad <memmove>
801019d6:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019d9:	83 ec 0c             	sub    $0xc,%esp
801019dc:	ff 75 f4             	pushl  -0xc(%ebp)
801019df:	e8 50 1f 00 00       	call   80103934 <log_write>
801019e4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019e7:	83 ec 0c             	sub    $0xc,%esp
801019ea:	ff 75 f4             	pushl  -0xc(%ebp)
801019ed:	e8 6f e8 ff ff       	call   80100261 <brelse>
801019f2:	83 c4 10             	add    $0x10,%esp
}
801019f5:	90                   	nop
801019f6:	c9                   	leave  
801019f7:	c3                   	ret    

801019f8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019f8:	f3 0f 1e fb          	endbr32 
801019fc:	55                   	push   %ebp
801019fd:	89 e5                	mov    %esp,%ebp
801019ff:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a02:	83 ec 0c             	sub    $0xc,%esp
80101a05:	68 80 2a 11 80       	push   $0x80112a80
80101a0a:	e8 38 38 00 00       	call   80105247 <acquire>
80101a0f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a19:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a20:	eb 60                	jmp    80101a82 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 40 08             	mov    0x8(%eax),%eax
80101a28:	85 c0                	test   %eax,%eax
80101a2a:	7e 39                	jle    80101a65 <iget+0x6d>
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	8b 00                	mov    (%eax),%eax
80101a31:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a34:	75 2f                	jne    80101a65 <iget+0x6d>
80101a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a39:	8b 40 04             	mov    0x4(%eax),%eax
80101a3c:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a3f:	75 24                	jne    80101a65 <iget+0x6d>
      ip->ref++;
80101a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	8d 50 01             	lea    0x1(%eax),%edx
80101a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a50:	83 ec 0c             	sub    $0xc,%esp
80101a53:	68 80 2a 11 80       	push   $0x80112a80
80101a58:	e8 5c 38 00 00       	call   801052b9 <release>
80101a5d:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a63:	eb 77                	jmp    80101adc <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a69:	75 10                	jne    80101a7b <iget+0x83>
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	8b 40 08             	mov    0x8(%eax),%eax
80101a71:	85 c0                	test   %eax,%eax
80101a73:	75 06                	jne    80101a7b <iget+0x83>
      empty = ip;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a7b:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a82:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a89:	72 97                	jb     80101a22 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a8f:	75 0d                	jne    80101a9e <iget+0xa6>
    panic("iget: no inodes");
80101a91:	83 ec 0c             	sub    $0xc,%esp
80101a94:	68 0d 8e 10 80       	push   $0x80108e0d
80101a99:	e8 6a eb ff ff       	call   80100608 <panic>

  ip = empty;
80101a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa7:	8b 55 08             	mov    0x8(%ebp),%edx
80101aaa:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ab2:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	68 80 2a 11 80       	push   $0x80112a80
80101ad1:	e8 e3 37 00 00       	call   801052b9 <release>
80101ad6:	83 c4 10             	add    $0x10,%esp

  return ip;
80101ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101adc:	c9                   	leave  
80101add:	c3                   	ret    

80101ade <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ade:	f3 0f 1e fb          	endbr32 
80101ae2:	55                   	push   %ebp
80101ae3:	89 e5                	mov    %esp,%ebp
80101ae5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ae8:	83 ec 0c             	sub    $0xc,%esp
80101aeb:	68 80 2a 11 80       	push   $0x80112a80
80101af0:	e8 52 37 00 00       	call   80105247 <acquire>
80101af5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101af8:	8b 45 08             	mov    0x8(%ebp),%eax
80101afb:	8b 40 08             	mov    0x8(%eax),%eax
80101afe:	8d 50 01             	lea    0x1(%eax),%edx
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b07:	83 ec 0c             	sub    $0xc,%esp
80101b0a:	68 80 2a 11 80       	push   $0x80112a80
80101b0f:	e8 a5 37 00 00       	call   801052b9 <release>
80101b14:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b1a:	c9                   	leave  
80101b1b:	c3                   	ret    

80101b1c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b1c:	f3 0f 1e fb          	endbr32 
80101b20:	55                   	push   %ebp
80101b21:	89 e5                	mov    %esp,%ebp
80101b23:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b2a:	74 0a                	je     80101b36 <ilock+0x1a>
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	8b 40 08             	mov    0x8(%eax),%eax
80101b32:	85 c0                	test   %eax,%eax
80101b34:	7f 0d                	jg     80101b43 <ilock+0x27>
    panic("ilock");
80101b36:	83 ec 0c             	sub    $0xc,%esp
80101b39:	68 1d 8e 10 80       	push   $0x80108e1d
80101b3e:	e8 c5 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b43:	8b 45 08             	mov    0x8(%ebp),%eax
80101b46:	83 c0 0c             	add    $0xc,%eax
80101b49:	83 ec 0c             	sub    $0xc,%esp
80101b4c:	50                   	push   %eax
80101b4d:	e8 7c 35 00 00       	call   801050ce <acquiresleep>
80101b52:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5b:	85 c0                	test   %eax,%eax
80101b5d:	0f 85 cd 00 00 00    	jne    80101c30 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 04             	mov    0x4(%eax),%eax
80101b69:	c1 e8 03             	shr    $0x3,%eax
80101b6c:	89 c2                	mov    %eax,%edx
80101b6e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b73:	01 c2                	add    %eax,%edx
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 00                	mov    (%eax),%eax
80101b7a:	83 ec 08             	sub    $0x8,%esp
80101b7d:	52                   	push   %edx
80101b7e:	50                   	push   %eax
80101b7f:	e8 53 e6 ff ff       	call   801001d7 <bread>
80101b84:	83 c4 10             	add    $0x10,%esp
80101b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	8b 40 04             	mov    0x4(%eax),%eax
80101b96:	83 e0 07             	and    $0x7,%eax
80101b99:	c1 e0 06             	shl    $0x6,%eax
80101b9c:	01 d0                	add    %edx,%eax
80101b9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba4:	0f b7 10             	movzwl (%eax),%edx
80101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80101baa:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb8:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbf:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcd:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd4:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bdb:	8b 50 08             	mov    0x8(%eax),%edx
80101bde:	8b 45 08             	mov    0x8(%ebp),%eax
80101be1:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be7:	8d 50 0c             	lea    0xc(%eax),%edx
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	83 c0 5c             	add    $0x5c,%eax
80101bf0:	83 ec 04             	sub    $0x4,%esp
80101bf3:	6a 34                	push   $0x34
80101bf5:	52                   	push   %edx
80101bf6:	50                   	push   %eax
80101bf7:	e8 b1 39 00 00       	call   801055ad <memmove>
80101bfc:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	ff 75 f4             	pushl  -0xc(%ebp)
80101c05:	e8 57 e6 ff ff       	call   80100261 <brelse>
80101c0a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c1e:	66 85 c0             	test   %ax,%ax
80101c21:	75 0d                	jne    80101c30 <ilock+0x114>
      panic("ilock: no type");
80101c23:	83 ec 0c             	sub    $0xc,%esp
80101c26:	68 23 8e 10 80       	push   $0x80108e23
80101c2b:	e8 d8 e9 ff ff       	call   80100608 <panic>
  }
}
80101c30:	90                   	nop
80101c31:	c9                   	leave  
80101c32:	c3                   	ret    

80101c33 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c33:	f3 0f 1e fb          	endbr32 
80101c37:	55                   	push   %ebp
80101c38:	89 e5                	mov    %esp,%ebp
80101c3a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c41:	74 20                	je     80101c63 <iunlock+0x30>
80101c43:	8b 45 08             	mov    0x8(%ebp),%eax
80101c46:	83 c0 0c             	add    $0xc,%eax
80101c49:	83 ec 0c             	sub    $0xc,%esp
80101c4c:	50                   	push   %eax
80101c4d:	e8 36 35 00 00       	call   80105188 <holdingsleep>
80101c52:	83 c4 10             	add    $0x10,%esp
80101c55:	85 c0                	test   %eax,%eax
80101c57:	74 0a                	je     80101c63 <iunlock+0x30>
80101c59:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5c:	8b 40 08             	mov    0x8(%eax),%eax
80101c5f:	85 c0                	test   %eax,%eax
80101c61:	7f 0d                	jg     80101c70 <iunlock+0x3d>
    panic("iunlock");
80101c63:	83 ec 0c             	sub    $0xc,%esp
80101c66:	68 32 8e 10 80       	push   $0x80108e32
80101c6b:	e8 98 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	83 c0 0c             	add    $0xc,%eax
80101c76:	83 ec 0c             	sub    $0xc,%esp
80101c79:	50                   	push   %eax
80101c7a:	e8 b7 34 00 00       	call   80105136 <releasesleep>
80101c7f:	83 c4 10             	add    $0x10,%esp
}
80101c82:	90                   	nop
80101c83:	c9                   	leave  
80101c84:	c3                   	ret    

80101c85 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c85:	f3 0f 1e fb          	endbr32 
80101c89:	55                   	push   %ebp
80101c8a:	89 e5                	mov    %esp,%ebp
80101c8c:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c92:	83 c0 0c             	add    $0xc,%eax
80101c95:	83 ec 0c             	sub    $0xc,%esp
80101c98:	50                   	push   %eax
80101c99:	e8 30 34 00 00       	call   801050ce <acquiresleep>
80101c9e:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ca7:	85 c0                	test   %eax,%eax
80101ca9:	74 6a                	je     80101d15 <iput+0x90>
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cb2:	66 85 c0             	test   %ax,%ax
80101cb5:	75 5e                	jne    80101d15 <iput+0x90>
    acquire(&icache.lock);
80101cb7:	83 ec 0c             	sub    $0xc,%esp
80101cba:	68 80 2a 11 80       	push   $0x80112a80
80101cbf:	e8 83 35 00 00       	call   80105247 <acquire>
80101cc4:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	8b 40 08             	mov    0x8(%eax),%eax
80101ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cd0:	83 ec 0c             	sub    $0xc,%esp
80101cd3:	68 80 2a 11 80       	push   $0x80112a80
80101cd8:	e8 dc 35 00 00       	call   801052b9 <release>
80101cdd:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ce0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ce4:	75 2f                	jne    80101d15 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ce6:	83 ec 0c             	sub    $0xc,%esp
80101ce9:	ff 75 08             	pushl  0x8(%ebp)
80101cec:	e8 b5 01 00 00       	call   80101ea6 <itrunc>
80101cf1:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cfd:	83 ec 0c             	sub    $0xc,%esp
80101d00:	ff 75 08             	pushl  0x8(%ebp)
80101d03:	e8 2b fc ff ff       	call   80101933 <iupdate>
80101d08:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	83 c0 0c             	add    $0xc,%eax
80101d1b:	83 ec 0c             	sub    $0xc,%esp
80101d1e:	50                   	push   %eax
80101d1f:	e8 12 34 00 00       	call   80105136 <releasesleep>
80101d24:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	68 80 2a 11 80       	push   $0x80112a80
80101d2f:	e8 13 35 00 00       	call   80105247 <acquire>
80101d34:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	8b 40 08             	mov    0x8(%eax),%eax
80101d3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	68 80 2a 11 80       	push   $0x80112a80
80101d4e:	e8 66 35 00 00       	call   801052b9 <release>
80101d53:	83 c4 10             	add    $0x10,%esp
}
80101d56:	90                   	nop
80101d57:	c9                   	leave  
80101d58:	c3                   	ret    

80101d59 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d59:	f3 0f 1e fb          	endbr32 
80101d5d:	55                   	push   %ebp
80101d5e:	89 e5                	mov    %esp,%ebp
80101d60:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d63:	83 ec 0c             	sub    $0xc,%esp
80101d66:	ff 75 08             	pushl  0x8(%ebp)
80101d69:	e8 c5 fe ff ff       	call   80101c33 <iunlock>
80101d6e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d71:	83 ec 0c             	sub    $0xc,%esp
80101d74:	ff 75 08             	pushl  0x8(%ebp)
80101d77:	e8 09 ff ff ff       	call   80101c85 <iput>
80101d7c:	83 c4 10             	add    $0x10,%esp
}
80101d7f:	90                   	nop
80101d80:	c9                   	leave  
80101d81:	c3                   	ret    

80101d82 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d82:	f3 0f 1e fb          	endbr32 
80101d86:	55                   	push   %ebp
80101d87:	89 e5                	mov    %esp,%ebp
80101d89:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d8c:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d90:	77 42                	ja     80101dd4 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d98:	83 c2 14             	add    $0x14,%edx
80101d9b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101da6:	75 24                	jne    80101dcc <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 00                	mov    (%eax),%eax
80101dad:	83 ec 0c             	sub    $0xc,%esp
80101db0:	50                   	push   %eax
80101db1:	e8 c7 f7 ff ff       	call   8010157d <balloc>
80101db6:	83 c4 10             	add    $0x10,%esp
80101db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dc2:	8d 4a 14             	lea    0x14(%edx),%ecx
80101dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc8:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcf:	e9 d0 00 00 00       	jmp    80101ea4 <bmap+0x122>
  }
  bn -= NDIRECT;
80101dd4:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dd8:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ddc:	0f 87 b5 00 00 00    	ja     80101e97 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df2:	75 20                	jne    80101e14 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	8b 00                	mov    (%eax),%eax
80101df9:	83 ec 0c             	sub    $0xc,%esp
80101dfc:	50                   	push   %eax
80101dfd:	e8 7b f7 ff ff       	call   8010157d <balloc>
80101e02:	83 c4 10             	add    $0x10,%esp
80101e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e0e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 00                	mov    (%eax),%eax
80101e19:	83 ec 08             	sub    $0x8,%esp
80101e1c:	ff 75 f4             	pushl  -0xc(%ebp)
80101e1f:	50                   	push   %eax
80101e20:	e8 b2 e3 ff ff       	call   801001d7 <bread>
80101e25:	83 c4 10             	add    $0x10,%esp
80101e28:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2e:	83 c0 5c             	add    $0x5c,%eax
80101e31:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e41:	01 d0                	add    %edx,%eax
80101e43:	8b 00                	mov    (%eax),%eax
80101e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e4c:	75 36                	jne    80101e84 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 00                	mov    (%eax),%eax
80101e53:	83 ec 0c             	sub    $0xc,%esp
80101e56:	50                   	push   %eax
80101e57:	e8 21 f7 ff ff       	call   8010157d <balloc>
80101e5c:	83 c4 10             	add    $0x10,%esp
80101e5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e6f:	01 c2                	add    %eax,%edx
80101e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e74:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	ff 75 f0             	pushl  -0x10(%ebp)
80101e7c:	e8 b3 1a 00 00       	call   80103934 <log_write>
80101e81:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e84:	83 ec 0c             	sub    $0xc,%esp
80101e87:	ff 75 f0             	pushl  -0x10(%ebp)
80101e8a:	e8 d2 e3 ff ff       	call   80100261 <brelse>
80101e8f:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e95:	eb 0d                	jmp    80101ea4 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e97:	83 ec 0c             	sub    $0xc,%esp
80101e9a:	68 3a 8e 10 80       	push   $0x80108e3a
80101e9f:	e8 64 e7 ff ff       	call   80100608 <panic>
}
80101ea4:	c9                   	leave  
80101ea5:	c3                   	ret    

80101ea6 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ea6:	f3 0f 1e fb          	endbr32 
80101eaa:	55                   	push   %ebp
80101eab:	89 e5                	mov    %esp,%ebp
80101ead:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101eb7:	eb 45                	jmp    80101efe <itrunc+0x58>
    if(ip->addrs[i]){
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebf:	83 c2 14             	add    $0x14,%edx
80101ec2:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ec6:	85 c0                	test   %eax,%eax
80101ec8:	74 30                	je     80101efa <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ed0:	83 c2 14             	add    $0x14,%edx
80101ed3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ed7:	8b 55 08             	mov    0x8(%ebp),%edx
80101eda:	8b 12                	mov    (%edx),%edx
80101edc:	83 ec 08             	sub    $0x8,%esp
80101edf:	50                   	push   %eax
80101ee0:	52                   	push   %edx
80101ee1:	e8 e7 f7 ff ff       	call   801016cd <bfree>
80101ee6:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eef:	83 c2 14             	add    $0x14,%edx
80101ef2:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ef9:	00 
  for(i = 0; i < NDIRECT; i++){
80101efa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101efe:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f02:	7e b5                	jle    80101eb9 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f0d:	85 c0                	test   %eax,%eax
80101f0f:	0f 84 aa 00 00 00    	je     80101fbf <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	8b 00                	mov    (%eax),%eax
80101f23:	83 ec 08             	sub    $0x8,%esp
80101f26:	52                   	push   %edx
80101f27:	50                   	push   %eax
80101f28:	e8 aa e2 ff ff       	call   801001d7 <bread>
80101f2d:	83 c4 10             	add    $0x10,%esp
80101f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f36:	83 c0 5c             	add    $0x5c,%eax
80101f39:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f3c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f43:	eb 3c                	jmp    80101f81 <itrunc+0xdb>
      if(a[j])
80101f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f52:	01 d0                	add    %edx,%eax
80101f54:	8b 00                	mov    (%eax),%eax
80101f56:	85 c0                	test   %eax,%eax
80101f58:	74 23                	je     80101f7d <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f67:	01 d0                	add    %edx,%eax
80101f69:	8b 00                	mov    (%eax),%eax
80101f6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f6e:	8b 12                	mov    (%edx),%edx
80101f70:	83 ec 08             	sub    $0x8,%esp
80101f73:	50                   	push   %eax
80101f74:	52                   	push   %edx
80101f75:	e8 53 f7 ff ff       	call   801016cd <bfree>
80101f7a:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f7d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f84:	83 f8 7f             	cmp    $0x7f,%eax
80101f87:	76 bc                	jbe    80101f45 <itrunc+0x9f>
    }
    brelse(bp);
80101f89:	83 ec 0c             	sub    $0xc,%esp
80101f8c:	ff 75 ec             	pushl  -0x14(%ebp)
80101f8f:	e8 cd e2 ff ff       	call   80100261 <brelse>
80101f94:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f97:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fa0:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa3:	8b 12                	mov    (%edx),%edx
80101fa5:	83 ec 08             	sub    $0x8,%esp
80101fa8:	50                   	push   %eax
80101fa9:	52                   	push   %edx
80101faa:	e8 1e f7 ff ff       	call   801016cd <bfree>
80101faf:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fbc:	00 00 00 
  }

  ip->size = 0;
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fc9:	83 ec 0c             	sub    $0xc,%esp
80101fcc:	ff 75 08             	pushl  0x8(%ebp)
80101fcf:	e8 5f f9 ff ff       	call   80101933 <iupdate>
80101fd4:	83 c4 10             	add    $0x10,%esp
}
80101fd7:	90                   	nop
80101fd8:	c9                   	leave  
80101fd9:	c3                   	ret    

80101fda <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fda:	f3 0f 1e fb          	endbr32 
80101fde:	55                   	push   %ebp
80101fdf:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 00                	mov    (%eax),%eax
80101fe6:	89 c2                	mov    %eax,%edx
80101fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101feb:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff1:	8b 50 04             	mov    0x4(%eax),%edx
80101ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff7:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffd:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102001:	8b 45 0c             	mov    0xc(%ebp),%eax
80102004:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010200e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102011:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102015:	8b 45 08             	mov    0x8(%ebp),%eax
80102018:	8b 50 58             	mov    0x58(%eax),%edx
8010201b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010201e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102021:	90                   	nop
80102022:	5d                   	pop    %ebp
80102023:	c3                   	ret    

80102024 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102024:	f3 0f 1e fb          	endbr32 
80102028:	55                   	push   %ebp
80102029:	89 e5                	mov    %esp,%ebp
8010202b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010202e:	8b 45 08             	mov    0x8(%ebp),%eax
80102031:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102035:	66 83 f8 03          	cmp    $0x3,%ax
80102039:	75 5c                	jne    80102097 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102042:	66 85 c0             	test   %ax,%ax
80102045:	78 20                	js     80102067 <readi+0x43>
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204e:	66 83 f8 09          	cmp    $0x9,%ax
80102052:	7f 13                	jg     80102067 <readi+0x43>
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205b:	98                   	cwtl   
8010205c:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102063:	85 c0                	test   %eax,%eax
80102065:	75 0a                	jne    80102071 <readi+0x4d>
      return -1;
80102067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206c:	e9 0a 01 00 00       	jmp    8010217b <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102078:	98                   	cwtl   
80102079:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102080:	8b 55 14             	mov    0x14(%ebp),%edx
80102083:	83 ec 04             	sub    $0x4,%esp
80102086:	52                   	push   %edx
80102087:	ff 75 0c             	pushl  0xc(%ebp)
8010208a:	ff 75 08             	pushl  0x8(%ebp)
8010208d:	ff d0                	call   *%eax
8010208f:	83 c4 10             	add    $0x10,%esp
80102092:	e9 e4 00 00 00       	jmp    8010217b <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102097:	8b 45 08             	mov    0x8(%ebp),%eax
8010209a:	8b 40 58             	mov    0x58(%eax),%eax
8010209d:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a0:	77 0d                	ja     801020af <readi+0x8b>
801020a2:	8b 55 10             	mov    0x10(%ebp),%edx
801020a5:	8b 45 14             	mov    0x14(%ebp),%eax
801020a8:	01 d0                	add    %edx,%eax
801020aa:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ad:	76 0a                	jbe    801020b9 <readi+0x95>
    return -1;
801020af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b4:	e9 c2 00 00 00       	jmp    8010217b <readi+0x157>
  if(off + n > ip->size)
801020b9:	8b 55 10             	mov    0x10(%ebp),%edx
801020bc:	8b 45 14             	mov    0x14(%ebp),%eax
801020bf:	01 c2                	add    %eax,%edx
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	8b 40 58             	mov    0x58(%eax),%eax
801020c7:	39 c2                	cmp    %eax,%edx
801020c9:	76 0c                	jbe    801020d7 <readi+0xb3>
    n = ip->size - off;
801020cb:	8b 45 08             	mov    0x8(%ebp),%eax
801020ce:	8b 40 58             	mov    0x58(%eax),%eax
801020d1:	2b 45 10             	sub    0x10(%ebp),%eax
801020d4:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020de:	e9 89 00 00 00       	jmp    8010216c <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e3:	8b 45 10             	mov    0x10(%ebp),%eax
801020e6:	c1 e8 09             	shr    $0x9,%eax
801020e9:	83 ec 08             	sub    $0x8,%esp
801020ec:	50                   	push   %eax
801020ed:	ff 75 08             	pushl  0x8(%ebp)
801020f0:	e8 8d fc ff ff       	call   80101d82 <bmap>
801020f5:	83 c4 10             	add    $0x10,%esp
801020f8:	8b 55 08             	mov    0x8(%ebp),%edx
801020fb:	8b 12                	mov    (%edx),%edx
801020fd:	83 ec 08             	sub    $0x8,%esp
80102100:	50                   	push   %eax
80102101:	52                   	push   %edx
80102102:	e8 d0 e0 ff ff       	call   801001d7 <bread>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210d:	8b 45 10             	mov    0x10(%ebp),%eax
80102110:	25 ff 01 00 00       	and    $0x1ff,%eax
80102115:	ba 00 02 00 00       	mov    $0x200,%edx
8010211a:	29 c2                	sub    %eax,%edx
8010211c:	8b 45 14             	mov    0x14(%ebp),%eax
8010211f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102122:	39 c2                	cmp    %eax,%edx
80102124:	0f 46 c2             	cmovbe %edx,%eax
80102127:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010212a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102130:	8b 45 10             	mov    0x10(%ebp),%eax
80102133:	25 ff 01 00 00       	and    $0x1ff,%eax
80102138:	01 d0                	add    %edx,%eax
8010213a:	83 ec 04             	sub    $0x4,%esp
8010213d:	ff 75 ec             	pushl  -0x14(%ebp)
80102140:	50                   	push   %eax
80102141:	ff 75 0c             	pushl  0xc(%ebp)
80102144:	e8 64 34 00 00       	call   801055ad <memmove>
80102149:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010214c:	83 ec 0c             	sub    $0xc,%esp
8010214f:	ff 75 f0             	pushl  -0x10(%ebp)
80102152:	e8 0a e1 ff ff       	call   80100261 <brelse>
80102157:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010215a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102160:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102163:	01 45 10             	add    %eax,0x10(%ebp)
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 0c             	add    %eax,0xc(%ebp)
8010216c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010216f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102172:	0f 82 6b ff ff ff    	jb     801020e3 <readi+0xbf>
  }
  return n;
80102178:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010217b:	c9                   	leave  
8010217c:	c3                   	ret    

8010217d <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010217d:	f3 0f 1e fb          	endbr32 
80102181:	55                   	push   %ebp
80102182:	89 e5                	mov    %esp,%ebp
80102184:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102187:	8b 45 08             	mov    0x8(%ebp),%eax
8010218a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010218e:	66 83 f8 03          	cmp    $0x3,%ax
80102192:	75 5c                	jne    801021f0 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102194:	8b 45 08             	mov    0x8(%ebp),%eax
80102197:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010219b:	66 85 c0             	test   %ax,%ax
8010219e:	78 20                	js     801021c0 <writei+0x43>
801021a0:	8b 45 08             	mov    0x8(%ebp),%eax
801021a3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021a7:	66 83 f8 09          	cmp    $0x9,%ax
801021ab:	7f 13                	jg     801021c0 <writei+0x43>
801021ad:	8b 45 08             	mov    0x8(%ebp),%eax
801021b0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021b4:	98                   	cwtl   
801021b5:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021bc:	85 c0                	test   %eax,%eax
801021be:	75 0a                	jne    801021ca <writei+0x4d>
      return -1;
801021c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c5:	e9 3b 01 00 00       	jmp    80102305 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021ca:	8b 45 08             	mov    0x8(%ebp),%eax
801021cd:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021d1:	98                   	cwtl   
801021d2:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021d9:	8b 55 14             	mov    0x14(%ebp),%edx
801021dc:	83 ec 04             	sub    $0x4,%esp
801021df:	52                   	push   %edx
801021e0:	ff 75 0c             	pushl  0xc(%ebp)
801021e3:	ff 75 08             	pushl  0x8(%ebp)
801021e6:	ff d0                	call   *%eax
801021e8:	83 c4 10             	add    $0x10,%esp
801021eb:	e9 15 01 00 00       	jmp    80102305 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021f0:	8b 45 08             	mov    0x8(%ebp),%eax
801021f3:	8b 40 58             	mov    0x58(%eax),%eax
801021f6:	39 45 10             	cmp    %eax,0x10(%ebp)
801021f9:	77 0d                	ja     80102208 <writei+0x8b>
801021fb:	8b 55 10             	mov    0x10(%ebp),%edx
801021fe:	8b 45 14             	mov    0x14(%ebp),%eax
80102201:	01 d0                	add    %edx,%eax
80102203:	39 45 10             	cmp    %eax,0x10(%ebp)
80102206:	76 0a                	jbe    80102212 <writei+0x95>
    return -1;
80102208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010220d:	e9 f3 00 00 00       	jmp    80102305 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102212:	8b 55 10             	mov    0x10(%ebp),%edx
80102215:	8b 45 14             	mov    0x14(%ebp),%eax
80102218:	01 d0                	add    %edx,%eax
8010221a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010221f:	76 0a                	jbe    8010222b <writei+0xae>
    return -1;
80102221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102226:	e9 da 00 00 00       	jmp    80102305 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010222b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102232:	e9 97 00 00 00       	jmp    801022ce <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102237:	8b 45 10             	mov    0x10(%ebp),%eax
8010223a:	c1 e8 09             	shr    $0x9,%eax
8010223d:	83 ec 08             	sub    $0x8,%esp
80102240:	50                   	push   %eax
80102241:	ff 75 08             	pushl  0x8(%ebp)
80102244:	e8 39 fb ff ff       	call   80101d82 <bmap>
80102249:	83 c4 10             	add    $0x10,%esp
8010224c:	8b 55 08             	mov    0x8(%ebp),%edx
8010224f:	8b 12                	mov    (%edx),%edx
80102251:	83 ec 08             	sub    $0x8,%esp
80102254:	50                   	push   %eax
80102255:	52                   	push   %edx
80102256:	e8 7c df ff ff       	call   801001d7 <bread>
8010225b:	83 c4 10             	add    $0x10,%esp
8010225e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102261:	8b 45 10             	mov    0x10(%ebp),%eax
80102264:	25 ff 01 00 00       	and    $0x1ff,%eax
80102269:	ba 00 02 00 00       	mov    $0x200,%edx
8010226e:	29 c2                	sub    %eax,%edx
80102270:	8b 45 14             	mov    0x14(%ebp),%eax
80102273:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102276:	39 c2                	cmp    %eax,%edx
80102278:	0f 46 c2             	cmovbe %edx,%eax
8010227b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010227e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102281:	8d 50 5c             	lea    0x5c(%eax),%edx
80102284:	8b 45 10             	mov    0x10(%ebp),%eax
80102287:	25 ff 01 00 00       	and    $0x1ff,%eax
8010228c:	01 d0                	add    %edx,%eax
8010228e:	83 ec 04             	sub    $0x4,%esp
80102291:	ff 75 ec             	pushl  -0x14(%ebp)
80102294:	ff 75 0c             	pushl  0xc(%ebp)
80102297:	50                   	push   %eax
80102298:	e8 10 33 00 00       	call   801055ad <memmove>
8010229d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022a0:	83 ec 0c             	sub    $0xc,%esp
801022a3:	ff 75 f0             	pushl  -0x10(%ebp)
801022a6:	e8 89 16 00 00       	call   80103934 <log_write>
801022ab:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022ae:	83 ec 0c             	sub    $0xc,%esp
801022b1:	ff 75 f0             	pushl  -0x10(%ebp)
801022b4:	e8 a8 df ff ff       	call   80100261 <brelse>
801022b9:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022bf:	01 45 f4             	add    %eax,-0xc(%ebp)
801022c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c5:	01 45 10             	add    %eax,0x10(%ebp)
801022c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022cb:	01 45 0c             	add    %eax,0xc(%ebp)
801022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d1:	3b 45 14             	cmp    0x14(%ebp),%eax
801022d4:	0f 82 5d ff ff ff    	jb     80102237 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022da:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022de:	74 22                	je     80102302 <writei+0x185>
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	8b 40 58             	mov    0x58(%eax),%eax
801022e6:	39 45 10             	cmp    %eax,0x10(%ebp)
801022e9:	76 17                	jbe    80102302 <writei+0x185>
    ip->size = off;
801022eb:	8b 45 08             	mov    0x8(%ebp),%eax
801022ee:	8b 55 10             	mov    0x10(%ebp),%edx
801022f1:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022f4:	83 ec 0c             	sub    $0xc,%esp
801022f7:	ff 75 08             	pushl  0x8(%ebp)
801022fa:	e8 34 f6 ff ff       	call   80101933 <iupdate>
801022ff:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102302:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102305:	c9                   	leave  
80102306:	c3                   	ret    

80102307 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102307:	f3 0f 1e fb          	endbr32 
8010230b:	55                   	push   %ebp
8010230c:	89 e5                	mov    %esp,%ebp
8010230e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102311:	83 ec 04             	sub    $0x4,%esp
80102314:	6a 0e                	push   $0xe
80102316:	ff 75 0c             	pushl  0xc(%ebp)
80102319:	ff 75 08             	pushl  0x8(%ebp)
8010231c:	e8 2a 33 00 00       	call   8010564b <strncmp>
80102321:	83 c4 10             	add    $0x10,%esp
}
80102324:	c9                   	leave  
80102325:	c3                   	ret    

80102326 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102326:	f3 0f 1e fb          	endbr32 
8010232a:	55                   	push   %ebp
8010232b:	89 e5                	mov    %esp,%ebp
8010232d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102330:	8b 45 08             	mov    0x8(%ebp),%eax
80102333:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102337:	66 83 f8 01          	cmp    $0x1,%ax
8010233b:	74 0d                	je     8010234a <dirlookup+0x24>
    panic("dirlookup not DIR");
8010233d:	83 ec 0c             	sub    $0xc,%esp
80102340:	68 4d 8e 10 80       	push   $0x80108e4d
80102345:	e8 be e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010234a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102351:	eb 7b                	jmp    801023ce <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102353:	6a 10                	push   $0x10
80102355:	ff 75 f4             	pushl  -0xc(%ebp)
80102358:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010235b:	50                   	push   %eax
8010235c:	ff 75 08             	pushl  0x8(%ebp)
8010235f:	e8 c0 fc ff ff       	call   80102024 <readi>
80102364:	83 c4 10             	add    $0x10,%esp
80102367:	83 f8 10             	cmp    $0x10,%eax
8010236a:	74 0d                	je     80102379 <dirlookup+0x53>
      panic("dirlookup read");
8010236c:	83 ec 0c             	sub    $0xc,%esp
8010236f:	68 5f 8e 10 80       	push   $0x80108e5f
80102374:	e8 8f e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102379:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010237d:	66 85 c0             	test   %ax,%ax
80102380:	74 47                	je     801023c9 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102382:	83 ec 08             	sub    $0x8,%esp
80102385:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102388:	83 c0 02             	add    $0x2,%eax
8010238b:	50                   	push   %eax
8010238c:	ff 75 0c             	pushl  0xc(%ebp)
8010238f:	e8 73 ff ff ff       	call   80102307 <namecmp>
80102394:	83 c4 10             	add    $0x10,%esp
80102397:	85 c0                	test   %eax,%eax
80102399:	75 2f                	jne    801023ca <dirlookup+0xa4>
      // entry matches path element
      if(poff)
8010239b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010239f:	74 08                	je     801023a9 <dirlookup+0x83>
        *poff = off;
801023a1:	8b 45 10             	mov    0x10(%ebp),%eax
801023a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023a7:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023a9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ad:	0f b7 c0             	movzwl %ax,%eax
801023b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	8b 00                	mov    (%eax),%eax
801023b8:	83 ec 08             	sub    $0x8,%esp
801023bb:	ff 75 f0             	pushl  -0x10(%ebp)
801023be:	50                   	push   %eax
801023bf:	e8 34 f6 ff ff       	call   801019f8 <iget>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 19                	jmp    801023e2 <dirlookup+0xbc>
      continue;
801023c9:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ca:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023ce:	8b 45 08             	mov    0x8(%ebp),%eax
801023d1:	8b 40 58             	mov    0x58(%eax),%eax
801023d4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023d7:	0f 82 76 ff ff ff    	jb     80102353 <dirlookup+0x2d>
    }
  }

  return 0;
801023dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023e2:	c9                   	leave  
801023e3:	c3                   	ret    

801023e4 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023e4:	f3 0f 1e fb          	endbr32 
801023e8:	55                   	push   %ebp
801023e9:	89 e5                	mov    %esp,%ebp
801023eb:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023ee:	83 ec 04             	sub    $0x4,%esp
801023f1:	6a 00                	push   $0x0
801023f3:	ff 75 0c             	pushl  0xc(%ebp)
801023f6:	ff 75 08             	pushl  0x8(%ebp)
801023f9:	e8 28 ff ff ff       	call   80102326 <dirlookup>
801023fe:	83 c4 10             	add    $0x10,%esp
80102401:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102408:	74 18                	je     80102422 <dirlink+0x3e>
    iput(ip);
8010240a:	83 ec 0c             	sub    $0xc,%esp
8010240d:	ff 75 f0             	pushl  -0x10(%ebp)
80102410:	e8 70 f8 ff ff       	call   80101c85 <iput>
80102415:	83 c4 10             	add    $0x10,%esp
    return -1;
80102418:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010241d:	e9 9c 00 00 00       	jmp    801024be <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102422:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102429:	eb 39                	jmp    80102464 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010242b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242e:	6a 10                	push   $0x10
80102430:	50                   	push   %eax
80102431:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102434:	50                   	push   %eax
80102435:	ff 75 08             	pushl  0x8(%ebp)
80102438:	e8 e7 fb ff ff       	call   80102024 <readi>
8010243d:	83 c4 10             	add    $0x10,%esp
80102440:	83 f8 10             	cmp    $0x10,%eax
80102443:	74 0d                	je     80102452 <dirlink+0x6e>
      panic("dirlink read");
80102445:	83 ec 0c             	sub    $0xc,%esp
80102448:	68 6e 8e 10 80       	push   $0x80108e6e
8010244d:	e8 b6 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102452:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102456:	66 85 c0             	test   %ax,%ax
80102459:	74 18                	je     80102473 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	83 c0 10             	add    $0x10,%eax
80102461:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102464:	8b 45 08             	mov    0x8(%ebp),%eax
80102467:	8b 50 58             	mov    0x58(%eax),%edx
8010246a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246d:	39 c2                	cmp    %eax,%edx
8010246f:	77 ba                	ja     8010242b <dirlink+0x47>
80102471:	eb 01                	jmp    80102474 <dirlink+0x90>
      break;
80102473:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102474:	83 ec 04             	sub    $0x4,%esp
80102477:	6a 0e                	push   $0xe
80102479:	ff 75 0c             	pushl  0xc(%ebp)
8010247c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010247f:	83 c0 02             	add    $0x2,%eax
80102482:	50                   	push   %eax
80102483:	e8 1d 32 00 00       	call   801056a5 <strncpy>
80102488:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010248b:	8b 45 10             	mov    0x10(%ebp),%eax
8010248e:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	6a 10                	push   $0x10
80102497:	50                   	push   %eax
80102498:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010249b:	50                   	push   %eax
8010249c:	ff 75 08             	pushl  0x8(%ebp)
8010249f:	e8 d9 fc ff ff       	call   8010217d <writei>
801024a4:	83 c4 10             	add    $0x10,%esp
801024a7:	83 f8 10             	cmp    $0x10,%eax
801024aa:	74 0d                	je     801024b9 <dirlink+0xd5>
    panic("dirlink");
801024ac:	83 ec 0c             	sub    $0xc,%esp
801024af:	68 7b 8e 10 80       	push   $0x80108e7b
801024b4:	e8 4f e1 ff ff       	call   80100608 <panic>

  return 0;
801024b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024be:	c9                   	leave  
801024bf:	c3                   	ret    

801024c0 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024c0:	f3 0f 1e fb          	endbr32 
801024c4:	55                   	push   %ebp
801024c5:	89 e5                	mov    %esp,%ebp
801024c7:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024ca:	eb 04                	jmp    801024d0 <skipelem+0x10>
    path++;
801024cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024d0:	8b 45 08             	mov    0x8(%ebp),%eax
801024d3:	0f b6 00             	movzbl (%eax),%eax
801024d6:	3c 2f                	cmp    $0x2f,%al
801024d8:	74 f2                	je     801024cc <skipelem+0xc>
  if(*path == 0)
801024da:	8b 45 08             	mov    0x8(%ebp),%eax
801024dd:	0f b6 00             	movzbl (%eax),%eax
801024e0:	84 c0                	test   %al,%al
801024e2:	75 07                	jne    801024eb <skipelem+0x2b>
    return 0;
801024e4:	b8 00 00 00 00       	mov    $0x0,%eax
801024e9:	eb 77                	jmp    80102562 <skipelem+0xa2>
  s = path;
801024eb:	8b 45 08             	mov    0x8(%ebp),%eax
801024ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024f1:	eb 04                	jmp    801024f7 <skipelem+0x37>
    path++;
801024f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024f7:	8b 45 08             	mov    0x8(%ebp),%eax
801024fa:	0f b6 00             	movzbl (%eax),%eax
801024fd:	3c 2f                	cmp    $0x2f,%al
801024ff:	74 0a                	je     8010250b <skipelem+0x4b>
80102501:	8b 45 08             	mov    0x8(%ebp),%eax
80102504:	0f b6 00             	movzbl (%eax),%eax
80102507:	84 c0                	test   %al,%al
80102509:	75 e8                	jne    801024f3 <skipelem+0x33>
  len = path - s;
8010250b:	8b 45 08             	mov    0x8(%ebp),%eax
8010250e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102511:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102514:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102518:	7e 15                	jle    8010252f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010251a:	83 ec 04             	sub    $0x4,%esp
8010251d:	6a 0e                	push   $0xe
8010251f:	ff 75 f4             	pushl  -0xc(%ebp)
80102522:	ff 75 0c             	pushl  0xc(%ebp)
80102525:	e8 83 30 00 00       	call   801055ad <memmove>
8010252a:	83 c4 10             	add    $0x10,%esp
8010252d:	eb 26                	jmp    80102555 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010252f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102532:	83 ec 04             	sub    $0x4,%esp
80102535:	50                   	push   %eax
80102536:	ff 75 f4             	pushl  -0xc(%ebp)
80102539:	ff 75 0c             	pushl  0xc(%ebp)
8010253c:	e8 6c 30 00 00       	call   801055ad <memmove>
80102541:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102544:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010254a:	01 d0                	add    %edx,%eax
8010254c:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010254f:	eb 04                	jmp    80102555 <skipelem+0x95>
    path++;
80102551:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102555:	8b 45 08             	mov    0x8(%ebp),%eax
80102558:	0f b6 00             	movzbl (%eax),%eax
8010255b:	3c 2f                	cmp    $0x2f,%al
8010255d:	74 f2                	je     80102551 <skipelem+0x91>
  return path;
8010255f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102562:	c9                   	leave  
80102563:	c3                   	ret    

80102564 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102564:	f3 0f 1e fb          	endbr32 
80102568:	55                   	push   %ebp
80102569:	89 e5                	mov    %esp,%ebp
8010256b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010256e:	8b 45 08             	mov    0x8(%ebp),%eax
80102571:	0f b6 00             	movzbl (%eax),%eax
80102574:	3c 2f                	cmp    $0x2f,%al
80102576:	75 17                	jne    8010258f <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102578:	83 ec 08             	sub    $0x8,%esp
8010257b:	6a 01                	push   $0x1
8010257d:	6a 01                	push   $0x1
8010257f:	e8 74 f4 ff ff       	call   801019f8 <iget>
80102584:	83 c4 10             	add    $0x10,%esp
80102587:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010258a:	e9 ba 00 00 00       	jmp    80102649 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010258f:	e8 16 1f 00 00       	call   801044aa <myproc>
80102594:	8b 40 68             	mov    0x68(%eax),%eax
80102597:	83 ec 0c             	sub    $0xc,%esp
8010259a:	50                   	push   %eax
8010259b:	e8 3e f5 ff ff       	call   80101ade <idup>
801025a0:	83 c4 10             	add    $0x10,%esp
801025a3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025a6:	e9 9e 00 00 00       	jmp    80102649 <namex+0xe5>
    ilock(ip);
801025ab:	83 ec 0c             	sub    $0xc,%esp
801025ae:	ff 75 f4             	pushl  -0xc(%ebp)
801025b1:	e8 66 f5 ff ff       	call   80101b1c <ilock>
801025b6:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025bc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025c0:	66 83 f8 01          	cmp    $0x1,%ax
801025c4:	74 18                	je     801025de <namex+0x7a>
      iunlockput(ip);
801025c6:	83 ec 0c             	sub    $0xc,%esp
801025c9:	ff 75 f4             	pushl  -0xc(%ebp)
801025cc:	e8 88 f7 ff ff       	call   80101d59 <iunlockput>
801025d1:	83 c4 10             	add    $0x10,%esp
      return 0;
801025d4:	b8 00 00 00 00       	mov    $0x0,%eax
801025d9:	e9 a7 00 00 00       	jmp    80102685 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025e2:	74 20                	je     80102604 <namex+0xa0>
801025e4:	8b 45 08             	mov    0x8(%ebp),%eax
801025e7:	0f b6 00             	movzbl (%eax),%eax
801025ea:	84 c0                	test   %al,%al
801025ec:	75 16                	jne    80102604 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025ee:	83 ec 0c             	sub    $0xc,%esp
801025f1:	ff 75 f4             	pushl  -0xc(%ebp)
801025f4:	e8 3a f6 ff ff       	call   80101c33 <iunlock>
801025f9:	83 c4 10             	add    $0x10,%esp
      return ip;
801025fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ff:	e9 81 00 00 00       	jmp    80102685 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102604:	83 ec 04             	sub    $0x4,%esp
80102607:	6a 00                	push   $0x0
80102609:	ff 75 10             	pushl  0x10(%ebp)
8010260c:	ff 75 f4             	pushl  -0xc(%ebp)
8010260f:	e8 12 fd ff ff       	call   80102326 <dirlookup>
80102614:	83 c4 10             	add    $0x10,%esp
80102617:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010261a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010261e:	75 15                	jne    80102635 <namex+0xd1>
      iunlockput(ip);
80102620:	83 ec 0c             	sub    $0xc,%esp
80102623:	ff 75 f4             	pushl  -0xc(%ebp)
80102626:	e8 2e f7 ff ff       	call   80101d59 <iunlockput>
8010262b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010262e:	b8 00 00 00 00       	mov    $0x0,%eax
80102633:	eb 50                	jmp    80102685 <namex+0x121>
    }
    iunlockput(ip);
80102635:	83 ec 0c             	sub    $0xc,%esp
80102638:	ff 75 f4             	pushl  -0xc(%ebp)
8010263b:	e8 19 f7 ff ff       	call   80101d59 <iunlockput>
80102640:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102643:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102646:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102649:	83 ec 08             	sub    $0x8,%esp
8010264c:	ff 75 10             	pushl  0x10(%ebp)
8010264f:	ff 75 08             	pushl  0x8(%ebp)
80102652:	e8 69 fe ff ff       	call   801024c0 <skipelem>
80102657:	83 c4 10             	add    $0x10,%esp
8010265a:	89 45 08             	mov    %eax,0x8(%ebp)
8010265d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102661:	0f 85 44 ff ff ff    	jne    801025ab <namex+0x47>
  }
  if(nameiparent){
80102667:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010266b:	74 15                	je     80102682 <namex+0x11e>
    iput(ip);
8010266d:	83 ec 0c             	sub    $0xc,%esp
80102670:	ff 75 f4             	pushl  -0xc(%ebp)
80102673:	e8 0d f6 ff ff       	call   80101c85 <iput>
80102678:	83 c4 10             	add    $0x10,%esp
    return 0;
8010267b:	b8 00 00 00 00       	mov    $0x0,%eax
80102680:	eb 03                	jmp    80102685 <namex+0x121>
  }
  return ip;
80102682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102685:	c9                   	leave  
80102686:	c3                   	ret    

80102687 <namei>:

struct inode*
namei(char *path)
{
80102687:	f3 0f 1e fb          	endbr32 
8010268b:	55                   	push   %ebp
8010268c:	89 e5                	mov    %esp,%ebp
8010268e:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102691:	83 ec 04             	sub    $0x4,%esp
80102694:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102697:	50                   	push   %eax
80102698:	6a 00                	push   $0x0
8010269a:	ff 75 08             	pushl  0x8(%ebp)
8010269d:	e8 c2 fe ff ff       	call   80102564 <namex>
801026a2:	83 c4 10             	add    $0x10,%esp
}
801026a5:	c9                   	leave  
801026a6:	c3                   	ret    

801026a7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026a7:	f3 0f 1e fb          	endbr32 
801026ab:	55                   	push   %ebp
801026ac:	89 e5                	mov    %esp,%ebp
801026ae:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026b1:	83 ec 04             	sub    $0x4,%esp
801026b4:	ff 75 0c             	pushl  0xc(%ebp)
801026b7:	6a 01                	push   $0x1
801026b9:	ff 75 08             	pushl  0x8(%ebp)
801026bc:	e8 a3 fe ff ff       	call   80102564 <namex>
801026c1:	83 c4 10             	add    $0x10,%esp
}
801026c4:	c9                   	leave  
801026c5:	c3                   	ret    

801026c6 <inb>:
{
801026c6:	55                   	push   %ebp
801026c7:	89 e5                	mov    %esp,%ebp
801026c9:	83 ec 14             	sub    $0x14,%esp
801026cc:	8b 45 08             	mov    0x8(%ebp),%eax
801026cf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026d3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026d7:	89 c2                	mov    %eax,%edx
801026d9:	ec                   	in     (%dx),%al
801026da:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026dd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026e1:	c9                   	leave  
801026e2:	c3                   	ret    

801026e3 <insl>:
{
801026e3:	55                   	push   %ebp
801026e4:	89 e5                	mov    %esp,%ebp
801026e6:	57                   	push   %edi
801026e7:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026e8:	8b 55 08             	mov    0x8(%ebp),%edx
801026eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026ee:	8b 45 10             	mov    0x10(%ebp),%eax
801026f1:	89 cb                	mov    %ecx,%ebx
801026f3:	89 df                	mov    %ebx,%edi
801026f5:	89 c1                	mov    %eax,%ecx
801026f7:	fc                   	cld    
801026f8:	f3 6d                	rep insl (%dx),%es:(%edi)
801026fa:	89 c8                	mov    %ecx,%eax
801026fc:	89 fb                	mov    %edi,%ebx
801026fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102701:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102704:	90                   	nop
80102705:	5b                   	pop    %ebx
80102706:	5f                   	pop    %edi
80102707:	5d                   	pop    %ebp
80102708:	c3                   	ret    

80102709 <outb>:
{
80102709:	55                   	push   %ebp
8010270a:	89 e5                	mov    %esp,%ebp
8010270c:	83 ec 08             	sub    $0x8,%esp
8010270f:	8b 45 08             	mov    0x8(%ebp),%eax
80102712:	8b 55 0c             	mov    0xc(%ebp),%edx
80102715:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102719:	89 d0                	mov    %edx,%eax
8010271b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010271e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102722:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102726:	ee                   	out    %al,(%dx)
}
80102727:	90                   	nop
80102728:	c9                   	leave  
80102729:	c3                   	ret    

8010272a <outsl>:
{
8010272a:	55                   	push   %ebp
8010272b:	89 e5                	mov    %esp,%ebp
8010272d:	56                   	push   %esi
8010272e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010272f:	8b 55 08             	mov    0x8(%ebp),%edx
80102732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102735:	8b 45 10             	mov    0x10(%ebp),%eax
80102738:	89 cb                	mov    %ecx,%ebx
8010273a:	89 de                	mov    %ebx,%esi
8010273c:	89 c1                	mov    %eax,%ecx
8010273e:	fc                   	cld    
8010273f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102741:	89 c8                	mov    %ecx,%eax
80102743:	89 f3                	mov    %esi,%ebx
80102745:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102748:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010274b:	90                   	nop
8010274c:	5b                   	pop    %ebx
8010274d:	5e                   	pop    %esi
8010274e:	5d                   	pop    %ebp
8010274f:	c3                   	ret    

80102750 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102750:	f3 0f 1e fb          	endbr32 
80102754:	55                   	push   %ebp
80102755:	89 e5                	mov    %esp,%ebp
80102757:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010275a:	90                   	nop
8010275b:	68 f7 01 00 00       	push   $0x1f7
80102760:	e8 61 ff ff ff       	call   801026c6 <inb>
80102765:	83 c4 04             	add    $0x4,%esp
80102768:	0f b6 c0             	movzbl %al,%eax
8010276b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010276e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102771:	25 c0 00 00 00       	and    $0xc0,%eax
80102776:	83 f8 40             	cmp    $0x40,%eax
80102779:	75 e0                	jne    8010275b <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010277b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010277f:	74 11                	je     80102792 <idewait+0x42>
80102781:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102784:	83 e0 21             	and    $0x21,%eax
80102787:	85 c0                	test   %eax,%eax
80102789:	74 07                	je     80102792 <idewait+0x42>
    return -1;
8010278b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102790:	eb 05                	jmp    80102797 <idewait+0x47>
  return 0;
80102792:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102797:	c9                   	leave  
80102798:	c3                   	ret    

80102799 <ideinit>:

void
ideinit(void)
{
80102799:	f3 0f 1e fb          	endbr32 
8010279d:	55                   	push   %ebp
8010279e:	89 e5                	mov    %esp,%ebp
801027a0:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027a3:	83 ec 08             	sub    $0x8,%esp
801027a6:	68 83 8e 10 80       	push   $0x80108e83
801027ab:	68 00 c6 10 80       	push   $0x8010c600
801027b0:	e8 6c 2a 00 00       	call   80105221 <initlock>
801027b5:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027b8:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027bd:	83 e8 01             	sub    $0x1,%eax
801027c0:	83 ec 08             	sub    $0x8,%esp
801027c3:	50                   	push   %eax
801027c4:	6a 0e                	push   $0xe
801027c6:	e8 bb 04 00 00       	call   80102c86 <ioapicenable>
801027cb:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	6a 00                	push   $0x0
801027d3:	e8 78 ff ff ff       	call   80102750 <idewait>
801027d8:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027db:	83 ec 08             	sub    $0x8,%esp
801027de:	68 f0 00 00 00       	push   $0xf0
801027e3:	68 f6 01 00 00       	push   $0x1f6
801027e8:	e8 1c ff ff ff       	call   80102709 <outb>
801027ed:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027f7:	eb 24                	jmp    8010281d <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027f9:	83 ec 0c             	sub    $0xc,%esp
801027fc:	68 f7 01 00 00       	push   $0x1f7
80102801:	e8 c0 fe ff ff       	call   801026c6 <inb>
80102806:	83 c4 10             	add    $0x10,%esp
80102809:	84 c0                	test   %al,%al
8010280b:	74 0c                	je     80102819 <ideinit+0x80>
      havedisk1 = 1;
8010280d:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102814:	00 00 00 
      break;
80102817:	eb 0d                	jmp    80102826 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102819:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010281d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102824:	7e d3                	jle    801027f9 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102826:	83 ec 08             	sub    $0x8,%esp
80102829:	68 e0 00 00 00       	push   $0xe0
8010282e:	68 f6 01 00 00       	push   $0x1f6
80102833:	e8 d1 fe ff ff       	call   80102709 <outb>
80102838:	83 c4 10             	add    $0x10,%esp
}
8010283b:	90                   	nop
8010283c:	c9                   	leave  
8010283d:	c3                   	ret    

8010283e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010283e:	f3 0f 1e fb          	endbr32 
80102842:	55                   	push   %ebp
80102843:	89 e5                	mov    %esp,%ebp
80102845:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102848:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010284c:	75 0d                	jne    8010285b <idestart+0x1d>
    panic("idestart");
8010284e:	83 ec 0c             	sub    $0xc,%esp
80102851:	68 87 8e 10 80       	push   $0x80108e87
80102856:	e8 ad dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
8010285b:	8b 45 08             	mov    0x8(%ebp),%eax
8010285e:	8b 40 08             	mov    0x8(%eax),%eax
80102861:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102866:	76 0d                	jbe    80102875 <idestart+0x37>
    panic("incorrect blockno");
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 90 8e 10 80       	push   $0x80108e90
80102870:	e8 93 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102875:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010287c:	8b 45 08             	mov    0x8(%ebp),%eax
8010287f:	8b 50 08             	mov    0x8(%eax),%edx
80102882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102885:	0f af c2             	imul   %edx,%eax
80102888:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010288b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010288f:	75 07                	jne    80102898 <idestart+0x5a>
80102891:	b8 20 00 00 00       	mov    $0x20,%eax
80102896:	eb 05                	jmp    8010289d <idestart+0x5f>
80102898:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010289d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028a0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028a4:	75 07                	jne    801028ad <idestart+0x6f>
801028a6:	b8 30 00 00 00       	mov    $0x30,%eax
801028ab:	eb 05                	jmp    801028b2 <idestart+0x74>
801028ad:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028b2:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028b5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028b9:	7e 0d                	jle    801028c8 <idestart+0x8a>
801028bb:	83 ec 0c             	sub    $0xc,%esp
801028be:	68 87 8e 10 80       	push   $0x80108e87
801028c3:	e8 40 dd ff ff       	call   80100608 <panic>

  idewait(0);
801028c8:	83 ec 0c             	sub    $0xc,%esp
801028cb:	6a 00                	push   $0x0
801028cd:	e8 7e fe ff ff       	call   80102750 <idewait>
801028d2:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028d5:	83 ec 08             	sub    $0x8,%esp
801028d8:	6a 00                	push   $0x0
801028da:	68 f6 03 00 00       	push   $0x3f6
801028df:	e8 25 fe ff ff       	call   80102709 <outb>
801028e4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ea:	0f b6 c0             	movzbl %al,%eax
801028ed:	83 ec 08             	sub    $0x8,%esp
801028f0:	50                   	push   %eax
801028f1:	68 f2 01 00 00       	push   $0x1f2
801028f6:	e8 0e fe ff ff       	call   80102709 <outb>
801028fb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801028fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102901:	0f b6 c0             	movzbl %al,%eax
80102904:	83 ec 08             	sub    $0x8,%esp
80102907:	50                   	push   %eax
80102908:	68 f3 01 00 00       	push   $0x1f3
8010290d:	e8 f7 fd ff ff       	call   80102709 <outb>
80102912:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102918:	c1 f8 08             	sar    $0x8,%eax
8010291b:	0f b6 c0             	movzbl %al,%eax
8010291e:	83 ec 08             	sub    $0x8,%esp
80102921:	50                   	push   %eax
80102922:	68 f4 01 00 00       	push   $0x1f4
80102927:	e8 dd fd ff ff       	call   80102709 <outb>
8010292c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010292f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102932:	c1 f8 10             	sar    $0x10,%eax
80102935:	0f b6 c0             	movzbl %al,%eax
80102938:	83 ec 08             	sub    $0x8,%esp
8010293b:	50                   	push   %eax
8010293c:	68 f5 01 00 00       	push   $0x1f5
80102941:	e8 c3 fd ff ff       	call   80102709 <outb>
80102946:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102949:	8b 45 08             	mov    0x8(%ebp),%eax
8010294c:	8b 40 04             	mov    0x4(%eax),%eax
8010294f:	c1 e0 04             	shl    $0x4,%eax
80102952:	83 e0 10             	and    $0x10,%eax
80102955:	89 c2                	mov    %eax,%edx
80102957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010295a:	c1 f8 18             	sar    $0x18,%eax
8010295d:	83 e0 0f             	and    $0xf,%eax
80102960:	09 d0                	or     %edx,%eax
80102962:	83 c8 e0             	or     $0xffffffe0,%eax
80102965:	0f b6 c0             	movzbl %al,%eax
80102968:	83 ec 08             	sub    $0x8,%esp
8010296b:	50                   	push   %eax
8010296c:	68 f6 01 00 00       	push   $0x1f6
80102971:	e8 93 fd ff ff       	call   80102709 <outb>
80102976:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102979:	8b 45 08             	mov    0x8(%ebp),%eax
8010297c:	8b 00                	mov    (%eax),%eax
8010297e:	83 e0 04             	and    $0x4,%eax
80102981:	85 c0                	test   %eax,%eax
80102983:	74 35                	je     801029ba <idestart+0x17c>
    outb(0x1f7, write_cmd);
80102985:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102988:	0f b6 c0             	movzbl %al,%eax
8010298b:	83 ec 08             	sub    $0x8,%esp
8010298e:	50                   	push   %eax
8010298f:	68 f7 01 00 00       	push   $0x1f7
80102994:	e8 70 fd ff ff       	call   80102709 <outb>
80102999:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010299c:	8b 45 08             	mov    0x8(%ebp),%eax
8010299f:	83 c0 5c             	add    $0x5c,%eax
801029a2:	83 ec 04             	sub    $0x4,%esp
801029a5:	68 80 00 00 00       	push   $0x80
801029aa:	50                   	push   %eax
801029ab:	68 f0 01 00 00       	push   $0x1f0
801029b0:	e8 75 fd ff ff       	call   8010272a <outsl>
801029b5:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029b8:	eb 17                	jmp    801029d1 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029bd:	0f b6 c0             	movzbl %al,%eax
801029c0:	83 ec 08             	sub    $0x8,%esp
801029c3:	50                   	push   %eax
801029c4:	68 f7 01 00 00       	push   $0x1f7
801029c9:	e8 3b fd ff ff       	call   80102709 <outb>
801029ce:	83 c4 10             	add    $0x10,%esp
}
801029d1:	90                   	nop
801029d2:	c9                   	leave  
801029d3:	c3                   	ret    

801029d4 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029d4:	f3 0f 1e fb          	endbr32 
801029d8:	55                   	push   %ebp
801029d9:	89 e5                	mov    %esp,%ebp
801029db:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029de:	83 ec 0c             	sub    $0xc,%esp
801029e1:	68 00 c6 10 80       	push   $0x8010c600
801029e6:	e8 5c 28 00 00       	call   80105247 <acquire>
801029eb:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029ee:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029fa:	75 15                	jne    80102a11 <ideintr+0x3d>
    release(&idelock);
801029fc:	83 ec 0c             	sub    $0xc,%esp
801029ff:	68 00 c6 10 80       	push   $0x8010c600
80102a04:	e8 b0 28 00 00       	call   801052b9 <release>
80102a09:	83 c4 10             	add    $0x10,%esp
    return;
80102a0c:	e9 9a 00 00 00       	jmp    80102aab <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a14:	8b 40 58             	mov    0x58(%eax),%eax
80102a17:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1f:	8b 00                	mov    (%eax),%eax
80102a21:	83 e0 04             	and    $0x4,%eax
80102a24:	85 c0                	test   %eax,%eax
80102a26:	75 2d                	jne    80102a55 <ideintr+0x81>
80102a28:	83 ec 0c             	sub    $0xc,%esp
80102a2b:	6a 01                	push   $0x1
80102a2d:	e8 1e fd ff ff       	call   80102750 <idewait>
80102a32:	83 c4 10             	add    $0x10,%esp
80102a35:	85 c0                	test   %eax,%eax
80102a37:	78 1c                	js     80102a55 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3c:	83 c0 5c             	add    $0x5c,%eax
80102a3f:	83 ec 04             	sub    $0x4,%esp
80102a42:	68 80 00 00 00       	push   $0x80
80102a47:	50                   	push   %eax
80102a48:	68 f0 01 00 00       	push   $0x1f0
80102a4d:	e8 91 fc ff ff       	call   801026e3 <insl>
80102a52:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a58:	8b 00                	mov    (%eax),%eax
80102a5a:	83 c8 02             	or     $0x2,%eax
80102a5d:	89 c2                	mov    %eax,%edx
80102a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a62:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a67:	8b 00                	mov    (%eax),%eax
80102a69:	83 e0 fb             	and    $0xfffffffb,%eax
80102a6c:	89 c2                	mov    %eax,%edx
80102a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a71:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a73:	83 ec 0c             	sub    $0xc,%esp
80102a76:	ff 75 f4             	pushl  -0xc(%ebp)
80102a79:	e8 4f 24 00 00       	call   80104ecd <wakeup>
80102a7e:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a81:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a86:	85 c0                	test   %eax,%eax
80102a88:	74 11                	je     80102a9b <ideintr+0xc7>
    idestart(idequeue);
80102a8a:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a8f:	83 ec 0c             	sub    $0xc,%esp
80102a92:	50                   	push   %eax
80102a93:	e8 a6 fd ff ff       	call   8010283e <idestart>
80102a98:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a9b:	83 ec 0c             	sub    $0xc,%esp
80102a9e:	68 00 c6 10 80       	push   $0x8010c600
80102aa3:	e8 11 28 00 00       	call   801052b9 <release>
80102aa8:	83 c4 10             	add    $0x10,%esp
}
80102aab:	c9                   	leave  
80102aac:	c3                   	ret    

80102aad <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102aad:	f3 0f 1e fb          	endbr32 
80102ab1:	55                   	push   %ebp
80102ab2:	89 e5                	mov    %esp,%ebp
80102ab4:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aba:	83 c0 0c             	add    $0xc,%eax
80102abd:	83 ec 0c             	sub    $0xc,%esp
80102ac0:	50                   	push   %eax
80102ac1:	e8 c2 26 00 00       	call   80105188 <holdingsleep>
80102ac6:	83 c4 10             	add    $0x10,%esp
80102ac9:	85 c0                	test   %eax,%eax
80102acb:	75 0d                	jne    80102ada <iderw+0x2d>
    panic("iderw: buf not locked");
80102acd:	83 ec 0c             	sub    $0xc,%esp
80102ad0:	68 a2 8e 10 80       	push   $0x80108ea2
80102ad5:	e8 2e db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ada:	8b 45 08             	mov    0x8(%ebp),%eax
80102add:	8b 00                	mov    (%eax),%eax
80102adf:	83 e0 06             	and    $0x6,%eax
80102ae2:	83 f8 02             	cmp    $0x2,%eax
80102ae5:	75 0d                	jne    80102af4 <iderw+0x47>
    panic("iderw: nothing to do");
80102ae7:	83 ec 0c             	sub    $0xc,%esp
80102aea:	68 b8 8e 10 80       	push   $0x80108eb8
80102aef:	e8 14 db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102af4:	8b 45 08             	mov    0x8(%ebp),%eax
80102af7:	8b 40 04             	mov    0x4(%eax),%eax
80102afa:	85 c0                	test   %eax,%eax
80102afc:	74 16                	je     80102b14 <iderw+0x67>
80102afe:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	75 0d                	jne    80102b14 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b07:	83 ec 0c             	sub    $0xc,%esp
80102b0a:	68 cd 8e 10 80       	push   $0x80108ecd
80102b0f:	e8 f4 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b14:	83 ec 0c             	sub    $0xc,%esp
80102b17:	68 00 c6 10 80       	push   $0x8010c600
80102b1c:	e8 26 27 00 00       	call   80105247 <acquire>
80102b21:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b24:	8b 45 08             	mov    0x8(%ebp),%eax
80102b27:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b2e:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b35:	eb 0b                	jmp    80102b42 <iderw+0x95>
80102b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3a:	8b 00                	mov    (%eax),%eax
80102b3c:	83 c0 58             	add    $0x58,%eax
80102b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b45:	8b 00                	mov    (%eax),%eax
80102b47:	85 c0                	test   %eax,%eax
80102b49:	75 ec                	jne    80102b37 <iderw+0x8a>
    ;
  *pp = b;
80102b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4e:	8b 55 08             	mov    0x8(%ebp),%edx
80102b51:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b53:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b58:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b5b:	75 23                	jne    80102b80 <iderw+0xd3>
    idestart(b);
80102b5d:	83 ec 0c             	sub    $0xc,%esp
80102b60:	ff 75 08             	pushl  0x8(%ebp)
80102b63:	e8 d6 fc ff ff       	call   8010283e <idestart>
80102b68:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b6b:	eb 13                	jmp    80102b80 <iderw+0xd3>
    sleep(b, &idelock);
80102b6d:	83 ec 08             	sub    $0x8,%esp
80102b70:	68 00 c6 10 80       	push   $0x8010c600
80102b75:	ff 75 08             	pushl  0x8(%ebp)
80102b78:	e8 61 22 00 00       	call   80104dde <sleep>
80102b7d:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b80:	8b 45 08             	mov    0x8(%ebp),%eax
80102b83:	8b 00                	mov    (%eax),%eax
80102b85:	83 e0 06             	and    $0x6,%eax
80102b88:	83 f8 02             	cmp    $0x2,%eax
80102b8b:	75 e0                	jne    80102b6d <iderw+0xc0>
  }


  release(&idelock);
80102b8d:	83 ec 0c             	sub    $0xc,%esp
80102b90:	68 00 c6 10 80       	push   $0x8010c600
80102b95:	e8 1f 27 00 00       	call   801052b9 <release>
80102b9a:	83 c4 10             	add    $0x10,%esp
}
80102b9d:	90                   	nop
80102b9e:	c9                   	leave  
80102b9f:	c3                   	ret    

80102ba0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ba0:	f3 0f 1e fb          	endbr32 
80102ba4:	55                   	push   %ebp
80102ba5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ba7:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bac:	8b 55 08             	mov    0x8(%ebp),%edx
80102baf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bb1:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bb6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bb9:	5d                   	pop    %ebp
80102bba:	c3                   	ret    

80102bbb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bbb:	f3 0f 1e fb          	endbr32 
80102bbf:	55                   	push   %ebp
80102bc0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bc2:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bc7:	8b 55 08             	mov    0x8(%ebp),%edx
80102bca:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bcc:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bd4:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bd7:	90                   	nop
80102bd8:	5d                   	pop    %ebp
80102bd9:	c3                   	ret    

80102bda <ioapicinit>:

void
ioapicinit(void)
{
80102bda:	f3 0f 1e fb          	endbr32 
80102bde:	55                   	push   %ebp
80102bdf:	89 e5                	mov    %esp,%ebp
80102be1:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102be4:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102beb:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bee:	6a 01                	push   $0x1
80102bf0:	e8 ab ff ff ff       	call   80102ba0 <ioapicread>
80102bf5:	83 c4 04             	add    $0x4,%esp
80102bf8:	c1 e8 10             	shr    $0x10,%eax
80102bfb:	25 ff 00 00 00       	and    $0xff,%eax
80102c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c03:	6a 00                	push   $0x0
80102c05:	e8 96 ff ff ff       	call   80102ba0 <ioapicread>
80102c0a:	83 c4 04             	add    $0x4,%esp
80102c0d:	c1 e8 18             	shr    $0x18,%eax
80102c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c13:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c1a:	0f b6 c0             	movzbl %al,%eax
80102c1d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c20:	74 10                	je     80102c32 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c22:	83 ec 0c             	sub    $0xc,%esp
80102c25:	68 ec 8e 10 80       	push   $0x80108eec
80102c2a:	e8 e9 d7 ff ff       	call   80100418 <cprintf>
80102c2f:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c39:	eb 3f                	jmp    80102c7a <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3e:	83 c0 20             	add    $0x20,%eax
80102c41:	0d 00 00 01 00       	or     $0x10000,%eax
80102c46:	89 c2                	mov    %eax,%edx
80102c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4b:	83 c0 08             	add    $0x8,%eax
80102c4e:	01 c0                	add    %eax,%eax
80102c50:	83 ec 08             	sub    $0x8,%esp
80102c53:	52                   	push   %edx
80102c54:	50                   	push   %eax
80102c55:	e8 61 ff ff ff       	call   80102bbb <ioapicwrite>
80102c5a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c60:	83 c0 08             	add    $0x8,%eax
80102c63:	01 c0                	add    %eax,%eax
80102c65:	83 c0 01             	add    $0x1,%eax
80102c68:	83 ec 08             	sub    $0x8,%esp
80102c6b:	6a 00                	push   $0x0
80102c6d:	50                   	push   %eax
80102c6e:	e8 48 ff ff ff       	call   80102bbb <ioapicwrite>
80102c73:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c76:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c80:	7e b9                	jle    80102c3b <ioapicinit+0x61>
  }
}
80102c82:	90                   	nop
80102c83:	90                   	nop
80102c84:	c9                   	leave  
80102c85:	c3                   	ret    

80102c86 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c86:	f3 0f 1e fb          	endbr32 
80102c8a:	55                   	push   %ebp
80102c8b:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c90:	83 c0 20             	add    $0x20,%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	8b 45 08             	mov    0x8(%ebp),%eax
80102c98:	83 c0 08             	add    $0x8,%eax
80102c9b:	01 c0                	add    %eax,%eax
80102c9d:	52                   	push   %edx
80102c9e:	50                   	push   %eax
80102c9f:	e8 17 ff ff ff       	call   80102bbb <ioapicwrite>
80102ca4:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102caa:	c1 e0 18             	shl    $0x18,%eax
80102cad:	89 c2                	mov    %eax,%edx
80102caf:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb2:	83 c0 08             	add    $0x8,%eax
80102cb5:	01 c0                	add    %eax,%eax
80102cb7:	83 c0 01             	add    $0x1,%eax
80102cba:	52                   	push   %edx
80102cbb:	50                   	push   %eax
80102cbc:	e8 fa fe ff ff       	call   80102bbb <ioapicwrite>
80102cc1:	83 c4 08             	add    $0x8,%esp
}
80102cc4:	90                   	nop
80102cc5:	c9                   	leave  
80102cc6:	c3                   	ret    

80102cc7 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cc7:	f3 0f 1e fb          	endbr32 
80102ccb:	55                   	push   %ebp
80102ccc:	89 e5                	mov    %esp,%ebp
80102cce:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cd1:	83 ec 08             	sub    $0x8,%esp
80102cd4:	68 1e 8f 10 80       	push   $0x80108f1e
80102cd9:	68 e0 46 11 80       	push   $0x801146e0
80102cde:	e8 3e 25 00 00       	call   80105221 <initlock>
80102ce3:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ce6:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102ced:	00 00 00 
  freerange(vstart, vend);
80102cf0:	83 ec 08             	sub    $0x8,%esp
80102cf3:	ff 75 0c             	pushl  0xc(%ebp)
80102cf6:	ff 75 08             	pushl  0x8(%ebp)
80102cf9:	e8 2e 00 00 00       	call   80102d2c <freerange>
80102cfe:	83 c4 10             	add    $0x10,%esp
}
80102d01:	90                   	nop
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d04:	f3 0f 1e fb          	endbr32 
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d0e:	83 ec 08             	sub    $0x8,%esp
80102d11:	ff 75 0c             	pushl  0xc(%ebp)
80102d14:	ff 75 08             	pushl  0x8(%ebp)
80102d17:	e8 10 00 00 00       	call   80102d2c <freerange>
80102d1c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d1f:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d26:	00 00 00 
}
80102d29:	90                   	nop
80102d2a:	c9                   	leave  
80102d2b:	c3                   	ret    

80102d2c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d2c:	f3 0f 1e fb          	endbr32 
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d36:	8b 45 08             	mov    0x8(%ebp),%eax
80102d39:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d46:	eb 15                	jmp    80102d5d <freerange+0x31>
    kfree(p);
80102d48:	83 ec 0c             	sub    $0xc,%esp
80102d4b:	ff 75 f4             	pushl  -0xc(%ebp)
80102d4e:	e8 1b 00 00 00       	call   80102d6e <kfree>
80102d53:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d56:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d60:	05 00 10 00 00       	add    $0x1000,%eax
80102d65:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d68:	73 de                	jae    80102d48 <freerange+0x1c>
}
80102d6a:	90                   	nop
80102d6b:	90                   	nop
80102d6c:	c9                   	leave  
80102d6d:	c3                   	ret    

80102d6e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d6e:	f3 0f 1e fb          	endbr32 
80102d72:	55                   	push   %ebp
80102d73:	89 e5                	mov    %esp,%ebp
80102d75:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d78:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d80:	85 c0                	test   %eax,%eax
80102d82:	75 18                	jne    80102d9c <kfree+0x2e>
80102d84:	81 7d 08 48 75 11 80 	cmpl   $0x80117548,0x8(%ebp)
80102d8b:	72 0f                	jb     80102d9c <kfree+0x2e>
80102d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d90:	05 00 00 00 80       	add    $0x80000000,%eax
80102d95:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d9a:	76 0d                	jbe    80102da9 <kfree+0x3b>
    panic("kfree");
80102d9c:	83 ec 0c             	sub    $0xc,%esp
80102d9f:	68 23 8f 10 80       	push   $0x80108f23
80102da4:	e8 5f d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102da9:	83 ec 04             	sub    $0x4,%esp
80102dac:	68 00 10 00 00       	push   $0x1000
80102db1:	6a 01                	push   $0x1
80102db3:	ff 75 08             	pushl  0x8(%ebp)
80102db6:	e8 2b 27 00 00       	call   801054e6 <memset>
80102dbb:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dbe:	a1 14 47 11 80       	mov    0x80114714,%eax
80102dc3:	85 c0                	test   %eax,%eax
80102dc5:	74 10                	je     80102dd7 <kfree+0x69>
    acquire(&kmem.lock);
80102dc7:	83 ec 0c             	sub    $0xc,%esp
80102dca:	68 e0 46 11 80       	push   $0x801146e0
80102dcf:	e8 73 24 00 00       	call   80105247 <acquire>
80102dd4:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ddd:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102de6:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102deb:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102df0:	a1 14 47 11 80       	mov    0x80114714,%eax
80102df5:	85 c0                	test   %eax,%eax
80102df7:	74 10                	je     80102e09 <kfree+0x9b>
    release(&kmem.lock);
80102df9:	83 ec 0c             	sub    $0xc,%esp
80102dfc:	68 e0 46 11 80       	push   $0x801146e0
80102e01:	e8 b3 24 00 00       	call   801052b9 <release>
80102e06:	83 c4 10             	add    $0x10,%esp
}
80102e09:	90                   	nop
80102e0a:	c9                   	leave  
80102e0b:	c3                   	ret    

80102e0c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e0c:	f3 0f 1e fb          	endbr32 
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
80102e13:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e16:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e1b:	85 c0                	test   %eax,%eax
80102e1d:	74 10                	je     80102e2f <kalloc+0x23>
    acquire(&kmem.lock);
80102e1f:	83 ec 0c             	sub    $0xc,%esp
80102e22:	68 e0 46 11 80       	push   $0x801146e0
80102e27:	e8 1b 24 00 00       	call   80105247 <acquire>
80102e2c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e2f:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e3b:	74 0a                	je     80102e47 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e40:	8b 00                	mov    (%eax),%eax
80102e42:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e47:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e4c:	85 c0                	test   %eax,%eax
80102e4e:	74 10                	je     80102e60 <kalloc+0x54>
    release(&kmem.lock);
80102e50:	83 ec 0c             	sub    $0xc,%esp
80102e53:	68 e0 46 11 80       	push   $0x801146e0
80102e58:	e8 5c 24 00 00       	call   801052b9 <release>
80102e5d:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e63:	c9                   	leave  
80102e64:	c3                   	ret    

80102e65 <inb>:
{
80102e65:	55                   	push   %ebp
80102e66:	89 e5                	mov    %esp,%ebp
80102e68:	83 ec 14             	sub    $0x14,%esp
80102e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e72:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e76:	89 c2                	mov    %eax,%edx
80102e78:	ec                   	in     (%dx),%al
80102e79:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e80:	c9                   	leave  
80102e81:	c3                   	ret    

80102e82 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e82:	f3 0f 1e fb          	endbr32 
80102e86:	55                   	push   %ebp
80102e87:	89 e5                	mov    %esp,%ebp
80102e89:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e8c:	6a 64                	push   $0x64
80102e8e:	e8 d2 ff ff ff       	call   80102e65 <inb>
80102e93:	83 c4 04             	add    $0x4,%esp
80102e96:	0f b6 c0             	movzbl %al,%eax
80102e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9f:	83 e0 01             	and    $0x1,%eax
80102ea2:	85 c0                	test   %eax,%eax
80102ea4:	75 0a                	jne    80102eb0 <kbdgetc+0x2e>
    return -1;
80102ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eab:	e9 23 01 00 00       	jmp    80102fd3 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102eb0:	6a 60                	push   $0x60
80102eb2:	e8 ae ff ff ff       	call   80102e65 <inb>
80102eb7:	83 c4 04             	add    $0x4,%esp
80102eba:	0f b6 c0             	movzbl %al,%eax
80102ebd:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ec0:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ec7:	75 17                	jne    80102ee0 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ec9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ece:	83 c8 40             	or     $0x40,%eax
80102ed1:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102ed6:	b8 00 00 00 00       	mov    $0x0,%eax
80102edb:	e9 f3 00 00 00       	jmp    80102fd3 <kbdgetc+0x151>
  } else if(data & 0x80){
80102ee0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee3:	25 80 00 00 00       	and    $0x80,%eax
80102ee8:	85 c0                	test   %eax,%eax
80102eea:	74 45                	je     80102f31 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102eec:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ef1:	83 e0 40             	and    $0x40,%eax
80102ef4:	85 c0                	test   %eax,%eax
80102ef6:	75 08                	jne    80102f00 <kbdgetc+0x7e>
80102ef8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102efb:	83 e0 7f             	and    $0x7f,%eax
80102efe:	eb 03                	jmp    80102f03 <kbdgetc+0x81>
80102f00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f03:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f09:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f0e:	0f b6 00             	movzbl (%eax),%eax
80102f11:	83 c8 40             	or     $0x40,%eax
80102f14:	0f b6 c0             	movzbl %al,%eax
80102f17:	f7 d0                	not    %eax
80102f19:	89 c2                	mov    %eax,%edx
80102f1b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f20:	21 d0                	and    %edx,%eax
80102f22:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f27:	b8 00 00 00 00       	mov    $0x0,%eax
80102f2c:	e9 a2 00 00 00       	jmp    80102fd3 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f31:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f36:	83 e0 40             	and    $0x40,%eax
80102f39:	85 c0                	test   %eax,%eax
80102f3b:	74 14                	je     80102f51 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f3d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f44:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f49:	83 e0 bf             	and    $0xffffffbf,%eax
80102f4c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f54:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f59:	0f b6 00             	movzbl (%eax),%eax
80102f5c:	0f b6 d0             	movzbl %al,%edx
80102f5f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f64:	09 d0                	or     %edx,%eax
80102f66:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f6e:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f73:	0f b6 00             	movzbl (%eax),%eax
80102f76:	0f b6 d0             	movzbl %al,%edx
80102f79:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f7e:	31 d0                	xor    %edx,%eax
80102f80:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f85:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f8a:	83 e0 03             	and    $0x3,%eax
80102f8d:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f97:	01 d0                	add    %edx,%eax
80102f99:	0f b6 00             	movzbl (%eax),%eax
80102f9c:	0f b6 c0             	movzbl %al,%eax
80102f9f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fa2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fa7:	83 e0 08             	and    $0x8,%eax
80102faa:	85 c0                	test   %eax,%eax
80102fac:	74 22                	je     80102fd0 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fae:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fb2:	76 0c                	jbe    80102fc0 <kbdgetc+0x13e>
80102fb4:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fb8:	77 06                	ja     80102fc0 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fba:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fbe:	eb 10                	jmp    80102fd0 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fc0:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fc4:	76 0a                	jbe    80102fd0 <kbdgetc+0x14e>
80102fc6:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fca:	77 04                	ja     80102fd0 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fcc:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fd3:	c9                   	leave  
80102fd4:	c3                   	ret    

80102fd5 <kbdintr>:

void
kbdintr(void)
{
80102fd5:	f3 0f 1e fb          	endbr32 
80102fd9:	55                   	push   %ebp
80102fda:	89 e5                	mov    %esp,%ebp
80102fdc:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102fdf:	83 ec 0c             	sub    $0xc,%esp
80102fe2:	68 82 2e 10 80       	push   $0x80102e82
80102fe7:	e8 bc d8 ff ff       	call   801008a8 <consoleintr>
80102fec:	83 c4 10             	add    $0x10,%esp
}
80102fef:	90                   	nop
80102ff0:	c9                   	leave  
80102ff1:	c3                   	ret    

80102ff2 <inb>:
{
80102ff2:	55                   	push   %ebp
80102ff3:	89 e5                	mov    %esp,%ebp
80102ff5:	83 ec 14             	sub    $0x14,%esp
80102ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fff:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103003:	89 c2                	mov    %eax,%edx
80103005:	ec                   	in     (%dx),%al
80103006:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103009:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010300d:	c9                   	leave  
8010300e:	c3                   	ret    

8010300f <outb>:
{
8010300f:	55                   	push   %ebp
80103010:	89 e5                	mov    %esp,%ebp
80103012:	83 ec 08             	sub    $0x8,%esp
80103015:	8b 45 08             	mov    0x8(%ebp),%eax
80103018:	8b 55 0c             	mov    0xc(%ebp),%edx
8010301b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010301f:	89 d0                	mov    %edx,%eax
80103021:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103024:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103028:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010302c:	ee                   	out    %al,(%dx)
}
8010302d:	90                   	nop
8010302e:	c9                   	leave  
8010302f:	c3                   	ret    

80103030 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103030:	f3 0f 1e fb          	endbr32 
80103034:	55                   	push   %ebp
80103035:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103037:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010303c:	8b 55 08             	mov    0x8(%ebp),%edx
8010303f:	c1 e2 02             	shl    $0x2,%edx
80103042:	01 c2                	add    %eax,%edx
80103044:	8b 45 0c             	mov    0xc(%ebp),%eax
80103047:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103049:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010304e:	83 c0 20             	add    $0x20,%eax
80103051:	8b 00                	mov    (%eax),%eax
}
80103053:	90                   	nop
80103054:	5d                   	pop    %ebp
80103055:	c3                   	ret    

80103056 <lapicinit>:

void
lapicinit(void)
{
80103056:	f3 0f 1e fb          	endbr32 
8010305a:	55                   	push   %ebp
8010305b:	89 e5                	mov    %esp,%ebp
  if(!lapic)
8010305d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103062:	85 c0                	test   %eax,%eax
80103064:	0f 84 0c 01 00 00    	je     80103176 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010306a:	68 3f 01 00 00       	push   $0x13f
8010306f:	6a 3c                	push   $0x3c
80103071:	e8 ba ff ff ff       	call   80103030 <lapicw>
80103076:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103079:	6a 0b                	push   $0xb
8010307b:	68 f8 00 00 00       	push   $0xf8
80103080:	e8 ab ff ff ff       	call   80103030 <lapicw>
80103085:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103088:	68 20 00 02 00       	push   $0x20020
8010308d:	68 c8 00 00 00       	push   $0xc8
80103092:	e8 99 ff ff ff       	call   80103030 <lapicw>
80103097:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
8010309a:	68 80 96 98 00       	push   $0x989680
8010309f:	68 e0 00 00 00       	push   $0xe0
801030a4:	e8 87 ff ff ff       	call   80103030 <lapicw>
801030a9:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030ac:	68 00 00 01 00       	push   $0x10000
801030b1:	68 d4 00 00 00       	push   $0xd4
801030b6:	e8 75 ff ff ff       	call   80103030 <lapicw>
801030bb:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030be:	68 00 00 01 00       	push   $0x10000
801030c3:	68 d8 00 00 00       	push   $0xd8
801030c8:	e8 63 ff ff ff       	call   80103030 <lapicw>
801030cd:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030d0:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030d5:	83 c0 30             	add    $0x30,%eax
801030d8:	8b 00                	mov    (%eax),%eax
801030da:	c1 e8 10             	shr    $0x10,%eax
801030dd:	25 fc 00 00 00       	and    $0xfc,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 12                	je     801030f8 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030e6:	68 00 00 01 00       	push   $0x10000
801030eb:	68 d0 00 00 00       	push   $0xd0
801030f0:	e8 3b ff ff ff       	call   80103030 <lapicw>
801030f5:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030f8:	6a 33                	push   $0x33
801030fa:	68 dc 00 00 00       	push   $0xdc
801030ff:	e8 2c ff ff ff       	call   80103030 <lapicw>
80103104:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103107:	6a 00                	push   $0x0
80103109:	68 a0 00 00 00       	push   $0xa0
8010310e:	e8 1d ff ff ff       	call   80103030 <lapicw>
80103113:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103116:	6a 00                	push   $0x0
80103118:	68 a0 00 00 00       	push   $0xa0
8010311d:	e8 0e ff ff ff       	call   80103030 <lapicw>
80103122:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103125:	6a 00                	push   $0x0
80103127:	6a 2c                	push   $0x2c
80103129:	e8 02 ff ff ff       	call   80103030 <lapicw>
8010312e:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103131:	6a 00                	push   $0x0
80103133:	68 c4 00 00 00       	push   $0xc4
80103138:	e8 f3 fe ff ff       	call   80103030 <lapicw>
8010313d:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103140:	68 00 85 08 00       	push   $0x88500
80103145:	68 c0 00 00 00       	push   $0xc0
8010314a:	e8 e1 fe ff ff       	call   80103030 <lapicw>
8010314f:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103152:	90                   	nop
80103153:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103158:	05 00 03 00 00       	add    $0x300,%eax
8010315d:	8b 00                	mov    (%eax),%eax
8010315f:	25 00 10 00 00       	and    $0x1000,%eax
80103164:	85 c0                	test   %eax,%eax
80103166:	75 eb                	jne    80103153 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103168:	6a 00                	push   $0x0
8010316a:	6a 20                	push   $0x20
8010316c:	e8 bf fe ff ff       	call   80103030 <lapicw>
80103171:	83 c4 08             	add    $0x8,%esp
80103174:	eb 01                	jmp    80103177 <lapicinit+0x121>
    return;
80103176:	90                   	nop
}
80103177:	c9                   	leave  
80103178:	c3                   	ret    

80103179 <lapicid>:

int
lapicid(void)
{
80103179:	f3 0f 1e fb          	endbr32 
8010317d:	55                   	push   %ebp
8010317e:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103180:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103185:	85 c0                	test   %eax,%eax
80103187:	75 07                	jne    80103190 <lapicid+0x17>
    return 0;
80103189:	b8 00 00 00 00       	mov    $0x0,%eax
8010318e:	eb 0d                	jmp    8010319d <lapicid+0x24>
  return lapic[ID] >> 24;
80103190:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103195:	83 c0 20             	add    $0x20,%eax
80103198:	8b 00                	mov    (%eax),%eax
8010319a:	c1 e8 18             	shr    $0x18,%eax
}
8010319d:	5d                   	pop    %ebp
8010319e:	c3                   	ret    

8010319f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010319f:	f3 0f 1e fb          	endbr32 
801031a3:	55                   	push   %ebp
801031a4:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031a6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031ab:	85 c0                	test   %eax,%eax
801031ad:	74 0c                	je     801031bb <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031af:	6a 00                	push   $0x0
801031b1:	6a 2c                	push   $0x2c
801031b3:	e8 78 fe ff ff       	call   80103030 <lapicw>
801031b8:	83 c4 08             	add    $0x8,%esp
}
801031bb:	90                   	nop
801031bc:	c9                   	leave  
801031bd:	c3                   	ret    

801031be <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031be:	f3 0f 1e fb          	endbr32 
801031c2:	55                   	push   %ebp
801031c3:	89 e5                	mov    %esp,%ebp
}
801031c5:	90                   	nop
801031c6:	5d                   	pop    %ebp
801031c7:	c3                   	ret    

801031c8 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031c8:	f3 0f 1e fb          	endbr32 
801031cc:	55                   	push   %ebp
801031cd:	89 e5                	mov    %esp,%ebp
801031cf:	83 ec 14             	sub    $0x14,%esp
801031d2:	8b 45 08             	mov    0x8(%ebp),%eax
801031d5:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031d8:	6a 0f                	push   $0xf
801031da:	6a 70                	push   $0x70
801031dc:	e8 2e fe ff ff       	call   8010300f <outb>
801031e1:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031e4:	6a 0a                	push   $0xa
801031e6:	6a 71                	push   $0x71
801031e8:	e8 22 fe ff ff       	call   8010300f <outb>
801031ed:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031f0:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031fa:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103202:	c1 e8 04             	shr    $0x4,%eax
80103205:	89 c2                	mov    %eax,%edx
80103207:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010320a:	83 c0 02             	add    $0x2,%eax
8010320d:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103210:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103214:	c1 e0 18             	shl    $0x18,%eax
80103217:	50                   	push   %eax
80103218:	68 c4 00 00 00       	push   $0xc4
8010321d:	e8 0e fe ff ff       	call   80103030 <lapicw>
80103222:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103225:	68 00 c5 00 00       	push   $0xc500
8010322a:	68 c0 00 00 00       	push   $0xc0
8010322f:	e8 fc fd ff ff       	call   80103030 <lapicw>
80103234:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103237:	68 c8 00 00 00       	push   $0xc8
8010323c:	e8 7d ff ff ff       	call   801031be <microdelay>
80103241:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103244:	68 00 85 00 00       	push   $0x8500
80103249:	68 c0 00 00 00       	push   $0xc0
8010324e:	e8 dd fd ff ff       	call   80103030 <lapicw>
80103253:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103256:	6a 64                	push   $0x64
80103258:	e8 61 ff ff ff       	call   801031be <microdelay>
8010325d:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103260:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103267:	eb 3d                	jmp    801032a6 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80103269:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010326d:	c1 e0 18             	shl    $0x18,%eax
80103270:	50                   	push   %eax
80103271:	68 c4 00 00 00       	push   $0xc4
80103276:	e8 b5 fd ff ff       	call   80103030 <lapicw>
8010327b:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010327e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103281:	c1 e8 0c             	shr    $0xc,%eax
80103284:	80 cc 06             	or     $0x6,%ah
80103287:	50                   	push   %eax
80103288:	68 c0 00 00 00       	push   $0xc0
8010328d:	e8 9e fd ff ff       	call   80103030 <lapicw>
80103292:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103295:	68 c8 00 00 00       	push   $0xc8
8010329a:	e8 1f ff ff ff       	call   801031be <microdelay>
8010329f:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032a2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032a6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032aa:	7e bd                	jle    80103269 <lapicstartap+0xa1>
  }
}
801032ac:	90                   	nop
801032ad:	90                   	nop
801032ae:	c9                   	leave  
801032af:	c3                   	ret    

801032b0 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032b0:	f3 0f 1e fb          	endbr32 
801032b4:	55                   	push   %ebp
801032b5:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032b7:	8b 45 08             	mov    0x8(%ebp),%eax
801032ba:	0f b6 c0             	movzbl %al,%eax
801032bd:	50                   	push   %eax
801032be:	6a 70                	push   $0x70
801032c0:	e8 4a fd ff ff       	call   8010300f <outb>
801032c5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032c8:	68 c8 00 00 00       	push   $0xc8
801032cd:	e8 ec fe ff ff       	call   801031be <microdelay>
801032d2:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032d5:	6a 71                	push   $0x71
801032d7:	e8 16 fd ff ff       	call   80102ff2 <inb>
801032dc:	83 c4 04             	add    $0x4,%esp
801032df:	0f b6 c0             	movzbl %al,%eax
}
801032e2:	c9                   	leave  
801032e3:	c3                   	ret    

801032e4 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032e4:	f3 0f 1e fb          	endbr32 
801032e8:	55                   	push   %ebp
801032e9:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801032eb:	6a 00                	push   $0x0
801032ed:	e8 be ff ff ff       	call   801032b0 <cmos_read>
801032f2:	83 c4 04             	add    $0x4,%esp
801032f5:	8b 55 08             	mov    0x8(%ebp),%edx
801032f8:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032fa:	6a 02                	push   $0x2
801032fc:	e8 af ff ff ff       	call   801032b0 <cmos_read>
80103301:	83 c4 04             	add    $0x4,%esp
80103304:	8b 55 08             	mov    0x8(%ebp),%edx
80103307:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010330a:	6a 04                	push   $0x4
8010330c:	e8 9f ff ff ff       	call   801032b0 <cmos_read>
80103311:	83 c4 04             	add    $0x4,%esp
80103314:	8b 55 08             	mov    0x8(%ebp),%edx
80103317:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010331a:	6a 07                	push   $0x7
8010331c:	e8 8f ff ff ff       	call   801032b0 <cmos_read>
80103321:	83 c4 04             	add    $0x4,%esp
80103324:	8b 55 08             	mov    0x8(%ebp),%edx
80103327:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010332a:	6a 08                	push   $0x8
8010332c:	e8 7f ff ff ff       	call   801032b0 <cmos_read>
80103331:	83 c4 04             	add    $0x4,%esp
80103334:	8b 55 08             	mov    0x8(%ebp),%edx
80103337:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010333a:	6a 09                	push   $0x9
8010333c:	e8 6f ff ff ff       	call   801032b0 <cmos_read>
80103341:	83 c4 04             	add    $0x4,%esp
80103344:	8b 55 08             	mov    0x8(%ebp),%edx
80103347:	89 42 14             	mov    %eax,0x14(%edx)
}
8010334a:	90                   	nop
8010334b:	c9                   	leave  
8010334c:	c3                   	ret    

8010334d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010334d:	f3 0f 1e fb          	endbr32 
80103351:	55                   	push   %ebp
80103352:	89 e5                	mov    %esp,%ebp
80103354:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103357:	6a 0b                	push   $0xb
80103359:	e8 52 ff ff ff       	call   801032b0 <cmos_read>
8010335e:	83 c4 04             	add    $0x4,%esp
80103361:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103367:	83 e0 04             	and    $0x4,%eax
8010336a:	85 c0                	test   %eax,%eax
8010336c:	0f 94 c0             	sete   %al
8010336f:	0f b6 c0             	movzbl %al,%eax
80103372:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103375:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103378:	50                   	push   %eax
80103379:	e8 66 ff ff ff       	call   801032e4 <fill_rtcdate>
8010337e:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103381:	6a 0a                	push   $0xa
80103383:	e8 28 ff ff ff       	call   801032b0 <cmos_read>
80103388:	83 c4 04             	add    $0x4,%esp
8010338b:	25 80 00 00 00       	and    $0x80,%eax
80103390:	85 c0                	test   %eax,%eax
80103392:	75 27                	jne    801033bb <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103394:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103397:	50                   	push   %eax
80103398:	e8 47 ff ff ff       	call   801032e4 <fill_rtcdate>
8010339d:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033a0:	83 ec 04             	sub    $0x4,%esp
801033a3:	6a 18                	push   $0x18
801033a5:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033a8:	50                   	push   %eax
801033a9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033ac:	50                   	push   %eax
801033ad:	e8 9f 21 00 00       	call   80105551 <memcmp>
801033b2:	83 c4 10             	add    $0x10,%esp
801033b5:	85 c0                	test   %eax,%eax
801033b7:	74 05                	je     801033be <cmostime+0x71>
801033b9:	eb ba                	jmp    80103375 <cmostime+0x28>
        continue;
801033bb:	90                   	nop
    fill_rtcdate(&t1);
801033bc:	eb b7                	jmp    80103375 <cmostime+0x28>
      break;
801033be:	90                   	nop
  }

  // convert
  if(bcd) {
801033bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033c3:	0f 84 b4 00 00 00    	je     8010347d <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033cc:	c1 e8 04             	shr    $0x4,%eax
801033cf:	89 c2                	mov    %eax,%edx
801033d1:	89 d0                	mov    %edx,%eax
801033d3:	c1 e0 02             	shl    $0x2,%eax
801033d6:	01 d0                	add    %edx,%eax
801033d8:	01 c0                	add    %eax,%eax
801033da:	89 c2                	mov    %eax,%edx
801033dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033df:	83 e0 0f             	and    $0xf,%eax
801033e2:	01 d0                	add    %edx,%eax
801033e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033ea:	c1 e8 04             	shr    $0x4,%eax
801033ed:	89 c2                	mov    %eax,%edx
801033ef:	89 d0                	mov    %edx,%eax
801033f1:	c1 e0 02             	shl    $0x2,%eax
801033f4:	01 d0                	add    %edx,%eax
801033f6:	01 c0                	add    %eax,%eax
801033f8:	89 c2                	mov    %eax,%edx
801033fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033fd:	83 e0 0f             	and    $0xf,%eax
80103400:	01 d0                	add    %edx,%eax
80103402:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103405:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103408:	c1 e8 04             	shr    $0x4,%eax
8010340b:	89 c2                	mov    %eax,%edx
8010340d:	89 d0                	mov    %edx,%eax
8010340f:	c1 e0 02             	shl    $0x2,%eax
80103412:	01 d0                	add    %edx,%eax
80103414:	01 c0                	add    %eax,%eax
80103416:	89 c2                	mov    %eax,%edx
80103418:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010341b:	83 e0 0f             	and    $0xf,%eax
8010341e:	01 d0                	add    %edx,%eax
80103420:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103426:	c1 e8 04             	shr    $0x4,%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	89 d0                	mov    %edx,%eax
8010342d:	c1 e0 02             	shl    $0x2,%eax
80103430:	01 d0                	add    %edx,%eax
80103432:	01 c0                	add    %eax,%eax
80103434:	89 c2                	mov    %eax,%edx
80103436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103439:	83 e0 0f             	and    $0xf,%eax
8010343c:	01 d0                	add    %edx,%eax
8010343e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103441:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103444:	c1 e8 04             	shr    $0x4,%eax
80103447:	89 c2                	mov    %eax,%edx
80103449:	89 d0                	mov    %edx,%eax
8010344b:	c1 e0 02             	shl    $0x2,%eax
8010344e:	01 d0                	add    %edx,%eax
80103450:	01 c0                	add    %eax,%eax
80103452:	89 c2                	mov    %eax,%edx
80103454:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103457:	83 e0 0f             	and    $0xf,%eax
8010345a:	01 d0                	add    %edx,%eax
8010345c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	c1 e8 04             	shr    $0x4,%eax
80103465:	89 c2                	mov    %eax,%edx
80103467:	89 d0                	mov    %edx,%eax
80103469:	c1 e0 02             	shl    $0x2,%eax
8010346c:	01 d0                	add    %edx,%eax
8010346e:	01 c0                	add    %eax,%eax
80103470:	89 c2                	mov    %eax,%edx
80103472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103475:	83 e0 0f             	and    $0xf,%eax
80103478:	01 d0                	add    %edx,%eax
8010347a:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010347d:	8b 45 08             	mov    0x8(%ebp),%eax
80103480:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103483:	89 10                	mov    %edx,(%eax)
80103485:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103488:	89 50 04             	mov    %edx,0x4(%eax)
8010348b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010348e:	89 50 08             	mov    %edx,0x8(%eax)
80103491:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103494:	89 50 0c             	mov    %edx,0xc(%eax)
80103497:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010349a:	89 50 10             	mov    %edx,0x10(%eax)
8010349d:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034a0:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034a3:	8b 45 08             	mov    0x8(%ebp),%eax
801034a6:	8b 40 14             	mov    0x14(%eax),%eax
801034a9:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034af:	8b 45 08             	mov    0x8(%ebp),%eax
801034b2:	89 50 14             	mov    %edx,0x14(%eax)
}
801034b5:	90                   	nop
801034b6:	c9                   	leave  
801034b7:	c3                   	ret    

801034b8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034b8:	f3 0f 1e fb          	endbr32 
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034c2:	83 ec 08             	sub    $0x8,%esp
801034c5:	68 29 8f 10 80       	push   $0x80108f29
801034ca:	68 20 47 11 80       	push   $0x80114720
801034cf:	e8 4d 1d 00 00       	call   80105221 <initlock>
801034d4:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034d7:	83 ec 08             	sub    $0x8,%esp
801034da:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034dd:	50                   	push   %eax
801034de:	ff 75 08             	pushl  0x8(%ebp)
801034e1:	e8 f9 df ff ff       	call   801014df <readsb>
801034e6:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ec:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
801034f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034f4:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
801034f9:	8b 45 08             	mov    0x8(%ebp),%eax
801034fc:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103501:	e8 bf 01 00 00       	call   801036c5 <recover_from_log>
}
80103506:	90                   	nop
80103507:	c9                   	leave  
80103508:	c3                   	ret    

80103509 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103509:	f3 0f 1e fb          	endbr32 
8010350d:	55                   	push   %ebp
8010350e:	89 e5                	mov    %esp,%ebp
80103510:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010351a:	e9 95 00 00 00       	jmp    801035b4 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010351f:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103528:	01 d0                	add    %edx,%eax
8010352a:	83 c0 01             	add    $0x1,%eax
8010352d:	89 c2                	mov    %eax,%edx
8010352f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103534:	83 ec 08             	sub    $0x8,%esp
80103537:	52                   	push   %edx
80103538:	50                   	push   %eax
80103539:	e8 99 cc ff ff       	call   801001d7 <bread>
8010353e:	83 c4 10             	add    $0x10,%esp
80103541:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103547:	83 c0 10             	add    $0x10,%eax
8010354a:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103551:	89 c2                	mov    %eax,%edx
80103553:	a1 64 47 11 80       	mov    0x80114764,%eax
80103558:	83 ec 08             	sub    $0x8,%esp
8010355b:	52                   	push   %edx
8010355c:	50                   	push   %eax
8010355d:	e8 75 cc ff ff       	call   801001d7 <bread>
80103562:	83 c4 10             	add    $0x10,%esp
80103565:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010356e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103571:	83 c0 5c             	add    $0x5c,%eax
80103574:	83 ec 04             	sub    $0x4,%esp
80103577:	68 00 02 00 00       	push   $0x200
8010357c:	52                   	push   %edx
8010357d:	50                   	push   %eax
8010357e:	e8 2a 20 00 00       	call   801055ad <memmove>
80103583:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103586:	83 ec 0c             	sub    $0xc,%esp
80103589:	ff 75 ec             	pushl  -0x14(%ebp)
8010358c:	e8 83 cc ff ff       	call   80100214 <bwrite>
80103591:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103594:	83 ec 0c             	sub    $0xc,%esp
80103597:	ff 75 f0             	pushl  -0x10(%ebp)
8010359a:	e8 c2 cc ff ff       	call   80100261 <brelse>
8010359f:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035a2:	83 ec 0c             	sub    $0xc,%esp
801035a5:	ff 75 ec             	pushl  -0x14(%ebp)
801035a8:	e8 b4 cc ff ff       	call   80100261 <brelse>
801035ad:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035b4:	a1 68 47 11 80       	mov    0x80114768,%eax
801035b9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035bc:	0f 8c 5d ff ff ff    	jl     8010351f <install_trans+0x16>
  }
}
801035c2:	90                   	nop
801035c3:	90                   	nop
801035c4:	c9                   	leave  
801035c5:	c3                   	ret    

801035c6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035c6:	f3 0f 1e fb          	endbr32 
801035ca:	55                   	push   %ebp
801035cb:	89 e5                	mov    %esp,%ebp
801035cd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035d0:	a1 54 47 11 80       	mov    0x80114754,%eax
801035d5:	89 c2                	mov    %eax,%edx
801035d7:	a1 64 47 11 80       	mov    0x80114764,%eax
801035dc:	83 ec 08             	sub    $0x8,%esp
801035df:	52                   	push   %edx
801035e0:	50                   	push   %eax
801035e1:	e8 f1 cb ff ff       	call   801001d7 <bread>
801035e6:	83 c4 10             	add    $0x10,%esp
801035e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ef:	83 c0 5c             	add    $0x5c,%eax
801035f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f8:	8b 00                	mov    (%eax),%eax
801035fa:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
801035ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103606:	eb 1b                	jmp    80103623 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103608:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010360b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010360e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103612:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103615:	83 c2 10             	add    $0x10,%edx
80103618:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010361f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103623:	a1 68 47 11 80       	mov    0x80114768,%eax
80103628:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010362b:	7c db                	jl     80103608 <read_head+0x42>
  }
  brelse(buf);
8010362d:	83 ec 0c             	sub    $0xc,%esp
80103630:	ff 75 f0             	pushl  -0x10(%ebp)
80103633:	e8 29 cc ff ff       	call   80100261 <brelse>
80103638:	83 c4 10             	add    $0x10,%esp
}
8010363b:	90                   	nop
8010363c:	c9                   	leave  
8010363d:	c3                   	ret    

8010363e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010363e:	f3 0f 1e fb          	endbr32 
80103642:	55                   	push   %ebp
80103643:	89 e5                	mov    %esp,%ebp
80103645:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103648:	a1 54 47 11 80       	mov    0x80114754,%eax
8010364d:	89 c2                	mov    %eax,%edx
8010364f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103654:	83 ec 08             	sub    $0x8,%esp
80103657:	52                   	push   %edx
80103658:	50                   	push   %eax
80103659:	e8 79 cb ff ff       	call   801001d7 <bread>
8010365e:	83 c4 10             	add    $0x10,%esp
80103661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103667:	83 c0 5c             	add    $0x5c,%eax
8010366a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010366d:	8b 15 68 47 11 80    	mov    0x80114768,%edx
80103673:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103676:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367f:	eb 1b                	jmp    8010369c <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103684:	83 c0 10             	add    $0x10,%eax
80103687:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
8010368e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103691:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103694:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103698:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010369c:	a1 68 47 11 80       	mov    0x80114768,%eax
801036a1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036a4:	7c db                	jl     80103681 <write_head+0x43>
  }
  bwrite(buf);
801036a6:	83 ec 0c             	sub    $0xc,%esp
801036a9:	ff 75 f0             	pushl  -0x10(%ebp)
801036ac:	e8 63 cb ff ff       	call   80100214 <bwrite>
801036b1:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036b4:	83 ec 0c             	sub    $0xc,%esp
801036b7:	ff 75 f0             	pushl  -0x10(%ebp)
801036ba:	e8 a2 cb ff ff       	call   80100261 <brelse>
801036bf:	83 c4 10             	add    $0x10,%esp
}
801036c2:	90                   	nop
801036c3:	c9                   	leave  
801036c4:	c3                   	ret    

801036c5 <recover_from_log>:

static void
recover_from_log(void)
{
801036c5:	f3 0f 1e fb          	endbr32 
801036c9:	55                   	push   %ebp
801036ca:	89 e5                	mov    %esp,%ebp
801036cc:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036cf:	e8 f2 fe ff ff       	call   801035c6 <read_head>
  install_trans(); // if committed, copy from log to disk
801036d4:	e8 30 fe ff ff       	call   80103509 <install_trans>
  log.lh.n = 0;
801036d9:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036e0:	00 00 00 
  write_head(); // clear the log
801036e3:	e8 56 ff ff ff       	call   8010363e <write_head>
}
801036e8:	90                   	nop
801036e9:	c9                   	leave  
801036ea:	c3                   	ret    

801036eb <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036eb:	f3 0f 1e fb          	endbr32 
801036ef:	55                   	push   %ebp
801036f0:	89 e5                	mov    %esp,%ebp
801036f2:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801036f5:	83 ec 0c             	sub    $0xc,%esp
801036f8:	68 20 47 11 80       	push   $0x80114720
801036fd:	e8 45 1b 00 00       	call   80105247 <acquire>
80103702:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103705:	a1 60 47 11 80       	mov    0x80114760,%eax
8010370a:	85 c0                	test   %eax,%eax
8010370c:	74 17                	je     80103725 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010370e:	83 ec 08             	sub    $0x8,%esp
80103711:	68 20 47 11 80       	push   $0x80114720
80103716:	68 20 47 11 80       	push   $0x80114720
8010371b:	e8 be 16 00 00       	call   80104dde <sleep>
80103720:	83 c4 10             	add    $0x10,%esp
80103723:	eb e0                	jmp    80103705 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103725:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
8010372b:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103730:	8d 50 01             	lea    0x1(%eax),%edx
80103733:	89 d0                	mov    %edx,%eax
80103735:	c1 e0 02             	shl    $0x2,%eax
80103738:	01 d0                	add    %edx,%eax
8010373a:	01 c0                	add    %eax,%eax
8010373c:	01 c8                	add    %ecx,%eax
8010373e:	83 f8 1e             	cmp    $0x1e,%eax
80103741:	7e 17                	jle    8010375a <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103743:	83 ec 08             	sub    $0x8,%esp
80103746:	68 20 47 11 80       	push   $0x80114720
8010374b:	68 20 47 11 80       	push   $0x80114720
80103750:	e8 89 16 00 00       	call   80104dde <sleep>
80103755:	83 c4 10             	add    $0x10,%esp
80103758:	eb ab                	jmp    80103705 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
8010375a:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010375f:	83 c0 01             	add    $0x1,%eax
80103762:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
80103767:	83 ec 0c             	sub    $0xc,%esp
8010376a:	68 20 47 11 80       	push   $0x80114720
8010376f:	e8 45 1b 00 00       	call   801052b9 <release>
80103774:	83 c4 10             	add    $0x10,%esp
      break;
80103777:	90                   	nop
    }
  }
}
80103778:	90                   	nop
80103779:	c9                   	leave  
8010377a:	c3                   	ret    

8010377b <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010377b:	f3 0f 1e fb          	endbr32 
8010377f:	55                   	push   %ebp
80103780:	89 e5                	mov    %esp,%ebp
80103782:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010378c:	83 ec 0c             	sub    $0xc,%esp
8010378f:	68 20 47 11 80       	push   $0x80114720
80103794:	e8 ae 1a 00 00       	call   80105247 <acquire>
80103799:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010379c:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037a1:	83 e8 01             	sub    $0x1,%eax
801037a4:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
801037a9:	a1 60 47 11 80       	mov    0x80114760,%eax
801037ae:	85 c0                	test   %eax,%eax
801037b0:	74 0d                	je     801037bf <end_op+0x44>
    panic("log.committing");
801037b2:	83 ec 0c             	sub    $0xc,%esp
801037b5:	68 2d 8f 10 80       	push   $0x80108f2d
801037ba:	e8 49 ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037bf:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037c4:	85 c0                	test   %eax,%eax
801037c6:	75 13                	jne    801037db <end_op+0x60>
    do_commit = 1;
801037c8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037cf:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037d6:	00 00 00 
801037d9:	eb 10                	jmp    801037eb <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037db:	83 ec 0c             	sub    $0xc,%esp
801037de:	68 20 47 11 80       	push   $0x80114720
801037e3:	e8 e5 16 00 00       	call   80104ecd <wakeup>
801037e8:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801037eb:	83 ec 0c             	sub    $0xc,%esp
801037ee:	68 20 47 11 80       	push   $0x80114720
801037f3:	e8 c1 1a 00 00       	call   801052b9 <release>
801037f8:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801037fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037ff:	74 3f                	je     80103840 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103801:	e8 fa 00 00 00       	call   80103900 <commit>
    acquire(&log.lock);
80103806:	83 ec 0c             	sub    $0xc,%esp
80103809:	68 20 47 11 80       	push   $0x80114720
8010380e:	e8 34 1a 00 00       	call   80105247 <acquire>
80103813:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103816:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
8010381d:	00 00 00 
    wakeup(&log);
80103820:	83 ec 0c             	sub    $0xc,%esp
80103823:	68 20 47 11 80       	push   $0x80114720
80103828:	e8 a0 16 00 00       	call   80104ecd <wakeup>
8010382d:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	68 20 47 11 80       	push   $0x80114720
80103838:	e8 7c 1a 00 00       	call   801052b9 <release>
8010383d:	83 c4 10             	add    $0x10,%esp
  }
}
80103840:	90                   	nop
80103841:	c9                   	leave  
80103842:	c3                   	ret    

80103843 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103843:	f3 0f 1e fb          	endbr32 
80103847:	55                   	push   %ebp
80103848:	89 e5                	mov    %esp,%ebp
8010384a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010384d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103854:	e9 95 00 00 00       	jmp    801038ee <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103859:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010385f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103862:	01 d0                	add    %edx,%eax
80103864:	83 c0 01             	add    $0x1,%eax
80103867:	89 c2                	mov    %eax,%edx
80103869:	a1 64 47 11 80       	mov    0x80114764,%eax
8010386e:	83 ec 08             	sub    $0x8,%esp
80103871:	52                   	push   %edx
80103872:	50                   	push   %eax
80103873:	e8 5f c9 ff ff       	call   801001d7 <bread>
80103878:	83 c4 10             	add    $0x10,%esp
8010387b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010387e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103881:	83 c0 10             	add    $0x10,%eax
80103884:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
8010388b:	89 c2                	mov    %eax,%edx
8010388d:	a1 64 47 11 80       	mov    0x80114764,%eax
80103892:	83 ec 08             	sub    $0x8,%esp
80103895:	52                   	push   %edx
80103896:	50                   	push   %eax
80103897:	e8 3b c9 ff ff       	call   801001d7 <bread>
8010389c:	83 c4 10             	add    $0x10,%esp
8010389f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038a5:	8d 50 5c             	lea    0x5c(%eax),%edx
801038a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ab:	83 c0 5c             	add    $0x5c,%eax
801038ae:	83 ec 04             	sub    $0x4,%esp
801038b1:	68 00 02 00 00       	push   $0x200
801038b6:	52                   	push   %edx
801038b7:	50                   	push   %eax
801038b8:	e8 f0 1c 00 00       	call   801055ad <memmove>
801038bd:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038c0:	83 ec 0c             	sub    $0xc,%esp
801038c3:	ff 75 f0             	pushl  -0x10(%ebp)
801038c6:	e8 49 c9 ff ff       	call   80100214 <bwrite>
801038cb:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038ce:	83 ec 0c             	sub    $0xc,%esp
801038d1:	ff 75 ec             	pushl  -0x14(%ebp)
801038d4:	e8 88 c9 ff ff       	call   80100261 <brelse>
801038d9:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038dc:	83 ec 0c             	sub    $0xc,%esp
801038df:	ff 75 f0             	pushl  -0x10(%ebp)
801038e2:	e8 7a c9 ff ff       	call   80100261 <brelse>
801038e7:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801038ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038ee:	a1 68 47 11 80       	mov    0x80114768,%eax
801038f3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038f6:	0f 8c 5d ff ff ff    	jl     80103859 <write_log+0x16>
  }
}
801038fc:	90                   	nop
801038fd:	90                   	nop
801038fe:	c9                   	leave  
801038ff:	c3                   	ret    

80103900 <commit>:

static void
commit()
{
80103900:	f3 0f 1e fb          	endbr32 
80103904:	55                   	push   %ebp
80103905:	89 e5                	mov    %esp,%ebp
80103907:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010390a:	a1 68 47 11 80       	mov    0x80114768,%eax
8010390f:	85 c0                	test   %eax,%eax
80103911:	7e 1e                	jle    80103931 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103913:	e8 2b ff ff ff       	call   80103843 <write_log>
    write_head();    // Write header to disk -- the real commit
80103918:	e8 21 fd ff ff       	call   8010363e <write_head>
    install_trans(); // Now install writes to home locations
8010391d:	e8 e7 fb ff ff       	call   80103509 <install_trans>
    log.lh.n = 0;
80103922:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103929:	00 00 00 
    write_head();    // Erase the transaction from the log
8010392c:	e8 0d fd ff ff       	call   8010363e <write_head>
  }
}
80103931:	90                   	nop
80103932:	c9                   	leave  
80103933:	c3                   	ret    

80103934 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103934:	f3 0f 1e fb          	endbr32 
80103938:	55                   	push   %ebp
80103939:	89 e5                	mov    %esp,%ebp
8010393b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010393e:	a1 68 47 11 80       	mov    0x80114768,%eax
80103943:	83 f8 1d             	cmp    $0x1d,%eax
80103946:	7f 12                	jg     8010395a <log_write+0x26>
80103948:	a1 68 47 11 80       	mov    0x80114768,%eax
8010394d:	8b 15 58 47 11 80    	mov    0x80114758,%edx
80103953:	83 ea 01             	sub    $0x1,%edx
80103956:	39 d0                	cmp    %edx,%eax
80103958:	7c 0d                	jl     80103967 <log_write+0x33>
    panic("too big a transaction");
8010395a:	83 ec 0c             	sub    $0xc,%esp
8010395d:	68 3c 8f 10 80       	push   $0x80108f3c
80103962:	e8 a1 cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
80103967:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010396c:	85 c0                	test   %eax,%eax
8010396e:	7f 0d                	jg     8010397d <log_write+0x49>
    panic("log_write outside of trans");
80103970:	83 ec 0c             	sub    $0xc,%esp
80103973:	68 52 8f 10 80       	push   $0x80108f52
80103978:	e8 8b cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
8010397d:	83 ec 0c             	sub    $0xc,%esp
80103980:	68 20 47 11 80       	push   $0x80114720
80103985:	e8 bd 18 00 00       	call   80105247 <acquire>
8010398a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010398d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103994:	eb 1d                	jmp    801039b3 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103999:	83 c0 10             	add    $0x10,%eax
8010399c:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801039a3:	89 c2                	mov    %eax,%edx
801039a5:	8b 45 08             	mov    0x8(%ebp),%eax
801039a8:	8b 40 08             	mov    0x8(%eax),%eax
801039ab:	39 c2                	cmp    %eax,%edx
801039ad:	74 10                	je     801039bf <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039b3:	a1 68 47 11 80       	mov    0x80114768,%eax
801039b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039bb:	7c d9                	jl     80103996 <log_write+0x62>
801039bd:	eb 01                	jmp    801039c0 <log_write+0x8c>
      break;
801039bf:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039c0:	8b 45 08             	mov    0x8(%ebp),%eax
801039c3:	8b 40 08             	mov    0x8(%eax),%eax
801039c6:	89 c2                	mov    %eax,%edx
801039c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cb:	83 c0 10             	add    $0x10,%eax
801039ce:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039d5:	a1 68 47 11 80       	mov    0x80114768,%eax
801039da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039dd:	75 0d                	jne    801039ec <log_write+0xb8>
    log.lh.n++;
801039df:	a1 68 47 11 80       	mov    0x80114768,%eax
801039e4:	83 c0 01             	add    $0x1,%eax
801039e7:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
801039ec:	8b 45 08             	mov    0x8(%ebp),%eax
801039ef:	8b 00                	mov    (%eax),%eax
801039f1:	83 c8 04             	or     $0x4,%eax
801039f4:	89 c2                	mov    %eax,%edx
801039f6:	8b 45 08             	mov    0x8(%ebp),%eax
801039f9:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801039fb:	83 ec 0c             	sub    $0xc,%esp
801039fe:	68 20 47 11 80       	push   $0x80114720
80103a03:	e8 b1 18 00 00       	call   801052b9 <release>
80103a08:	83 c4 10             	add    $0x10,%esp
}
80103a0b:	90                   	nop
80103a0c:	c9                   	leave  
80103a0d:	c3                   	ret    

80103a0e <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a0e:	55                   	push   %ebp
80103a0f:	89 e5                	mov    %esp,%ebp
80103a11:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a14:	8b 55 08             	mov    0x8(%ebp),%edx
80103a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a1d:	f0 87 02             	lock xchg %eax,(%edx)
80103a20:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a23:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a26:	c9                   	leave  
80103a27:	c3                   	ret    

80103a28 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a28:	f3 0f 1e fb          	endbr32 
80103a2c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a30:	83 e4 f0             	and    $0xfffffff0,%esp
80103a33:	ff 71 fc             	pushl  -0x4(%ecx)
80103a36:	55                   	push   %ebp
80103a37:	89 e5                	mov    %esp,%ebp
80103a39:	51                   	push   %ecx
80103a3a:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a3d:	83 ec 08             	sub    $0x8,%esp
80103a40:	68 00 00 40 80       	push   $0x80400000
80103a45:	68 48 75 11 80       	push   $0x80117548
80103a4a:	e8 78 f2 ff ff       	call   80102cc7 <kinit1>
80103a4f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a52:	e8 4b 46 00 00       	call   801080a2 <kvmalloc>
  mpinit();        // detect other processors
80103a57:	e8 d9 03 00 00       	call   80103e35 <mpinit>
  lapicinit();     // interrupt controller
80103a5c:	e8 f5 f5 ff ff       	call   80103056 <lapicinit>
  seginit();       // segment descriptors
80103a61:	e8 ef 40 00 00       	call   80107b55 <seginit>
  picinit();       // disable pic
80103a66:	e8 35 05 00 00       	call   80103fa0 <picinit>
  ioapicinit();    // another interrupt controller
80103a6b:	e8 6a f1 ff ff       	call   80102bda <ioapicinit>
  consoleinit();   // console hardware
80103a70:	e8 6c d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a75:	e8 64 34 00 00       	call   80106ede <uartinit>
  pinit();         // process table
80103a7a:	e8 6e 09 00 00       	call   801043ed <pinit>
  tvinit();        // trap vectors
80103a7f:	e8 0c 30 00 00       	call   80106a90 <tvinit>
  binit();         // buffer cache
80103a84:	e8 ab c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a89:	e8 26 d6 ff ff       	call   801010b4 <fileinit>
  ideinit();       // disk 
80103a8e:	e8 06 ed ff ff       	call   80102799 <ideinit>
  startothers();   // start other processors
80103a93:	e8 88 00 00 00       	call   80103b20 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a98:	83 ec 08             	sub    $0x8,%esp
80103a9b:	68 00 00 00 8e       	push   $0x8e000000
80103aa0:	68 00 00 40 80       	push   $0x80400000
80103aa5:	e8 5a f2 ff ff       	call   80102d04 <kinit2>
80103aaa:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103aad:	e8 31 0b 00 00       	call   801045e3 <userinit>
  mpmain();        // finish this processor's setup
80103ab2:	e8 1e 00 00 00       	call   80103ad5 <mpmain>

80103ab7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103ab7:	f3 0f 1e fb          	endbr32 
80103abb:	55                   	push   %ebp
80103abc:	89 e5                	mov    %esp,%ebp
80103abe:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ac1:	e8 f8 45 00 00       	call   801080be <switchkvm>
  seginit();
80103ac6:	e8 8a 40 00 00       	call   80107b55 <seginit>
  lapicinit();
80103acb:	e8 86 f5 ff ff       	call   80103056 <lapicinit>
  mpmain();
80103ad0:	e8 00 00 00 00       	call   80103ad5 <mpmain>

80103ad5 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103ad5:	f3 0f 1e fb          	endbr32 
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
80103adc:	53                   	push   %ebx
80103add:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103ae0:	e8 2a 09 00 00       	call   8010440f <cpuid>
80103ae5:	89 c3                	mov    %eax,%ebx
80103ae7:	e8 23 09 00 00       	call   8010440f <cpuid>
80103aec:	83 ec 04             	sub    $0x4,%esp
80103aef:	53                   	push   %ebx
80103af0:	50                   	push   %eax
80103af1:	68 6d 8f 10 80       	push   $0x80108f6d
80103af6:	e8 1d c9 ff ff       	call   80100418 <cprintf>
80103afb:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103afe:	e8 07 31 00 00       	call   80106c0a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b03:	e8 26 09 00 00       	call   8010442e <mycpu>
80103b08:	05 a0 00 00 00       	add    $0xa0,%eax
80103b0d:	83 ec 08             	sub    $0x8,%esp
80103b10:	6a 01                	push   $0x1
80103b12:	50                   	push   %eax
80103b13:	e8 f6 fe ff ff       	call   80103a0e <xchg>
80103b18:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b1b:	e8 bd 10 00 00       	call   80104bdd <scheduler>

80103b20 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b20:	f3 0f 1e fb          	endbr32 
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b2a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b31:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b36:	83 ec 04             	sub    $0x4,%esp
80103b39:	50                   	push   %eax
80103b3a:	68 0c c5 10 80       	push   $0x8010c50c
80103b3f:	ff 75 f0             	pushl  -0x10(%ebp)
80103b42:	e8 66 1a 00 00       	call   801055ad <memmove>
80103b47:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b4a:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b51:	eb 79                	jmp    80103bcc <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b53:	e8 d6 08 00 00       	call   8010442e <mycpu>
80103b58:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b5b:	74 67                	je     80103bc4 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b5d:	e8 aa f2 ff ff       	call   80102e0c <kalloc>
80103b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b68:	83 e8 04             	sub    $0x4,%eax
80103b6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b6e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b74:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b79:	83 e8 08             	sub    $0x8,%eax
80103b7c:	c7 00 b7 3a 10 80    	movl   $0x80103ab7,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b82:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b87:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b90:	83 e8 0c             	sub    $0xc,%eax
80103b93:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b98:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba1:	0f b6 00             	movzbl (%eax),%eax
80103ba4:	0f b6 c0             	movzbl %al,%eax
80103ba7:	83 ec 08             	sub    $0x8,%esp
80103baa:	52                   	push   %edx
80103bab:	50                   	push   %eax
80103bac:	e8 17 f6 ff ff       	call   801031c8 <lapicstartap>
80103bb1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103bb4:	90                   	nop
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bbe:	85 c0                	test   %eax,%eax
80103bc0:	74 f3                	je     80103bb5 <startothers+0x95>
80103bc2:	eb 01                	jmp    80103bc5 <startothers+0xa5>
      continue;
80103bc4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bc5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bcc:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bd1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bd7:	05 20 48 11 80       	add    $0x80114820,%eax
80103bdc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bdf:	0f 82 6e ff ff ff    	jb     80103b53 <startothers+0x33>
      ;
  }
}
80103be5:	90                   	nop
80103be6:	90                   	nop
80103be7:	c9                   	leave  
80103be8:	c3                   	ret    

80103be9 <inb>:
{
80103be9:	55                   	push   %ebp
80103bea:	89 e5                	mov    %esp,%ebp
80103bec:	83 ec 14             	sub    $0x14,%esp
80103bef:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103bf6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103bfa:	89 c2                	mov    %eax,%edx
80103bfc:	ec                   	in     (%dx),%al
80103bfd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c00:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c04:	c9                   	leave  
80103c05:	c3                   	ret    

80103c06 <outb>:
{
80103c06:	55                   	push   %ebp
80103c07:	89 e5                	mov    %esp,%ebp
80103c09:	83 ec 08             	sub    $0x8,%esp
80103c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c12:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c16:	89 d0                	mov    %edx,%eax
80103c18:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c1b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c1f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c23:	ee                   	out    %al,(%dx)
}
80103c24:	90                   	nop
80103c25:	c9                   	leave  
80103c26:	c3                   	ret    

80103c27 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c27:	f3 0f 1e fb          	endbr32 
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c31:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c3f:	eb 15                	jmp    80103c56 <sum+0x2f>
    sum += addr[i];
80103c41:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c44:	8b 45 08             	mov    0x8(%ebp),%eax
80103c47:	01 d0                	add    %edx,%eax
80103c49:	0f b6 00             	movzbl (%eax),%eax
80103c4c:	0f b6 c0             	movzbl %al,%eax
80103c4f:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c52:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c59:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c5c:	7c e3                	jl     80103c41 <sum+0x1a>
  return sum;
80103c5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c61:	c9                   	leave  
80103c62:	c3                   	ret    

80103c63 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c63:	f3 0f 1e fb          	endbr32 
80103c67:	55                   	push   %ebp
80103c68:	89 e5                	mov    %esp,%ebp
80103c6a:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c70:	05 00 00 00 80       	add    $0x80000000,%eax
80103c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c78:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7e:	01 d0                	add    %edx,%eax
80103c80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c89:	eb 36                	jmp    80103cc1 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c8b:	83 ec 04             	sub    $0x4,%esp
80103c8e:	6a 04                	push   $0x4
80103c90:	68 84 8f 10 80       	push   $0x80108f84
80103c95:	ff 75 f4             	pushl  -0xc(%ebp)
80103c98:	e8 b4 18 00 00       	call   80105551 <memcmp>
80103c9d:	83 c4 10             	add    $0x10,%esp
80103ca0:	85 c0                	test   %eax,%eax
80103ca2:	75 19                	jne    80103cbd <mpsearch1+0x5a>
80103ca4:	83 ec 08             	sub    $0x8,%esp
80103ca7:	6a 10                	push   $0x10
80103ca9:	ff 75 f4             	pushl  -0xc(%ebp)
80103cac:	e8 76 ff ff ff       	call   80103c27 <sum>
80103cb1:	83 c4 10             	add    $0x10,%esp
80103cb4:	84 c0                	test   %al,%al
80103cb6:	75 05                	jne    80103cbd <mpsearch1+0x5a>
      return (struct mp*)p;
80103cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbb:	eb 11                	jmp    80103cce <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103cbd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cc7:	72 c2                	jb     80103c8b <mpsearch1+0x28>
  return 0;
80103cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cce:	c9                   	leave  
80103ccf:	c3                   	ret    

80103cd0 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cd0:	f3 0f 1e fb          	endbr32 
80103cd4:	55                   	push   %ebp
80103cd5:	89 e5                	mov    %esp,%ebp
80103cd7:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cda:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce4:	83 c0 0f             	add    $0xf,%eax
80103ce7:	0f b6 00             	movzbl (%eax),%eax
80103cea:	0f b6 c0             	movzbl %al,%eax
80103ced:	c1 e0 08             	shl    $0x8,%eax
80103cf0:	89 c2                	mov    %eax,%edx
80103cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf5:	83 c0 0e             	add    $0xe,%eax
80103cf8:	0f b6 00             	movzbl (%eax),%eax
80103cfb:	0f b6 c0             	movzbl %al,%eax
80103cfe:	09 d0                	or     %edx,%eax
80103d00:	c1 e0 04             	shl    $0x4,%eax
80103d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d0a:	74 21                	je     80103d2d <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d0c:	83 ec 08             	sub    $0x8,%esp
80103d0f:	68 00 04 00 00       	push   $0x400
80103d14:	ff 75 f0             	pushl  -0x10(%ebp)
80103d17:	e8 47 ff ff ff       	call   80103c63 <mpsearch1>
80103d1c:	83 c4 10             	add    $0x10,%esp
80103d1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d22:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d26:	74 51                	je     80103d79 <mpsearch+0xa9>
      return mp;
80103d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d2b:	eb 61                	jmp    80103d8e <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d30:	83 c0 14             	add    $0x14,%eax
80103d33:	0f b6 00             	movzbl (%eax),%eax
80103d36:	0f b6 c0             	movzbl %al,%eax
80103d39:	c1 e0 08             	shl    $0x8,%eax
80103d3c:	89 c2                	mov    %eax,%edx
80103d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d41:	83 c0 13             	add    $0x13,%eax
80103d44:	0f b6 00             	movzbl (%eax),%eax
80103d47:	0f b6 c0             	movzbl %al,%eax
80103d4a:	09 d0                	or     %edx,%eax
80103d4c:	c1 e0 0a             	shl    $0xa,%eax
80103d4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d55:	2d 00 04 00 00       	sub    $0x400,%eax
80103d5a:	83 ec 08             	sub    $0x8,%esp
80103d5d:	68 00 04 00 00       	push   $0x400
80103d62:	50                   	push   %eax
80103d63:	e8 fb fe ff ff       	call   80103c63 <mpsearch1>
80103d68:	83 c4 10             	add    $0x10,%esp
80103d6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d6e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d72:	74 05                	je     80103d79 <mpsearch+0xa9>
      return mp;
80103d74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d77:	eb 15                	jmp    80103d8e <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d79:	83 ec 08             	sub    $0x8,%esp
80103d7c:	68 00 00 01 00       	push   $0x10000
80103d81:	68 00 00 0f 00       	push   $0xf0000
80103d86:	e8 d8 fe ff ff       	call   80103c63 <mpsearch1>
80103d8b:	83 c4 10             	add    $0x10,%esp
}
80103d8e:	c9                   	leave  
80103d8f:	c3                   	ret    

80103d90 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d90:	f3 0f 1e fb          	endbr32 
80103d94:	55                   	push   %ebp
80103d95:	89 e5                	mov    %esp,%ebp
80103d97:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d9a:	e8 31 ff ff ff       	call   80103cd0 <mpsearch>
80103d9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103da2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103da6:	74 0a                	je     80103db2 <mpconfig+0x22>
80103da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dab:	8b 40 04             	mov    0x4(%eax),%eax
80103dae:	85 c0                	test   %eax,%eax
80103db0:	75 07                	jne    80103db9 <mpconfig+0x29>
    return 0;
80103db2:	b8 00 00 00 00       	mov    $0x0,%eax
80103db7:	eb 7a                	jmp    80103e33 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbc:	8b 40 04             	mov    0x4(%eax),%eax
80103dbf:	05 00 00 00 80       	add    $0x80000000,%eax
80103dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	6a 04                	push   $0x4
80103dcc:	68 89 8f 10 80       	push   $0x80108f89
80103dd1:	ff 75 f0             	pushl  -0x10(%ebp)
80103dd4:	e8 78 17 00 00       	call   80105551 <memcmp>
80103dd9:	83 c4 10             	add    $0x10,%esp
80103ddc:	85 c0                	test   %eax,%eax
80103dde:	74 07                	je     80103de7 <mpconfig+0x57>
    return 0;
80103de0:	b8 00 00 00 00       	mov    $0x0,%eax
80103de5:	eb 4c                	jmp    80103e33 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dea:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103dee:	3c 01                	cmp    $0x1,%al
80103df0:	74 12                	je     80103e04 <mpconfig+0x74>
80103df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103df9:	3c 04                	cmp    $0x4,%al
80103dfb:	74 07                	je     80103e04 <mpconfig+0x74>
    return 0;
80103dfd:	b8 00 00 00 00       	mov    $0x0,%eax
80103e02:	eb 2f                	jmp    80103e33 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e07:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e0b:	0f b7 c0             	movzwl %ax,%eax
80103e0e:	83 ec 08             	sub    $0x8,%esp
80103e11:	50                   	push   %eax
80103e12:	ff 75 f0             	pushl  -0x10(%ebp)
80103e15:	e8 0d fe ff ff       	call   80103c27 <sum>
80103e1a:	83 c4 10             	add    $0x10,%esp
80103e1d:	84 c0                	test   %al,%al
80103e1f:	74 07                	je     80103e28 <mpconfig+0x98>
    return 0;
80103e21:	b8 00 00 00 00       	mov    $0x0,%eax
80103e26:	eb 0b                	jmp    80103e33 <mpconfig+0xa3>
  *pmp = mp;
80103e28:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e2e:	89 10                	mov    %edx,(%eax)
  return conf;
80103e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e33:	c9                   	leave  
80103e34:	c3                   	ret    

80103e35 <mpinit>:

void
mpinit(void)
{
80103e35:	f3 0f 1e fb          	endbr32 
80103e39:	55                   	push   %ebp
80103e3a:	89 e5                	mov    %esp,%ebp
80103e3c:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e3f:	83 ec 0c             	sub    $0xc,%esp
80103e42:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e45:	50                   	push   %eax
80103e46:	e8 45 ff ff ff       	call   80103d90 <mpconfig>
80103e4b:	83 c4 10             	add    $0x10,%esp
80103e4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e55:	75 0d                	jne    80103e64 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e57:	83 ec 0c             	sub    $0xc,%esp
80103e5a:	68 8e 8f 10 80       	push   $0x80108f8e
80103e5f:	e8 a4 c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e64:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e6e:	8b 40 24             	mov    0x24(%eax),%eax
80103e71:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e79:	83 c0 2c             	add    $0x2c,%eax
80103e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e82:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e86:	0f b7 d0             	movzwl %ax,%edx
80103e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e8c:	01 d0                	add    %edx,%eax
80103e8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e91:	e9 8c 00 00 00       	jmp    80103f22 <mpinit+0xed>
    switch(*p){
80103e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e99:	0f b6 00             	movzbl (%eax),%eax
80103e9c:	0f b6 c0             	movzbl %al,%eax
80103e9f:	83 f8 04             	cmp    $0x4,%eax
80103ea2:	7f 76                	jg     80103f1a <mpinit+0xe5>
80103ea4:	83 f8 03             	cmp    $0x3,%eax
80103ea7:	7d 6b                	jge    80103f14 <mpinit+0xdf>
80103ea9:	83 f8 02             	cmp    $0x2,%eax
80103eac:	74 4e                	je     80103efc <mpinit+0xc7>
80103eae:	83 f8 02             	cmp    $0x2,%eax
80103eb1:	7f 67                	jg     80103f1a <mpinit+0xe5>
80103eb3:	85 c0                	test   %eax,%eax
80103eb5:	74 07                	je     80103ebe <mpinit+0x89>
80103eb7:	83 f8 01             	cmp    $0x1,%eax
80103eba:	74 58                	je     80103f14 <mpinit+0xdf>
80103ebc:	eb 5c                	jmp    80103f1a <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103ec4:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ec9:	83 f8 07             	cmp    $0x7,%eax
80103ecc:	7f 28                	jg     80103ef6 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ece:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ed7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103edb:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ee1:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103ee7:	88 02                	mov    %al,(%edx)
        ncpu++;
80103ee9:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103eee:	83 c0 01             	add    $0x1,%eax
80103ef1:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103ef6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103efa:	eb 26                	jmp    80103f22 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f05:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f09:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f0e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f12:	eb 0e                	jmp    80103f22 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f14:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f18:	eb 08                	jmp    80103f22 <mpinit+0xed>
    default:
      ismp = 0;
80103f1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f21:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f25:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f28:	0f 82 68 ff ff ff    	jb     80103e96 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f32:	75 0d                	jne    80103f41 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f34:	83 ec 0c             	sub    $0xc,%esp
80103f37:	68 a8 8f 10 80       	push   $0x80108fa8
80103f3c:	e8 c7 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f41:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f44:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f48:	84 c0                	test   %al,%al
80103f4a:	74 30                	je     80103f7c <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f4c:	83 ec 08             	sub    $0x8,%esp
80103f4f:	6a 70                	push   $0x70
80103f51:	6a 22                	push   $0x22
80103f53:	e8 ae fc ff ff       	call   80103c06 <outb>
80103f58:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f5b:	83 ec 0c             	sub    $0xc,%esp
80103f5e:	6a 23                	push   $0x23
80103f60:	e8 84 fc ff ff       	call   80103be9 <inb>
80103f65:	83 c4 10             	add    $0x10,%esp
80103f68:	83 c8 01             	or     $0x1,%eax
80103f6b:	0f b6 c0             	movzbl %al,%eax
80103f6e:	83 ec 08             	sub    $0x8,%esp
80103f71:	50                   	push   %eax
80103f72:	6a 23                	push   $0x23
80103f74:	e8 8d fc ff ff       	call   80103c06 <outb>
80103f79:	83 c4 10             	add    $0x10,%esp
  }
}
80103f7c:	90                   	nop
80103f7d:	c9                   	leave  
80103f7e:	c3                   	ret    

80103f7f <outb>:
{
80103f7f:	55                   	push   %ebp
80103f80:	89 e5                	mov    %esp,%ebp
80103f82:	83 ec 08             	sub    $0x8,%esp
80103f85:	8b 45 08             	mov    0x8(%ebp),%eax
80103f88:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f8b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f8f:	89 d0                	mov    %edx,%eax
80103f91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f9c:	ee                   	out    %al,(%dx)
}
80103f9d:	90                   	nop
80103f9e:	c9                   	leave  
80103f9f:	c3                   	ret    

80103fa0 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103fa0:	f3 0f 1e fb          	endbr32 
80103fa4:	55                   	push   %ebp
80103fa5:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fa7:	68 ff 00 00 00       	push   $0xff
80103fac:	6a 21                	push   $0x21
80103fae:	e8 cc ff ff ff       	call   80103f7f <outb>
80103fb3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fb6:	68 ff 00 00 00       	push   $0xff
80103fbb:	68 a1 00 00 00       	push   $0xa1
80103fc0:	e8 ba ff ff ff       	call   80103f7f <outb>
80103fc5:	83 c4 08             	add    $0x8,%esp
}
80103fc8:	90                   	nop
80103fc9:	c9                   	leave  
80103fca:	c3                   	ret    

80103fcb <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fcb:	f3 0f 1e fb          	endbr32 
80103fcf:	55                   	push   %ebp
80103fd0:	89 e5                	mov    %esp,%ebp
80103fd2:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fdf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe8:	8b 10                	mov    (%eax),%edx
80103fea:	8b 45 08             	mov    0x8(%ebp),%eax
80103fed:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fef:	e8 e2 d0 ff ff       	call   801010d6 <filealloc>
80103ff4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff7:	89 02                	mov    %eax,(%edx)
80103ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffc:	8b 00                	mov    (%eax),%eax
80103ffe:	85 c0                	test   %eax,%eax
80104000:	0f 84 c8 00 00 00    	je     801040ce <pipealloc+0x103>
80104006:	e8 cb d0 ff ff       	call   801010d6 <filealloc>
8010400b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010400e:	89 02                	mov    %eax,(%edx)
80104010:	8b 45 0c             	mov    0xc(%ebp),%eax
80104013:	8b 00                	mov    (%eax),%eax
80104015:	85 c0                	test   %eax,%eax
80104017:	0f 84 b1 00 00 00    	je     801040ce <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010401d:	e8 ea ed ff ff       	call   80102e0c <kalloc>
80104022:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104025:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104029:	0f 84 a2 00 00 00    	je     801040d1 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104039:	00 00 00 
  p->writeopen = 1;
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104046:	00 00 00 
  p->nwrite = 0;
80104049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104053:	00 00 00 
  p->nread = 0;
80104056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104059:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104060:	00 00 00 
  initlock(&p->lock, "pipe");
80104063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104066:	83 ec 08             	sub    $0x8,%esp
80104069:	68 c7 8f 10 80       	push   $0x80108fc7
8010406e:	50                   	push   %eax
8010406f:	e8 ad 11 00 00       	call   80105221 <initlock>
80104074:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104082:	8b 45 08             	mov    0x8(%ebp),%eax
80104085:	8b 00                	mov    (%eax),%eax
80104087:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010408b:	8b 45 08             	mov    0x8(%ebp),%eax
8010408e:	8b 00                	mov    (%eax),%eax
80104090:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104094:	8b 45 08             	mov    0x8(%ebp),%eax
80104097:	8b 00                	mov    (%eax),%eax
80104099:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010409f:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a2:	8b 00                	mov    (%eax),%eax
801040a4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ad:	8b 00                	mov    (%eax),%eax
801040af:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b6:	8b 00                	mov    (%eax),%eax
801040b8:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801040bf:	8b 00                	mov    (%eax),%eax
801040c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c4:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c7:	b8 00 00 00 00       	mov    $0x0,%eax
801040cc:	eb 51                	jmp    8010411f <pipealloc+0x154>
    goto bad;
801040ce:	90                   	nop
801040cf:	eb 01                	jmp    801040d2 <pipealloc+0x107>
    goto bad;
801040d1:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040d6:	74 0e                	je     801040e6 <pipealloc+0x11b>
    kfree((char*)p);
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	ff 75 f4             	pushl  -0xc(%ebp)
801040de:	e8 8b ec ff ff       	call   80102d6e <kfree>
801040e3:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 00                	mov    (%eax),%eax
801040eb:	85 c0                	test   %eax,%eax
801040ed:	74 11                	je     80104100 <pipealloc+0x135>
    fileclose(*f0);
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 00                	mov    (%eax),%eax
801040f4:	83 ec 0c             	sub    $0xc,%esp
801040f7:	50                   	push   %eax
801040f8:	e8 9f d0 ff ff       	call   8010119c <fileclose>
801040fd:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104100:	8b 45 0c             	mov    0xc(%ebp),%eax
80104103:	8b 00                	mov    (%eax),%eax
80104105:	85 c0                	test   %eax,%eax
80104107:	74 11                	je     8010411a <pipealloc+0x14f>
    fileclose(*f1);
80104109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410c:	8b 00                	mov    (%eax),%eax
8010410e:	83 ec 0c             	sub    $0xc,%esp
80104111:	50                   	push   %eax
80104112:	e8 85 d0 ff ff       	call   8010119c <fileclose>
80104117:	83 c4 10             	add    $0x10,%esp
  return -1;
8010411a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010411f:	c9                   	leave  
80104120:	c3                   	ret    

80104121 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104121:	f3 0f 1e fb          	endbr32 
80104125:	55                   	push   %ebp
80104126:	89 e5                	mov    %esp,%ebp
80104128:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010412b:	8b 45 08             	mov    0x8(%ebp),%eax
8010412e:	83 ec 0c             	sub    $0xc,%esp
80104131:	50                   	push   %eax
80104132:	e8 10 11 00 00       	call   80105247 <acquire>
80104137:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010413a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010413e:	74 23                	je     80104163 <pipeclose+0x42>
    p->writeopen = 0;
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010414a:	00 00 00 
    wakeup(&p->nread);
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	05 34 02 00 00       	add    $0x234,%eax
80104155:	83 ec 0c             	sub    $0xc,%esp
80104158:	50                   	push   %eax
80104159:	e8 6f 0d 00 00       	call   80104ecd <wakeup>
8010415e:	83 c4 10             	add    $0x10,%esp
80104161:	eb 21                	jmp    80104184 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010416d:	00 00 00 
    wakeup(&p->nwrite);
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	05 38 02 00 00       	add    $0x238,%eax
80104178:	83 ec 0c             	sub    $0xc,%esp
8010417b:	50                   	push   %eax
8010417c:	e8 4c 0d 00 00       	call   80104ecd <wakeup>
80104181:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104184:	8b 45 08             	mov    0x8(%ebp),%eax
80104187:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010418d:	85 c0                	test   %eax,%eax
8010418f:	75 2c                	jne    801041bd <pipeclose+0x9c>
80104191:	8b 45 08             	mov    0x8(%ebp),%eax
80104194:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010419a:	85 c0                	test   %eax,%eax
8010419c:	75 1f                	jne    801041bd <pipeclose+0x9c>
    release(&p->lock);
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	83 ec 0c             	sub    $0xc,%esp
801041a4:	50                   	push   %eax
801041a5:	e8 0f 11 00 00       	call   801052b9 <release>
801041aa:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041ad:	83 ec 0c             	sub    $0xc,%esp
801041b0:	ff 75 08             	pushl  0x8(%ebp)
801041b3:	e8 b6 eb ff ff       	call   80102d6e <kfree>
801041b8:	83 c4 10             	add    $0x10,%esp
801041bb:	eb 10                	jmp    801041cd <pipeclose+0xac>
  } else
    release(&p->lock);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	50                   	push   %eax
801041c4:	e8 f0 10 00 00       	call   801052b9 <release>
801041c9:	83 c4 10             	add    $0x10,%esp
}
801041cc:	90                   	nop
801041cd:	90                   	nop
801041ce:	c9                   	leave  
801041cf:	c3                   	ret    

801041d0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041d0:	f3 0f 1e fb          	endbr32 
801041d4:	55                   	push   %ebp
801041d5:	89 e5                	mov    %esp,%ebp
801041d7:	53                   	push   %ebx
801041d8:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041db:	8b 45 08             	mov    0x8(%ebp),%eax
801041de:	83 ec 0c             	sub    $0xc,%esp
801041e1:	50                   	push   %eax
801041e2:	e8 60 10 00 00       	call   80105247 <acquire>
801041e7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041f1:	e9 ad 00 00 00       	jmp    801042a3 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041ff:	85 c0                	test   %eax,%eax
80104201:	74 0c                	je     8010420f <pipewrite+0x3f>
80104203:	e8 a2 02 00 00       	call   801044aa <myproc>
80104208:	8b 40 24             	mov    0x24(%eax),%eax
8010420b:	85 c0                	test   %eax,%eax
8010420d:	74 19                	je     80104228 <pipewrite+0x58>
        release(&p->lock);
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	50                   	push   %eax
80104216:	e8 9e 10 00 00       	call   801052b9 <release>
8010421b:	83 c4 10             	add    $0x10,%esp
        return -1;
8010421e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104223:	e9 a9 00 00 00       	jmp    801042d1 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80104228:	8b 45 08             	mov    0x8(%ebp),%eax
8010422b:	05 34 02 00 00       	add    $0x234,%eax
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	50                   	push   %eax
80104234:	e8 94 0c 00 00       	call   80104ecd <wakeup>
80104239:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	8b 55 08             	mov    0x8(%ebp),%edx
80104242:	81 c2 38 02 00 00    	add    $0x238,%edx
80104248:	83 ec 08             	sub    $0x8,%esp
8010424b:	50                   	push   %eax
8010424c:	52                   	push   %edx
8010424d:	e8 8c 0b 00 00       	call   80104dde <sleep>
80104252:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104255:	8b 45 08             	mov    0x8(%ebp),%eax
80104258:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104267:	05 00 02 00 00       	add    $0x200,%eax
8010426c:	39 c2                	cmp    %eax,%edx
8010426e:	74 86                	je     801041f6 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104270:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104273:	8b 45 0c             	mov    0xc(%ebp),%eax
80104276:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104282:	8d 48 01             	lea    0x1(%eax),%ecx
80104285:	8b 55 08             	mov    0x8(%ebp),%edx
80104288:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010428e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104293:	89 c1                	mov    %eax,%ecx
80104295:	0f b6 13             	movzbl (%ebx),%edx
80104298:	8b 45 08             	mov    0x8(%ebp),%eax
8010429b:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010429f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801042a9:	7c aa                	jl     80104255 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	05 34 02 00 00       	add    $0x234,%eax
801042b3:	83 ec 0c             	sub    $0xc,%esp
801042b6:	50                   	push   %eax
801042b7:	e8 11 0c 00 00       	call   80104ecd <wakeup>
801042bc:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	83 ec 0c             	sub    $0xc,%esp
801042c5:	50                   	push   %eax
801042c6:	e8 ee 0f 00 00       	call   801052b9 <release>
801042cb:	83 c4 10             	add    $0x10,%esp
  return n;
801042ce:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042d4:	c9                   	leave  
801042d5:	c3                   	ret    

801042d6 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042d6:	f3 0f 1e fb          	endbr32 
801042da:	55                   	push   %ebp
801042db:	89 e5                	mov    %esp,%ebp
801042dd:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042e0:	8b 45 08             	mov    0x8(%ebp),%eax
801042e3:	83 ec 0c             	sub    $0xc,%esp
801042e6:	50                   	push   %eax
801042e7:	e8 5b 0f 00 00       	call   80105247 <acquire>
801042ec:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042ef:	eb 3e                	jmp    8010432f <piperead+0x59>
    if(myproc()->killed){
801042f1:	e8 b4 01 00 00       	call   801044aa <myproc>
801042f6:	8b 40 24             	mov    0x24(%eax),%eax
801042f9:	85 c0                	test   %eax,%eax
801042fb:	74 19                	je     80104316 <piperead+0x40>
      release(&p->lock);
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	50                   	push   %eax
80104304:	e8 b0 0f 00 00       	call   801052b9 <release>
80104309:	83 c4 10             	add    $0x10,%esp
      return -1;
8010430c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104311:	e9 be 00 00 00       	jmp    801043d4 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104316:	8b 45 08             	mov    0x8(%ebp),%eax
80104319:	8b 55 08             	mov    0x8(%ebp),%edx
8010431c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104322:	83 ec 08             	sub    $0x8,%esp
80104325:	50                   	push   %eax
80104326:	52                   	push   %edx
80104327:	e8 b2 0a 00 00       	call   80104dde <sleep>
8010432c:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010432f:	8b 45 08             	mov    0x8(%ebp),%eax
80104332:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104338:	8b 45 08             	mov    0x8(%ebp),%eax
8010433b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104341:	39 c2                	cmp    %eax,%edx
80104343:	75 0d                	jne    80104352 <piperead+0x7c>
80104345:	8b 45 08             	mov    0x8(%ebp),%eax
80104348:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010434e:	85 c0                	test   %eax,%eax
80104350:	75 9f                	jne    801042f1 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104359:	eb 48                	jmp    801043a3 <piperead+0xcd>
    if(p->nread == p->nwrite)
8010435b:	8b 45 08             	mov    0x8(%ebp),%eax
8010435e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104364:	8b 45 08             	mov    0x8(%ebp),%eax
80104367:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010436d:	39 c2                	cmp    %eax,%edx
8010436f:	74 3c                	je     801043ad <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010437a:	8d 48 01             	lea    0x1(%eax),%ecx
8010437d:	8b 55 08             	mov    0x8(%ebp),%edx
80104380:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104386:	25 ff 01 00 00       	and    $0x1ff,%eax
8010438b:	89 c1                	mov    %eax,%ecx
8010438d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104390:	8b 45 0c             	mov    0xc(%ebp),%eax
80104393:	01 c2                	add    %eax,%edx
80104395:	8b 45 08             	mov    0x8(%ebp),%eax
80104398:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010439d:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010439f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801043a9:	7c b0                	jl     8010435b <piperead+0x85>
801043ab:	eb 01                	jmp    801043ae <piperead+0xd8>
      break;
801043ad:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043ae:	8b 45 08             	mov    0x8(%ebp),%eax
801043b1:	05 38 02 00 00       	add    $0x238,%eax
801043b6:	83 ec 0c             	sub    $0xc,%esp
801043b9:	50                   	push   %eax
801043ba:	e8 0e 0b 00 00       	call   80104ecd <wakeup>
801043bf:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043c2:	8b 45 08             	mov    0x8(%ebp),%eax
801043c5:	83 ec 0c             	sub    $0xc,%esp
801043c8:	50                   	push   %eax
801043c9:	e8 eb 0e 00 00       	call   801052b9 <release>
801043ce:	83 c4 10             	add    $0x10,%esp
  return i;
801043d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043d4:	c9                   	leave  
801043d5:	c3                   	ret    

801043d6 <readeflags>:
{
801043d6:	55                   	push   %ebp
801043d7:	89 e5                	mov    %esp,%ebp
801043d9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043dc:	9c                   	pushf  
801043dd:	58                   	pop    %eax
801043de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043e4:	c9                   	leave  
801043e5:	c3                   	ret    

801043e6 <sti>:
{
801043e6:	55                   	push   %ebp
801043e7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043e9:	fb                   	sti    
}
801043ea:	90                   	nop
801043eb:	5d                   	pop    %ebp
801043ec:	c3                   	ret    

801043ed <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043ed:	f3 0f 1e fb          	endbr32 
801043f1:	55                   	push   %ebp
801043f2:	89 e5                	mov    %esp,%ebp
801043f4:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043f7:	83 ec 08             	sub    $0x8,%esp
801043fa:	68 cc 8f 10 80       	push   $0x80108fcc
801043ff:	68 c0 4d 11 80       	push   $0x80114dc0
80104404:	e8 18 0e 00 00       	call   80105221 <initlock>
80104409:	83 c4 10             	add    $0x10,%esp
}
8010440c:	90                   	nop
8010440d:	c9                   	leave  
8010440e:	c3                   	ret    

8010440f <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010440f:	f3 0f 1e fb          	endbr32 
80104413:	55                   	push   %ebp
80104414:	89 e5                	mov    %esp,%ebp
80104416:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104419:	e8 10 00 00 00       	call   8010442e <mycpu>
8010441e:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104423:	c1 f8 04             	sar    $0x4,%eax
80104426:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010442c:	c9                   	leave  
8010442d:	c3                   	ret    

8010442e <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010442e:	f3 0f 1e fb          	endbr32 
80104432:	55                   	push   %ebp
80104433:	89 e5                	mov    %esp,%ebp
80104435:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104438:	e8 99 ff ff ff       	call   801043d6 <readeflags>
8010443d:	25 00 02 00 00       	and    $0x200,%eax
80104442:	85 c0                	test   %eax,%eax
80104444:	74 0d                	je     80104453 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80104446:	83 ec 0c             	sub    $0xc,%esp
80104449:	68 d4 8f 10 80       	push   $0x80108fd4
8010444e:	e8 b5 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
80104453:	e8 21 ed ff ff       	call   80103179 <lapicid>
80104458:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010445b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104462:	eb 2d                	jmp    80104491 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104467:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010446d:	05 20 48 11 80       	add    $0x80114820,%eax
80104472:	0f b6 00             	movzbl (%eax),%eax
80104475:	0f b6 c0             	movzbl %al,%eax
80104478:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010447b:	75 10                	jne    8010448d <mycpu+0x5f>
      return &cpus[i];
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104486:	05 20 48 11 80       	add    $0x80114820,%eax
8010448b:	eb 1b                	jmp    801044a8 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
8010448d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104491:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80104496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104499:	7c c9                	jl     80104464 <mycpu+0x36>
  }
  panic("unknown apicid\n");
8010449b:	83 ec 0c             	sub    $0xc,%esp
8010449e:	68 fa 8f 10 80       	push   $0x80108ffa
801044a3:	e8 60 c1 ff ff       	call   80100608 <panic>
}
801044a8:	c9                   	leave  
801044a9:	c3                   	ret    

801044aa <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044aa:	f3 0f 1e fb          	endbr32 
801044ae:	55                   	push   %ebp
801044af:	89 e5                	mov    %esp,%ebp
801044b1:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044b4:	e8 1a 0f 00 00       	call   801053d3 <pushcli>
  c = mycpu();
801044b9:	e8 70 ff ff ff       	call   8010442e <mycpu>
801044be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044cd:	e8 52 0f 00 00       	call   80105424 <popcli>
  return p;
801044d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044d5:	c9                   	leave  
801044d6:	c3                   	ret    

801044d7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044d7:	f3 0f 1e fb          	endbr32 
801044db:	55                   	push   %ebp
801044dc:	89 e5                	mov    %esp,%ebp
801044de:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044e1:	83 ec 0c             	sub    $0xc,%esp
801044e4:	68 c0 4d 11 80       	push   $0x80114dc0
801044e9:	e8 59 0d 00 00       	call   80105247 <acquire>
801044ee:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044f1:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
801044f8:	eb 0e                	jmp    80104508 <allocproc+0x31>
    if(p->state == UNUSED)
801044fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fd:	8b 40 0c             	mov    0xc(%eax),%eax
80104500:	85 c0                	test   %eax,%eax
80104502:	74 27                	je     8010452b <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104504:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104508:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
8010450f:	72 e9                	jb     801044fa <allocproc+0x23>
      goto found;

  release(&ptable.lock);
80104511:	83 ec 0c             	sub    $0xc,%esp
80104514:	68 c0 4d 11 80       	push   $0x80114dc0
80104519:	e8 9b 0d 00 00       	call   801052b9 <release>
8010451e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104521:	b8 00 00 00 00       	mov    $0x0,%eax
80104526:	e9 b6 00 00 00       	jmp    801045e1 <allocproc+0x10a>
      goto found;
8010452b:	90                   	nop
8010452c:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104533:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010453a:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010453f:	8d 50 01             	lea    0x1(%eax),%edx
80104542:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454b:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010454e:	83 ec 0c             	sub    $0xc,%esp
80104551:	68 c0 4d 11 80       	push   $0x80114dc0
80104556:	e8 5e 0d 00 00       	call   801052b9 <release>
8010455b:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010455e:	e8 a9 e8 ff ff       	call   80102e0c <kalloc>
80104563:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104566:	89 42 08             	mov    %eax,0x8(%edx)
80104569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456c:	8b 40 08             	mov    0x8(%eax),%eax
8010456f:	85 c0                	test   %eax,%eax
80104571:	75 11                	jne    80104584 <allocproc+0xad>
    p->state = UNUSED;
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010457d:	b8 00 00 00 00       	mov    $0x0,%eax
80104582:	eb 5d                	jmp    801045e1 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80104584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104587:	8b 40 08             	mov    0x8(%eax),%eax
8010458a:	05 00 10 00 00       	add    $0x1000,%eax
8010458f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104592:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010459c:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010459f:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045a3:	ba 4a 6a 10 80       	mov    $0x80106a4a,%edx
801045a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ab:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045ad:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b7:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bd:	8b 40 1c             	mov    0x1c(%eax),%eax
801045c0:	83 ec 04             	sub    $0x4,%esp
801045c3:	6a 14                	push   $0x14
801045c5:	6a 00                	push   $0x0
801045c7:	50                   	push   %eax
801045c8:	e8 19 0f 00 00       	call   801054e6 <memset>
801045cd:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d3:	8b 40 1c             	mov    0x1c(%eax),%eax
801045d6:	ba 94 4d 10 80       	mov    $0x80104d94,%edx
801045db:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045e1:	c9                   	leave  
801045e2:	c3                   	ret    

801045e3 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045e3:	f3 0f 1e fb          	endbr32 
801045e7:	55                   	push   %ebp
801045e8:	89 e5                	mov    %esp,%ebp
801045ea:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045ed:	e8 e5 fe ff ff       	call   801044d7 <allocproc>
801045f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
801045fd:	e8 03 3a 00 00       	call   80108005 <setupkvm>
80104602:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104605:	89 42 04             	mov    %eax,0x4(%edx)
80104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460b:	8b 40 04             	mov    0x4(%eax),%eax
8010460e:	85 c0                	test   %eax,%eax
80104610:	75 0d                	jne    8010461f <userinit+0x3c>
    panic("userinit: out of memory?");
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	68 0a 90 10 80       	push   $0x8010900a
8010461a:	e8 e9 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010461f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 04             	mov    0x4(%eax),%eax
8010462a:	83 ec 04             	sub    $0x4,%esp
8010462d:	52                   	push   %edx
8010462e:	68 e0 c4 10 80       	push   $0x8010c4e0
80104633:	50                   	push   %eax
80104634:	e8 45 3c 00 00       	call   8010827e <inituvm>
80104639:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104648:	8b 40 18             	mov    0x18(%eax),%eax
8010464b:	83 ec 04             	sub    $0x4,%esp
8010464e:	6a 4c                	push   $0x4c
80104650:	6a 00                	push   $0x0
80104652:	50                   	push   %eax
80104653:	e8 8e 0e 00 00       	call   801054e6 <memset>
80104658:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	8b 40 18             	mov    0x18(%eax),%eax
80104661:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466a:	8b 40 18             	mov    0x18(%eax),%eax
8010466d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104676:	8b 50 18             	mov    0x18(%eax),%edx
80104679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467c:	8b 40 18             	mov    0x18(%eax),%eax
8010467f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104683:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468a:	8b 50 18             	mov    0x18(%eax),%edx
8010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104690:	8b 40 18             	mov    0x18(%eax),%eax
80104693:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104697:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469e:	8b 40 18             	mov    0x18(%eax),%eax
801046a1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ab:	8b 40 18             	mov    0x18(%eax),%eax
801046ae:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b8:	8b 40 18             	mov    0x18(%eax),%eax
801046bb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c5:	83 c0 6c             	add    $0x6c,%eax
801046c8:	83 ec 04             	sub    $0x4,%esp
801046cb:	6a 10                	push   $0x10
801046cd:	68 23 90 10 80       	push   $0x80109023
801046d2:	50                   	push   %eax
801046d3:	e8 29 10 00 00       	call   80105701 <safestrcpy>
801046d8:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046db:	83 ec 0c             	sub    $0xc,%esp
801046de:	68 2c 90 10 80       	push   $0x8010902c
801046e3:	e8 9f df ff ff       	call   80102687 <namei>
801046e8:	83 c4 10             	add    $0x10,%esp
801046eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046ee:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801046f1:	83 ec 0c             	sub    $0xc,%esp
801046f4:	68 c0 4d 11 80       	push   $0x80114dc0
801046f9:	e8 49 0b 00 00       	call   80105247 <acquire>
801046fe:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010470b:	83 ec 0c             	sub    $0xc,%esp
8010470e:	68 c0 4d 11 80       	push   $0x80114dc0
80104713:	e8 a1 0b 00 00       	call   801052b9 <release>
80104718:	83 c4 10             	add    $0x10,%esp
}
8010471b:	90                   	nop
8010471c:	c9                   	leave  
8010471d:	c3                   	ret    

8010471e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010471e:	f3 0f 1e fb          	endbr32 
80104722:	55                   	push   %ebp
80104723:	89 e5                	mov    %esp,%ebp
80104725:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104728:	e8 7d fd ff ff       	call   801044aa <myproc>
8010472d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104733:	8b 00                	mov    (%eax),%eax
80104735:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104738:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010473c:	7e 31                	jle    8010476f <growproc+0x51>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010473e:	8b 55 08             	mov    0x8(%ebp),%edx
80104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104744:	01 c2                	add    %eax,%edx
80104746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104749:	8b 40 04             	mov    0x4(%eax),%eax
8010474c:	83 ec 04             	sub    $0x4,%esp
8010474f:	52                   	push   %edx
80104750:	ff 75 f4             	pushl  -0xc(%ebp)
80104753:	50                   	push   %eax
80104754:	e8 6a 3c 00 00       	call   801083c3 <allocuvm>
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010475f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104763:	75 3e                	jne    801047a3 <growproc+0x85>
      return -1;
80104765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476a:	e9 a7 00 00 00       	jmp    80104816 <growproc+0xf8>
  } else if(n < 0){
8010476f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104773:	79 2e                	jns    801047a3 <growproc+0x85>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104775:	8b 55 08             	mov    0x8(%ebp),%edx
80104778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477b:	01 c2                	add    %eax,%edx
8010477d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104780:	8b 40 04             	mov    0x4(%eax),%eax
80104783:	83 ec 04             	sub    $0x4,%esp
80104786:	52                   	push   %edx
80104787:	ff 75 f4             	pushl  -0xc(%ebp)
8010478a:	50                   	push   %eax
8010478b:	e8 3c 3d 00 00       	call   801084cc <deallocuvm>
80104790:	83 c4 10             	add    $0x10,%esp
80104793:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104796:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010479a:	75 07                	jne    801047a3 <growproc+0x85>
      return -1;
8010479c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a1:	eb 73                	jmp    80104816 <growproc+0xf8>
  }
  curproc->sz = sz;
801047a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a9:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	ff 75 f0             	pushl  -0x10(%ebp)
801047b1:	e8 25 39 00 00       	call   801080db <switchuvm>
801047b6:	83 c4 10             	add    $0x10,%esp
  //p5 melody changes
  uint page_num=n/PGSIZE;
801047b9:	8b 45 08             	mov    0x8(%ebp),%eax
801047bc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801047c2:	85 c0                	test   %eax,%eax
801047c4:	0f 48 c2             	cmovs  %edx,%eax
801047c7:	c1 f8 0c             	sar    $0xc,%eax
801047ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  cprintf("growproc-page_num:%d\n",page_num);
801047cd:	83 ec 08             	sub    $0x8,%esp
801047d0:	ff 75 ec             	pushl  -0x14(%ebp)
801047d3:	68 2e 90 10 80       	push   $0x8010902e
801047d8:	e8 3b bc ff ff       	call   80100418 <cprintf>
801047dd:	83 c4 10             	add    $0x10,%esp
  if(mencrypt((char*)PGROUNDUP(sz-n),page_num)!=0) return -1;
801047e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e3:	8b 55 08             	mov    0x8(%ebp),%edx
801047e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047e9:	29 d1                	sub    %edx,%ecx
801047eb:	89 ca                	mov    %ecx,%edx
801047ed:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
801047f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801047f9:	83 ec 08             	sub    $0x8,%esp
801047fc:	50                   	push   %eax
801047fd:	52                   	push   %edx
801047fe:	e8 34 41 00 00       	call   80108937 <mencrypt>
80104803:	83 c4 10             	add    $0x10,%esp
80104806:	85 c0                	test   %eax,%eax
80104808:	74 07                	je     80104811 <growproc+0xf3>
8010480a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480f:	eb 05                	jmp    80104816 <growproc+0xf8>
  //ends
  return 0;
80104811:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104816:	c9                   	leave  
80104817:	c3                   	ret    

80104818 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104818:	f3 0f 1e fb          	endbr32 
8010481c:	55                   	push   %ebp
8010481d:	89 e5                	mov    %esp,%ebp
8010481f:	57                   	push   %edi
80104820:	56                   	push   %esi
80104821:	53                   	push   %ebx
80104822:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104825:	e8 80 fc ff ff       	call   801044aa <myproc>
8010482a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010482d:	e8 a5 fc ff ff       	call   801044d7 <allocproc>
80104832:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104835:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104839:	75 0a                	jne    80104845 <fork+0x2d>
    return -1;
8010483b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104840:	e9 48 01 00 00       	jmp    8010498d <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104845:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104848:	8b 10                	mov    (%eax),%edx
8010484a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484d:	8b 40 04             	mov    0x4(%eax),%eax
80104850:	83 ec 08             	sub    $0x8,%esp
80104853:	52                   	push   %edx
80104854:	50                   	push   %eax
80104855:	e8 1e 3e 00 00       	call   80108678 <copyuvm>
8010485a:	83 c4 10             	add    $0x10,%esp
8010485d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104860:	89 42 04             	mov    %eax,0x4(%edx)
80104863:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104866:	8b 40 04             	mov    0x4(%eax),%eax
80104869:	85 c0                	test   %eax,%eax
8010486b:	75 30                	jne    8010489d <fork+0x85>
    kfree(np->kstack);
8010486d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104870:	8b 40 08             	mov    0x8(%eax),%eax
80104873:	83 ec 0c             	sub    $0xc,%esp
80104876:	50                   	push   %eax
80104877:	e8 f2 e4 ff ff       	call   80102d6e <kfree>
8010487c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010487f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104882:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104889:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010488c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104898:	e9 f0 00 00 00       	jmp    8010498d <fork+0x175>
  }
  np->sz = curproc->sz;
8010489d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a0:	8b 10                	mov    (%eax),%edx
801048a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a5:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048ad:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b3:	8b 48 18             	mov    0x18(%eax),%ecx
801048b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b9:	8b 40 18             	mov    0x18(%eax),%eax
801048bc:	89 c2                	mov    %eax,%edx
801048be:	89 cb                	mov    %ecx,%ebx
801048c0:	b8 13 00 00 00       	mov    $0x13,%eax
801048c5:	89 d7                	mov    %edx,%edi
801048c7:	89 de                	mov    %ebx,%esi
801048c9:	89 c1                	mov    %eax,%ecx
801048cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d0:	8b 40 18             	mov    0x18(%eax),%eax
801048d3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048e1:	eb 3b                	jmp    8010491e <fork+0x106>
    if(curproc->ofile[i])
801048e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048e9:	83 c2 08             	add    $0x8,%edx
801048ec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048f0:	85 c0                	test   %eax,%eax
801048f2:	74 26                	je     8010491a <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048fa:	83 c2 08             	add    $0x8,%edx
801048fd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104901:	83 ec 0c             	sub    $0xc,%esp
80104904:	50                   	push   %eax
80104905:	e8 3d c8 ff ff       	call   80101147 <filedup>
8010490a:	83 c4 10             	add    $0x10,%esp
8010490d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104910:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104913:	83 c1 08             	add    $0x8,%ecx
80104916:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010491a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010491e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104922:	7e bf                	jle    801048e3 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104924:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104927:	8b 40 68             	mov    0x68(%eax),%eax
8010492a:	83 ec 0c             	sub    $0xc,%esp
8010492d:	50                   	push   %eax
8010492e:	e8 ab d1 ff ff       	call   80101ade <idup>
80104933:	83 c4 10             	add    $0x10,%esp
80104936:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104939:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010493c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104942:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104945:	83 c0 6c             	add    $0x6c,%eax
80104948:	83 ec 04             	sub    $0x4,%esp
8010494b:	6a 10                	push   $0x10
8010494d:	52                   	push   %edx
8010494e:	50                   	push   %eax
8010494f:	e8 ad 0d 00 00       	call   80105701 <safestrcpy>
80104954:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104957:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010495a:	8b 40 10             	mov    0x10(%eax),%eax
8010495d:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	68 c0 4d 11 80       	push   $0x80114dc0
80104968:	e8 da 08 00 00       	call   80105247 <acquire>
8010496d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104970:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104973:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010497a:	83 ec 0c             	sub    $0xc,%esp
8010497d:	68 c0 4d 11 80       	push   $0x80114dc0
80104982:	e8 32 09 00 00       	call   801052b9 <release>
80104987:	83 c4 10             	add    $0x10,%esp

  return pid;
8010498a:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010498d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104990:	5b                   	pop    %ebx
80104991:	5e                   	pop    %esi
80104992:	5f                   	pop    %edi
80104993:	5d                   	pop    %ebp
80104994:	c3                   	ret    

80104995 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104995:	f3 0f 1e fb          	endbr32 
80104999:	55                   	push   %ebp
8010499a:	89 e5                	mov    %esp,%ebp
8010499c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010499f:	e8 06 fb ff ff       	call   801044aa <myproc>
801049a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049a7:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801049ac:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049af:	75 0d                	jne    801049be <exit+0x29>
    panic("init exiting");
801049b1:	83 ec 0c             	sub    $0xc,%esp
801049b4:	68 44 90 10 80       	push   $0x80109044
801049b9:	e8 4a bc ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049c5:	eb 3f                	jmp    80104a06 <exit+0x71>
    if(curproc->ofile[fd]){
801049c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049cd:	83 c2 08             	add    $0x8,%edx
801049d0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049d4:	85 c0                	test   %eax,%eax
801049d6:	74 2a                	je     80104a02 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801049d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049db:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049de:	83 c2 08             	add    $0x8,%edx
801049e1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049e5:	83 ec 0c             	sub    $0xc,%esp
801049e8:	50                   	push   %eax
801049e9:	e8 ae c7 ff ff       	call   8010119c <fileclose>
801049ee:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801049f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049f7:	83 c2 08             	add    $0x8,%edx
801049fa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a01:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a02:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a06:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a0a:	7e bb                	jle    801049c7 <exit+0x32>
    }
  }

  begin_op();
80104a0c:	e8 da ec ff ff       	call   801036eb <begin_op>
  iput(curproc->cwd);
80104a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a14:	8b 40 68             	mov    0x68(%eax),%eax
80104a17:	83 ec 0c             	sub    $0xc,%esp
80104a1a:	50                   	push   %eax
80104a1b:	e8 65 d2 ff ff       	call   80101c85 <iput>
80104a20:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a23:	e8 53 ed ff ff       	call   8010377b <end_op>
  curproc->cwd = 0;
80104a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a2b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	68 c0 4d 11 80       	push   $0x80114dc0
80104a3a:	e8 08 08 00 00       	call   80105247 <acquire>
80104a3f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a45:	8b 40 14             	mov    0x14(%eax),%eax
80104a48:	83 ec 0c             	sub    $0xc,%esp
80104a4b:	50                   	push   %eax
80104a4c:	e8 38 04 00 00       	call   80104e89 <wakeup1>
80104a51:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a54:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104a5b:	eb 37                	jmp    80104a94 <exit+0xff>
    if(p->parent == curproc){
80104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a60:	8b 40 14             	mov    0x14(%eax),%eax
80104a63:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a66:	75 28                	jne    80104a90 <exit+0xfb>
      p->parent = initproc;
80104a68:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a77:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7a:	83 f8 05             	cmp    $0x5,%eax
80104a7d:	75 11                	jne    80104a90 <exit+0xfb>
        wakeup1(initproc);
80104a7f:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a84:	83 ec 0c             	sub    $0xc,%esp
80104a87:	50                   	push   %eax
80104a88:	e8 fc 03 00 00       	call   80104e89 <wakeup1>
80104a8d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a90:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a94:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104a9b:	72 c0                	jb     80104a5d <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104a9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104aa7:	e8 ed 01 00 00       	call   80104c99 <sched>
  panic("zombie exit");
80104aac:	83 ec 0c             	sub    $0xc,%esp
80104aaf:	68 51 90 10 80       	push   $0x80109051
80104ab4:	e8 4f bb ff ff       	call   80100608 <panic>

80104ab9 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ab9:	f3 0f 1e fb          	endbr32 
80104abd:	55                   	push   %ebp
80104abe:	89 e5                	mov    %esp,%ebp
80104ac0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104ac3:	e8 e2 f9 ff ff       	call   801044aa <myproc>
80104ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	68 c0 4d 11 80       	push   $0x80114dc0
80104ad3:	e8 6f 07 00 00       	call   80105247 <acquire>
80104ad8:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104adb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ae2:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ae9:	e9 a1 00 00 00       	jmp    80104b8f <wait+0xd6>
      if(p->parent != curproc)
80104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af1:	8b 40 14             	mov    0x14(%eax),%eax
80104af4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104af7:	0f 85 8d 00 00 00    	jne    80104b8a <wait+0xd1>
        continue;
      havekids = 1;
80104afd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b07:	8b 40 0c             	mov    0xc(%eax),%eax
80104b0a:	83 f8 05             	cmp    $0x5,%eax
80104b0d:	75 7c                	jne    80104b8b <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b12:	8b 40 10             	mov    0x10(%eax),%eax
80104b15:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1b:	8b 40 08             	mov    0x8(%eax),%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 47 e2 ff ff       	call   80102d6e <kfree>
80104b27:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b37:	8b 40 04             	mov    0x4(%eax),%eax
80104b3a:	83 ec 0c             	sub    $0xc,%esp
80104b3d:	50                   	push   %eax
80104b3e:	e8 53 3a 00 00       	call   80108596 <freevm>
80104b43:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b49:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b53:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b64:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104b75:	83 ec 0c             	sub    $0xc,%esp
80104b78:	68 c0 4d 11 80       	push   $0x80114dc0
80104b7d:	e8 37 07 00 00       	call   801052b9 <release>
80104b82:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b88:	eb 51                	jmp    80104bdb <wait+0x122>
        continue;
80104b8a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b8b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b8f:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104b96:	0f 82 52 ff ff ff    	jb     80104aee <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ba0:	74 0a                	je     80104bac <wait+0xf3>
80104ba2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ba5:	8b 40 24             	mov    0x24(%eax),%eax
80104ba8:	85 c0                	test   %eax,%eax
80104baa:	74 17                	je     80104bc3 <wait+0x10a>
      release(&ptable.lock);
80104bac:	83 ec 0c             	sub    $0xc,%esp
80104baf:	68 c0 4d 11 80       	push   $0x80114dc0
80104bb4:	e8 00 07 00 00       	call   801052b9 <release>
80104bb9:	83 c4 10             	add    $0x10,%esp
      return -1;
80104bbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bc1:	eb 18                	jmp    80104bdb <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104bc3:	83 ec 08             	sub    $0x8,%esp
80104bc6:	68 c0 4d 11 80       	push   $0x80114dc0
80104bcb:	ff 75 ec             	pushl  -0x14(%ebp)
80104bce:	e8 0b 02 00 00       	call   80104dde <sleep>
80104bd3:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104bd6:	e9 00 ff ff ff       	jmp    80104adb <wait+0x22>
  }
}
80104bdb:	c9                   	leave  
80104bdc:	c3                   	ret    

80104bdd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bdd:	f3 0f 1e fb          	endbr32 
80104be1:	55                   	push   %ebp
80104be2:	89 e5                	mov    %esp,%ebp
80104be4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104be7:	e8 42 f8 ff ff       	call   8010442e <mycpu>
80104bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bf2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104bf9:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bfc:	e8 e5 f7 ff ff       	call   801043e6 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	68 c0 4d 11 80       	push   $0x80114dc0
80104c09:	e8 39 06 00 00       	call   80105247 <acquire>
80104c0e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c11:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c18:	eb 61                	jmp    80104c7b <scheduler+0x9e>
      if(p->state != RUNNABLE)
80104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c20:	83 f8 03             	cmp    $0x3,%eax
80104c23:	75 51                	jne    80104c76 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c28:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c2b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c31:	83 ec 0c             	sub    $0xc,%esp
80104c34:	ff 75 f4             	pushl  -0xc(%ebp)
80104c37:	e8 9f 34 00 00       	call   801080db <switchuvm>
80104c3c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c42:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c52:	83 c2 04             	add    $0x4,%edx
80104c55:	83 ec 08             	sub    $0x8,%esp
80104c58:	50                   	push   %eax
80104c59:	52                   	push   %edx
80104c5a:	e8 1b 0b 00 00       	call   8010577a <swtch>
80104c5f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c62:	e8 57 34 00 00       	call   801080be <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c6a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c71:	00 00 00 
80104c74:	eb 01                	jmp    80104c77 <scheduler+0x9a>
        continue;
80104c76:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c77:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c7b:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104c82:	72 96                	jb     80104c1a <scheduler+0x3d>
    }
    release(&ptable.lock);
80104c84:	83 ec 0c             	sub    $0xc,%esp
80104c87:	68 c0 4d 11 80       	push   $0x80114dc0
80104c8c:	e8 28 06 00 00       	call   801052b9 <release>
80104c91:	83 c4 10             	add    $0x10,%esp
    sti();
80104c94:	e9 63 ff ff ff       	jmp    80104bfc <scheduler+0x1f>

80104c99 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104c99:	f3 0f 1e fb          	endbr32 
80104c9d:	55                   	push   %ebp
80104c9e:	89 e5                	mov    %esp,%ebp
80104ca0:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104ca3:	e8 02 f8 ff ff       	call   801044aa <myproc>
80104ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104cab:	83 ec 0c             	sub    $0xc,%esp
80104cae:	68 c0 4d 11 80       	push   $0x80114dc0
80104cb3:	e8 d6 06 00 00       	call   8010538e <holding>
80104cb8:	83 c4 10             	add    $0x10,%esp
80104cbb:	85 c0                	test   %eax,%eax
80104cbd:	75 0d                	jne    80104ccc <sched+0x33>
    panic("sched ptable.lock");
80104cbf:	83 ec 0c             	sub    $0xc,%esp
80104cc2:	68 5d 90 10 80       	push   $0x8010905d
80104cc7:	e8 3c b9 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104ccc:	e8 5d f7 ff ff       	call   8010442e <mycpu>
80104cd1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cd7:	83 f8 01             	cmp    $0x1,%eax
80104cda:	74 0d                	je     80104ce9 <sched+0x50>
    panic("sched locks");
80104cdc:	83 ec 0c             	sub    $0xc,%esp
80104cdf:	68 6f 90 10 80       	push   $0x8010906f
80104ce4:	e8 1f b9 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	8b 40 0c             	mov    0xc(%eax),%eax
80104cef:	83 f8 04             	cmp    $0x4,%eax
80104cf2:	75 0d                	jne    80104d01 <sched+0x68>
    panic("sched running");
80104cf4:	83 ec 0c             	sub    $0xc,%esp
80104cf7:	68 7b 90 10 80       	push   $0x8010907b
80104cfc:	e8 07 b9 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d01:	e8 d0 f6 ff ff       	call   801043d6 <readeflags>
80104d06:	25 00 02 00 00       	and    $0x200,%eax
80104d0b:	85 c0                	test   %eax,%eax
80104d0d:	74 0d                	je     80104d1c <sched+0x83>
    panic("sched interruptible");
80104d0f:	83 ec 0c             	sub    $0xc,%esp
80104d12:	68 89 90 10 80       	push   $0x80109089
80104d17:	e8 ec b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d1c:	e8 0d f7 ff ff       	call   8010442e <mycpu>
80104d21:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d2a:	e8 ff f6 ff ff       	call   8010442e <mycpu>
80104d2f:	8b 40 04             	mov    0x4(%eax),%eax
80104d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d35:	83 c2 1c             	add    $0x1c,%edx
80104d38:	83 ec 08             	sub    $0x8,%esp
80104d3b:	50                   	push   %eax
80104d3c:	52                   	push   %edx
80104d3d:	e8 38 0a 00 00       	call   8010577a <swtch>
80104d42:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104d45:	e8 e4 f6 ff ff       	call   8010442e <mycpu>
80104d4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d4d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d53:	90                   	nop
80104d54:	c9                   	leave  
80104d55:	c3                   	ret    

80104d56 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d56:	f3 0f 1e fb          	endbr32 
80104d5a:	55                   	push   %ebp
80104d5b:	89 e5                	mov    %esp,%ebp
80104d5d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d60:	83 ec 0c             	sub    $0xc,%esp
80104d63:	68 c0 4d 11 80       	push   $0x80114dc0
80104d68:	e8 da 04 00 00       	call   80105247 <acquire>
80104d6d:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104d70:	e8 35 f7 ff ff       	call   801044aa <myproc>
80104d75:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d7c:	e8 18 ff ff ff       	call   80104c99 <sched>
  release(&ptable.lock);
80104d81:	83 ec 0c             	sub    $0xc,%esp
80104d84:	68 c0 4d 11 80       	push   $0x80114dc0
80104d89:	e8 2b 05 00 00       	call   801052b9 <release>
80104d8e:	83 c4 10             	add    $0x10,%esp
}
80104d91:	90                   	nop
80104d92:	c9                   	leave  
80104d93:	c3                   	ret    

80104d94 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d94:	f3 0f 1e fb          	endbr32 
80104d98:	55                   	push   %ebp
80104d99:	89 e5                	mov    %esp,%ebp
80104d9b:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d9e:	83 ec 0c             	sub    $0xc,%esp
80104da1:	68 c0 4d 11 80       	push   $0x80114dc0
80104da6:	e8 0e 05 00 00       	call   801052b9 <release>
80104dab:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104dae:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104db3:	85 c0                	test   %eax,%eax
80104db5:	74 24                	je     80104ddb <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104db7:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104dbe:	00 00 00 
    iinit(ROOTDEV);
80104dc1:	83 ec 0c             	sub    $0xc,%esp
80104dc4:	6a 01                	push   $0x1
80104dc6:	e8 cb c9 ff ff       	call   80101796 <iinit>
80104dcb:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104dce:	83 ec 0c             	sub    $0xc,%esp
80104dd1:	6a 01                	push   $0x1
80104dd3:	e8 e0 e6 ff ff       	call   801034b8 <initlog>
80104dd8:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104ddb:	90                   	nop
80104ddc:	c9                   	leave  
80104ddd:	c3                   	ret    

80104dde <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104dde:	f3 0f 1e fb          	endbr32 
80104de2:	55                   	push   %ebp
80104de3:	89 e5                	mov    %esp,%ebp
80104de5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104de8:	e8 bd f6 ff ff       	call   801044aa <myproc>
80104ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104df0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104df4:	75 0d                	jne    80104e03 <sleep+0x25>
    panic("sleep");
80104df6:	83 ec 0c             	sub    $0xc,%esp
80104df9:	68 9d 90 10 80       	push   $0x8010909d
80104dfe:	e8 05 b8 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e07:	75 0d                	jne    80104e16 <sleep+0x38>
    panic("sleep without lk");
80104e09:	83 ec 0c             	sub    $0xc,%esp
80104e0c:	68 a3 90 10 80       	push   $0x801090a3
80104e11:	e8 f2 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e16:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e1d:	74 1e                	je     80104e3d <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e1f:	83 ec 0c             	sub    $0xc,%esp
80104e22:	68 c0 4d 11 80       	push   $0x80114dc0
80104e27:	e8 1b 04 00 00       	call   80105247 <acquire>
80104e2c:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e2f:	83 ec 0c             	sub    $0xc,%esp
80104e32:	ff 75 0c             	pushl  0xc(%ebp)
80104e35:	e8 7f 04 00 00       	call   801052b9 <release>
80104e3a:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e40:	8b 55 08             	mov    0x8(%ebp),%edx
80104e43:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e49:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104e50:	e8 44 fe ff ff       	call   80104c99 <sched>

  // Tidy up.
  p->chan = 0;
80104e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e58:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e5f:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e66:	74 1e                	je     80104e86 <sleep+0xa8>
    release(&ptable.lock);
80104e68:	83 ec 0c             	sub    $0xc,%esp
80104e6b:	68 c0 4d 11 80       	push   $0x80114dc0
80104e70:	e8 44 04 00 00       	call   801052b9 <release>
80104e75:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e78:	83 ec 0c             	sub    $0xc,%esp
80104e7b:	ff 75 0c             	pushl  0xc(%ebp)
80104e7e:	e8 c4 03 00 00       	call   80105247 <acquire>
80104e83:	83 c4 10             	add    $0x10,%esp
  }
}
80104e86:	90                   	nop
80104e87:	c9                   	leave  
80104e88:	c3                   	ret    

80104e89 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e89:	f3 0f 1e fb          	endbr32 
80104e8d:	55                   	push   %ebp
80104e8e:	89 e5                	mov    %esp,%ebp
80104e90:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e93:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104e9a:	eb 24                	jmp    80104ec0 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9f:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea2:	83 f8 02             	cmp    $0x2,%eax
80104ea5:	75 15                	jne    80104ebc <wakeup1+0x33>
80104ea7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eaa:	8b 40 20             	mov    0x20(%eax),%eax
80104ead:	39 45 08             	cmp    %eax,0x8(%ebp)
80104eb0:	75 0a                	jne    80104ebc <wakeup1+0x33>
      p->state = RUNNABLE;
80104eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ebc:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104ec0:	81 7d fc f4 6c 11 80 	cmpl   $0x80116cf4,-0x4(%ebp)
80104ec7:	72 d3                	jb     80104e9c <wakeup1+0x13>
}
80104ec9:	90                   	nop
80104eca:	90                   	nop
80104ecb:	c9                   	leave  
80104ecc:	c3                   	ret    

80104ecd <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ecd:	f3 0f 1e fb          	endbr32 
80104ed1:	55                   	push   %ebp
80104ed2:	89 e5                	mov    %esp,%ebp
80104ed4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ed7:	83 ec 0c             	sub    $0xc,%esp
80104eda:	68 c0 4d 11 80       	push   $0x80114dc0
80104edf:	e8 63 03 00 00       	call   80105247 <acquire>
80104ee4:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	ff 75 08             	pushl  0x8(%ebp)
80104eed:	e8 97 ff ff ff       	call   80104e89 <wakeup1>
80104ef2:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104ef5:	83 ec 0c             	sub    $0xc,%esp
80104ef8:	68 c0 4d 11 80       	push   $0x80114dc0
80104efd:	e8 b7 03 00 00       	call   801052b9 <release>
80104f02:	83 c4 10             	add    $0x10,%esp
}
80104f05:	90                   	nop
80104f06:	c9                   	leave  
80104f07:	c3                   	ret    

80104f08 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f08:	f3 0f 1e fb          	endbr32 
80104f0c:	55                   	push   %ebp
80104f0d:	89 e5                	mov    %esp,%ebp
80104f0f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f12:	83 ec 0c             	sub    $0xc,%esp
80104f15:	68 c0 4d 11 80       	push   $0x80114dc0
80104f1a:	e8 28 03 00 00       	call   80105247 <acquire>
80104f1f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f22:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f29:	eb 45                	jmp    80104f70 <kill+0x68>
    if(p->pid == pid){
80104f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2e:	8b 40 10             	mov    0x10(%eax),%eax
80104f31:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f34:	75 36                	jne    80104f6c <kill+0x64>
      p->killed = 1;
80104f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f39:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f43:	8b 40 0c             	mov    0xc(%eax),%eax
80104f46:	83 f8 02             	cmp    $0x2,%eax
80104f49:	75 0a                	jne    80104f55 <kill+0x4d>
        p->state = RUNNABLE;
80104f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	68 c0 4d 11 80       	push   $0x80114dc0
80104f5d:	e8 57 03 00 00       	call   801052b9 <release>
80104f62:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f65:	b8 00 00 00 00       	mov    $0x0,%eax
80104f6a:	eb 22                	jmp    80104f8e <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f6c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f70:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104f77:	72 b2                	jb     80104f2b <kill+0x23>
    }
  }
  release(&ptable.lock);
80104f79:	83 ec 0c             	sub    $0xc,%esp
80104f7c:	68 c0 4d 11 80       	push   $0x80114dc0
80104f81:	e8 33 03 00 00       	call   801052b9 <release>
80104f86:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f8e:	c9                   	leave  
80104f8f:	c3                   	ret    

80104f90 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f90:	f3 0f 1e fb          	endbr32 
80104f94:	55                   	push   %ebp
80104f95:	89 e5                	mov    %esp,%ebp
80104f97:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f9a:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80104fa1:	e9 d7 00 00 00       	jmp    8010507d <procdump+0xed>
    if(p->state == UNUSED)
80104fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fac:	85 c0                	test   %eax,%eax
80104fae:	0f 84 c4 00 00 00    	je     80105078 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb7:	8b 40 0c             	mov    0xc(%eax),%eax
80104fba:	83 f8 05             	cmp    $0x5,%eax
80104fbd:	77 23                	ja     80104fe2 <procdump+0x52>
80104fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc2:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc5:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	74 12                	je     80104fe2 <procdump+0x52>
      state = states[p->state];
80104fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd3:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd6:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fe0:	eb 07                	jmp    80104fe9 <procdump+0x59>
    else
      state = "???";
80104fe2:	c7 45 ec b4 90 10 80 	movl   $0x801090b4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fec:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff2:	8b 40 10             	mov    0x10(%eax),%eax
80104ff5:	52                   	push   %edx
80104ff6:	ff 75 ec             	pushl  -0x14(%ebp)
80104ff9:	50                   	push   %eax
80104ffa:	68 b8 90 10 80       	push   $0x801090b8
80104fff:	e8 14 b4 ff ff       	call   80100418 <cprintf>
80105004:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500a:	8b 40 0c             	mov    0xc(%eax),%eax
8010500d:	83 f8 02             	cmp    $0x2,%eax
80105010:	75 54                	jne    80105066 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105015:	8b 40 1c             	mov    0x1c(%eax),%eax
80105018:	8b 40 0c             	mov    0xc(%eax),%eax
8010501b:	83 c0 08             	add    $0x8,%eax
8010501e:	89 c2                	mov    %eax,%edx
80105020:	83 ec 08             	sub    $0x8,%esp
80105023:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105026:	50                   	push   %eax
80105027:	52                   	push   %edx
80105028:	e8 e2 02 00 00       	call   8010530f <getcallerpcs>
8010502d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105030:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105037:	eb 1c                	jmp    80105055 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80105039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105040:	83 ec 08             	sub    $0x8,%esp
80105043:	50                   	push   %eax
80105044:	68 c1 90 10 80       	push   $0x801090c1
80105049:	e8 ca b3 ff ff       	call   80100418 <cprintf>
8010504e:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105051:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105055:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105059:	7f 0b                	jg     80105066 <procdump+0xd6>
8010505b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105062:	85 c0                	test   %eax,%eax
80105064:	75 d3                	jne    80105039 <procdump+0xa9>
    }
    cprintf("\n");
80105066:	83 ec 0c             	sub    $0xc,%esp
80105069:	68 c5 90 10 80       	push   $0x801090c5
8010506e:	e8 a5 b3 ff ff       	call   80100418 <cprintf>
80105073:	83 c4 10             	add    $0x10,%esp
80105076:	eb 01                	jmp    80105079 <procdump+0xe9>
      continue;
80105078:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105079:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010507d:	81 7d f0 f4 6c 11 80 	cmpl   $0x80116cf4,-0x10(%ebp)
80105084:	0f 82 1c ff ff ff    	jb     80104fa6 <procdump+0x16>
  }
}
8010508a:	90                   	nop
8010508b:	90                   	nop
8010508c:	c9                   	leave  
8010508d:	c3                   	ret    

8010508e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010508e:	f3 0f 1e fb          	endbr32 
80105092:	55                   	push   %ebp
80105093:	89 e5                	mov    %esp,%ebp
80105095:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105098:	8b 45 08             	mov    0x8(%ebp),%eax
8010509b:	83 c0 04             	add    $0x4,%eax
8010509e:	83 ec 08             	sub    $0x8,%esp
801050a1:	68 f1 90 10 80       	push   $0x801090f1
801050a6:	50                   	push   %eax
801050a7:	e8 75 01 00 00       	call   80105221 <initlock>
801050ac:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801050af:	8b 45 08             	mov    0x8(%ebp),%eax
801050b2:	8b 55 0c             	mov    0xc(%ebp),%edx
801050b5:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801050b8:	8b 45 08             	mov    0x8(%ebp),%eax
801050bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050c1:	8b 45 08             	mov    0x8(%ebp),%eax
801050c4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801050cb:	90                   	nop
801050cc:	c9                   	leave  
801050cd:	c3                   	ret    

801050ce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801050ce:	f3 0f 1e fb          	endbr32 
801050d2:	55                   	push   %ebp
801050d3:	89 e5                	mov    %esp,%ebp
801050d5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801050d8:	8b 45 08             	mov    0x8(%ebp),%eax
801050db:	83 c0 04             	add    $0x4,%eax
801050de:	83 ec 0c             	sub    $0xc,%esp
801050e1:	50                   	push   %eax
801050e2:	e8 60 01 00 00       	call   80105247 <acquire>
801050e7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050ea:	eb 15                	jmp    80105101 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801050ec:	8b 45 08             	mov    0x8(%ebp),%eax
801050ef:	83 c0 04             	add    $0x4,%eax
801050f2:	83 ec 08             	sub    $0x8,%esp
801050f5:	50                   	push   %eax
801050f6:	ff 75 08             	pushl  0x8(%ebp)
801050f9:	e8 e0 fc ff ff       	call   80104dde <sleep>
801050fe:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105101:	8b 45 08             	mov    0x8(%ebp),%eax
80105104:	8b 00                	mov    (%eax),%eax
80105106:	85 c0                	test   %eax,%eax
80105108:	75 e2                	jne    801050ec <acquiresleep+0x1e>
  }
  lk->locked = 1;
8010510a:	8b 45 08             	mov    0x8(%ebp),%eax
8010510d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105113:	e8 92 f3 ff ff       	call   801044aa <myproc>
80105118:	8b 50 10             	mov    0x10(%eax),%edx
8010511b:	8b 45 08             	mov    0x8(%ebp),%eax
8010511e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105121:	8b 45 08             	mov    0x8(%ebp),%eax
80105124:	83 c0 04             	add    $0x4,%eax
80105127:	83 ec 0c             	sub    $0xc,%esp
8010512a:	50                   	push   %eax
8010512b:	e8 89 01 00 00       	call   801052b9 <release>
80105130:	83 c4 10             	add    $0x10,%esp
}
80105133:	90                   	nop
80105134:	c9                   	leave  
80105135:	c3                   	ret    

80105136 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105136:	f3 0f 1e fb          	endbr32 
8010513a:	55                   	push   %ebp
8010513b:	89 e5                	mov    %esp,%ebp
8010513d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105140:	8b 45 08             	mov    0x8(%ebp),%eax
80105143:	83 c0 04             	add    $0x4,%eax
80105146:	83 ec 0c             	sub    $0xc,%esp
80105149:	50                   	push   %eax
8010514a:	e8 f8 00 00 00       	call   80105247 <acquire>
8010514f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010515b:	8b 45 08             	mov    0x8(%ebp),%eax
8010515e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105165:	83 ec 0c             	sub    $0xc,%esp
80105168:	ff 75 08             	pushl  0x8(%ebp)
8010516b:	e8 5d fd ff ff       	call   80104ecd <wakeup>
80105170:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105173:	8b 45 08             	mov    0x8(%ebp),%eax
80105176:	83 c0 04             	add    $0x4,%eax
80105179:	83 ec 0c             	sub    $0xc,%esp
8010517c:	50                   	push   %eax
8010517d:	e8 37 01 00 00       	call   801052b9 <release>
80105182:	83 c4 10             	add    $0x10,%esp
}
80105185:	90                   	nop
80105186:	c9                   	leave  
80105187:	c3                   	ret    

80105188 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105188:	f3 0f 1e fb          	endbr32 
8010518c:	55                   	push   %ebp
8010518d:	89 e5                	mov    %esp,%ebp
8010518f:	53                   	push   %ebx
80105190:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	83 c0 04             	add    $0x4,%eax
80105199:	83 ec 0c             	sub    $0xc,%esp
8010519c:	50                   	push   %eax
8010519d:	e8 a5 00 00 00       	call   80105247 <acquire>
801051a2:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801051a5:	8b 45 08             	mov    0x8(%ebp),%eax
801051a8:	8b 00                	mov    (%eax),%eax
801051aa:	85 c0                	test   %eax,%eax
801051ac:	74 19                	je     801051c7 <holdingsleep+0x3f>
801051ae:	8b 45 08             	mov    0x8(%ebp),%eax
801051b1:	8b 58 3c             	mov    0x3c(%eax),%ebx
801051b4:	e8 f1 f2 ff ff       	call   801044aa <myproc>
801051b9:	8b 40 10             	mov    0x10(%eax),%eax
801051bc:	39 c3                	cmp    %eax,%ebx
801051be:	75 07                	jne    801051c7 <holdingsleep+0x3f>
801051c0:	b8 01 00 00 00       	mov    $0x1,%eax
801051c5:	eb 05                	jmp    801051cc <holdingsleep+0x44>
801051c7:	b8 00 00 00 00       	mov    $0x0,%eax
801051cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801051cf:	8b 45 08             	mov    0x8(%ebp),%eax
801051d2:	83 c0 04             	add    $0x4,%eax
801051d5:	83 ec 0c             	sub    $0xc,%esp
801051d8:	50                   	push   %eax
801051d9:	e8 db 00 00 00       	call   801052b9 <release>
801051de:	83 c4 10             	add    $0x10,%esp
  return r;
801051e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801051e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051e7:	c9                   	leave  
801051e8:	c3                   	ret    

801051e9 <readeflags>:
{
801051e9:	55                   	push   %ebp
801051ea:	89 e5                	mov    %esp,%ebp
801051ec:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801051ef:	9c                   	pushf  
801051f0:	58                   	pop    %eax
801051f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801051f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051f7:	c9                   	leave  
801051f8:	c3                   	ret    

801051f9 <cli>:
{
801051f9:	55                   	push   %ebp
801051fa:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801051fc:	fa                   	cli    
}
801051fd:	90                   	nop
801051fe:	5d                   	pop    %ebp
801051ff:	c3                   	ret    

80105200 <sti>:
{
80105200:	55                   	push   %ebp
80105201:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105203:	fb                   	sti    
}
80105204:	90                   	nop
80105205:	5d                   	pop    %ebp
80105206:	c3                   	ret    

80105207 <xchg>:
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
8010520a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010520d:	8b 55 08             	mov    0x8(%ebp),%edx
80105210:	8b 45 0c             	mov    0xc(%ebp),%eax
80105213:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105216:	f0 87 02             	lock xchg %eax,(%edx)
80105219:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010521c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010521f:	c9                   	leave  
80105220:	c3                   	ret    

80105221 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105221:	f3 0f 1e fb          	endbr32 
80105225:	55                   	push   %ebp
80105226:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105228:	8b 45 08             	mov    0x8(%ebp),%eax
8010522b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010522e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105231:	8b 45 08             	mov    0x8(%ebp),%eax
80105234:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010523a:	8b 45 08             	mov    0x8(%ebp),%eax
8010523d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105244:	90                   	nop
80105245:	5d                   	pop    %ebp
80105246:	c3                   	ret    

80105247 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105247:	f3 0f 1e fb          	endbr32 
8010524b:	55                   	push   %ebp
8010524c:	89 e5                	mov    %esp,%ebp
8010524e:	53                   	push   %ebx
8010524f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105252:	e8 7c 01 00 00       	call   801053d3 <pushcli>
  if(holding(lk))
80105257:	8b 45 08             	mov    0x8(%ebp),%eax
8010525a:	83 ec 0c             	sub    $0xc,%esp
8010525d:	50                   	push   %eax
8010525e:	e8 2b 01 00 00       	call   8010538e <holding>
80105263:	83 c4 10             	add    $0x10,%esp
80105266:	85 c0                	test   %eax,%eax
80105268:	74 0d                	je     80105277 <acquire+0x30>
    panic("acquire");
8010526a:	83 ec 0c             	sub    $0xc,%esp
8010526d:	68 fc 90 10 80       	push   $0x801090fc
80105272:	e8 91 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105277:	90                   	nop
80105278:	8b 45 08             	mov    0x8(%ebp),%eax
8010527b:	83 ec 08             	sub    $0x8,%esp
8010527e:	6a 01                	push   $0x1
80105280:	50                   	push   %eax
80105281:	e8 81 ff ff ff       	call   80105207 <xchg>
80105286:	83 c4 10             	add    $0x10,%esp
80105289:	85 c0                	test   %eax,%eax
8010528b:	75 eb                	jne    80105278 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010528d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105292:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105295:	e8 94 f1 ff ff       	call   8010442e <mycpu>
8010529a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010529d:	8b 45 08             	mov    0x8(%ebp),%eax
801052a0:	83 c0 0c             	add    $0xc,%eax
801052a3:	83 ec 08             	sub    $0x8,%esp
801052a6:	50                   	push   %eax
801052a7:	8d 45 08             	lea    0x8(%ebp),%eax
801052aa:	50                   	push   %eax
801052ab:	e8 5f 00 00 00       	call   8010530f <getcallerpcs>
801052b0:	83 c4 10             	add    $0x10,%esp
}
801052b3:	90                   	nop
801052b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052b7:	c9                   	leave  
801052b8:	c3                   	ret    

801052b9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801052b9:	f3 0f 1e fb          	endbr32 
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801052c3:	83 ec 0c             	sub    $0xc,%esp
801052c6:	ff 75 08             	pushl  0x8(%ebp)
801052c9:	e8 c0 00 00 00       	call   8010538e <holding>
801052ce:	83 c4 10             	add    $0x10,%esp
801052d1:	85 c0                	test   %eax,%eax
801052d3:	75 0d                	jne    801052e2 <release+0x29>
    panic("release");
801052d5:	83 ec 0c             	sub    $0xc,%esp
801052d8:	68 04 91 10 80       	push   $0x80109104
801052dd:	e8 26 b3 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801052ec:	8b 45 08             	mov    0x8(%ebp),%eax
801052ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801052f6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801052fb:	8b 45 08             	mov    0x8(%ebp),%eax
801052fe:	8b 55 08             	mov    0x8(%ebp),%edx
80105301:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105307:	e8 18 01 00 00       	call   80105424 <popcli>
}
8010530c:	90                   	nop
8010530d:	c9                   	leave  
8010530e:	c3                   	ret    

8010530f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010530f:	f3 0f 1e fb          	endbr32 
80105313:	55                   	push   %ebp
80105314:	89 e5                	mov    %esp,%ebp
80105316:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	83 e8 08             	sub    $0x8,%eax
8010531f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105322:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105329:	eb 38                	jmp    80105363 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010532b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010532f:	74 53                	je     80105384 <getcallerpcs+0x75>
80105331:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105338:	76 4a                	jbe    80105384 <getcallerpcs+0x75>
8010533a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010533e:	74 44                	je     80105384 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105340:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105343:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010534a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534d:	01 c2                	add    %eax,%edx
8010534f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105352:	8b 40 04             	mov    0x4(%eax),%eax
80105355:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010535a:	8b 00                	mov    (%eax),%eax
8010535c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010535f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105363:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105367:	7e c2                	jle    8010532b <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105369:	eb 19                	jmp    80105384 <getcallerpcs+0x75>
    pcs[i] = 0;
8010536b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010536e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105375:	8b 45 0c             	mov    0xc(%ebp),%eax
80105378:	01 d0                	add    %edx,%eax
8010537a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105380:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105384:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105388:	7e e1                	jle    8010536b <getcallerpcs+0x5c>
}
8010538a:	90                   	nop
8010538b:	90                   	nop
8010538c:	c9                   	leave  
8010538d:	c3                   	ret    

8010538e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010538e:	f3 0f 1e fb          	endbr32 
80105392:	55                   	push   %ebp
80105393:	89 e5                	mov    %esp,%ebp
80105395:	53                   	push   %ebx
80105396:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105399:	e8 35 00 00 00       	call   801053d3 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010539e:	8b 45 08             	mov    0x8(%ebp),%eax
801053a1:	8b 00                	mov    (%eax),%eax
801053a3:	85 c0                	test   %eax,%eax
801053a5:	74 16                	je     801053bd <holding+0x2f>
801053a7:	8b 45 08             	mov    0x8(%ebp),%eax
801053aa:	8b 58 08             	mov    0x8(%eax),%ebx
801053ad:	e8 7c f0 ff ff       	call   8010442e <mycpu>
801053b2:	39 c3                	cmp    %eax,%ebx
801053b4:	75 07                	jne    801053bd <holding+0x2f>
801053b6:	b8 01 00 00 00       	mov    $0x1,%eax
801053bb:	eb 05                	jmp    801053c2 <holding+0x34>
801053bd:	b8 00 00 00 00       	mov    $0x0,%eax
801053c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801053c5:	e8 5a 00 00 00       	call   80105424 <popcli>
  return r;
801053ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053cd:	83 c4 14             	add    $0x14,%esp
801053d0:	5b                   	pop    %ebx
801053d1:	5d                   	pop    %ebp
801053d2:	c3                   	ret    

801053d3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801053d3:	f3 0f 1e fb          	endbr32 
801053d7:	55                   	push   %ebp
801053d8:	89 e5                	mov    %esp,%ebp
801053da:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801053dd:	e8 07 fe ff ff       	call   801051e9 <readeflags>
801053e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801053e5:	e8 0f fe ff ff       	call   801051f9 <cli>
  if(mycpu()->ncli == 0)
801053ea:	e8 3f f0 ff ff       	call   8010442e <mycpu>
801053ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053f5:	85 c0                	test   %eax,%eax
801053f7:	75 14                	jne    8010540d <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801053f9:	e8 30 f0 ff ff       	call   8010442e <mycpu>
801053fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105401:	81 e2 00 02 00 00    	and    $0x200,%edx
80105407:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010540d:	e8 1c f0 ff ff       	call   8010442e <mycpu>
80105412:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105418:	83 c2 01             	add    $0x1,%edx
8010541b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105421:	90                   	nop
80105422:	c9                   	leave  
80105423:	c3                   	ret    

80105424 <popcli>:

void
popcli(void)
{
80105424:	f3 0f 1e fb          	endbr32 
80105428:	55                   	push   %ebp
80105429:	89 e5                	mov    %esp,%ebp
8010542b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010542e:	e8 b6 fd ff ff       	call   801051e9 <readeflags>
80105433:	25 00 02 00 00       	and    $0x200,%eax
80105438:	85 c0                	test   %eax,%eax
8010543a:	74 0d                	je     80105449 <popcli+0x25>
    panic("popcli - interruptible");
8010543c:	83 ec 0c             	sub    $0xc,%esp
8010543f:	68 0c 91 10 80       	push   $0x8010910c
80105444:	e8 bf b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
80105449:	e8 e0 ef ff ff       	call   8010442e <mycpu>
8010544e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105454:	83 ea 01             	sub    $0x1,%edx
80105457:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010545d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105463:	85 c0                	test   %eax,%eax
80105465:	79 0d                	jns    80105474 <popcli+0x50>
    panic("popcli");
80105467:	83 ec 0c             	sub    $0xc,%esp
8010546a:	68 23 91 10 80       	push   $0x80109123
8010546f:	e8 94 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105474:	e8 b5 ef ff ff       	call   8010442e <mycpu>
80105479:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010547f:	85 c0                	test   %eax,%eax
80105481:	75 14                	jne    80105497 <popcli+0x73>
80105483:	e8 a6 ef ff ff       	call   8010442e <mycpu>
80105488:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010548e:	85 c0                	test   %eax,%eax
80105490:	74 05                	je     80105497 <popcli+0x73>
    sti();
80105492:	e8 69 fd ff ff       	call   80105200 <sti>
}
80105497:	90                   	nop
80105498:	c9                   	leave  
80105499:	c3                   	ret    

8010549a <stosb>:
{
8010549a:	55                   	push   %ebp
8010549b:	89 e5                	mov    %esp,%ebp
8010549d:	57                   	push   %edi
8010549e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010549f:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054a2:	8b 55 10             	mov    0x10(%ebp),%edx
801054a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a8:	89 cb                	mov    %ecx,%ebx
801054aa:	89 df                	mov    %ebx,%edi
801054ac:	89 d1                	mov    %edx,%ecx
801054ae:	fc                   	cld    
801054af:	f3 aa                	rep stos %al,%es:(%edi)
801054b1:	89 ca                	mov    %ecx,%edx
801054b3:	89 fb                	mov    %edi,%ebx
801054b5:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054b8:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054bb:	90                   	nop
801054bc:	5b                   	pop    %ebx
801054bd:	5f                   	pop    %edi
801054be:	5d                   	pop    %ebp
801054bf:	c3                   	ret    

801054c0 <stosl>:
{
801054c0:	55                   	push   %ebp
801054c1:	89 e5                	mov    %esp,%ebp
801054c3:	57                   	push   %edi
801054c4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054c8:	8b 55 10             	mov    0x10(%ebp),%edx
801054cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ce:	89 cb                	mov    %ecx,%ebx
801054d0:	89 df                	mov    %ebx,%edi
801054d2:	89 d1                	mov    %edx,%ecx
801054d4:	fc                   	cld    
801054d5:	f3 ab                	rep stos %eax,%es:(%edi)
801054d7:	89 ca                	mov    %ecx,%edx
801054d9:	89 fb                	mov    %edi,%ebx
801054db:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054de:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054e1:	90                   	nop
801054e2:	5b                   	pop    %ebx
801054e3:	5f                   	pop    %edi
801054e4:	5d                   	pop    %ebp
801054e5:	c3                   	ret    

801054e6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054e6:	f3 0f 1e fb          	endbr32 
801054ea:	55                   	push   %ebp
801054eb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801054ed:	8b 45 08             	mov    0x8(%ebp),%eax
801054f0:	83 e0 03             	and    $0x3,%eax
801054f3:	85 c0                	test   %eax,%eax
801054f5:	75 43                	jne    8010553a <memset+0x54>
801054f7:	8b 45 10             	mov    0x10(%ebp),%eax
801054fa:	83 e0 03             	and    $0x3,%eax
801054fd:	85 c0                	test   %eax,%eax
801054ff:	75 39                	jne    8010553a <memset+0x54>
    c &= 0xFF;
80105501:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105508:	8b 45 10             	mov    0x10(%ebp),%eax
8010550b:	c1 e8 02             	shr    $0x2,%eax
8010550e:	89 c1                	mov    %eax,%ecx
80105510:	8b 45 0c             	mov    0xc(%ebp),%eax
80105513:	c1 e0 18             	shl    $0x18,%eax
80105516:	89 c2                	mov    %eax,%edx
80105518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551b:	c1 e0 10             	shl    $0x10,%eax
8010551e:	09 c2                	or     %eax,%edx
80105520:	8b 45 0c             	mov    0xc(%ebp),%eax
80105523:	c1 e0 08             	shl    $0x8,%eax
80105526:	09 d0                	or     %edx,%eax
80105528:	0b 45 0c             	or     0xc(%ebp),%eax
8010552b:	51                   	push   %ecx
8010552c:	50                   	push   %eax
8010552d:	ff 75 08             	pushl  0x8(%ebp)
80105530:	e8 8b ff ff ff       	call   801054c0 <stosl>
80105535:	83 c4 0c             	add    $0xc,%esp
80105538:	eb 12                	jmp    8010554c <memset+0x66>
  } else
    stosb(dst, c, n);
8010553a:	8b 45 10             	mov    0x10(%ebp),%eax
8010553d:	50                   	push   %eax
8010553e:	ff 75 0c             	pushl  0xc(%ebp)
80105541:	ff 75 08             	pushl  0x8(%ebp)
80105544:	e8 51 ff ff ff       	call   8010549a <stosb>
80105549:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010554c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010554f:	c9                   	leave  
80105550:	c3                   	ret    

80105551 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105551:	f3 0f 1e fb          	endbr32 
80105555:	55                   	push   %ebp
80105556:	89 e5                	mov    %esp,%ebp
80105558:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010555b:	8b 45 08             	mov    0x8(%ebp),%eax
8010555e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105561:	8b 45 0c             	mov    0xc(%ebp),%eax
80105564:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105567:	eb 30                	jmp    80105599 <memcmp+0x48>
    if(*s1 != *s2)
80105569:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556c:	0f b6 10             	movzbl (%eax),%edx
8010556f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105572:	0f b6 00             	movzbl (%eax),%eax
80105575:	38 c2                	cmp    %al,%dl
80105577:	74 18                	je     80105591 <memcmp+0x40>
      return *s1 - *s2;
80105579:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010557c:	0f b6 00             	movzbl (%eax),%eax
8010557f:	0f b6 d0             	movzbl %al,%edx
80105582:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105585:	0f b6 00             	movzbl (%eax),%eax
80105588:	0f b6 c0             	movzbl %al,%eax
8010558b:	29 c2                	sub    %eax,%edx
8010558d:	89 d0                	mov    %edx,%eax
8010558f:	eb 1a                	jmp    801055ab <memcmp+0x5a>
    s1++, s2++;
80105591:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105595:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105599:	8b 45 10             	mov    0x10(%ebp),%eax
8010559c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010559f:	89 55 10             	mov    %edx,0x10(%ebp)
801055a2:	85 c0                	test   %eax,%eax
801055a4:	75 c3                	jne    80105569 <memcmp+0x18>
  }

  return 0;
801055a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ab:	c9                   	leave  
801055ac:	c3                   	ret    

801055ad <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055ad:	f3 0f 1e fb          	endbr32 
801055b1:	55                   	push   %ebp
801055b2:	89 e5                	mov    %esp,%ebp
801055b4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055bd:	8b 45 08             	mov    0x8(%ebp),%eax
801055c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055c9:	73 54                	jae    8010561f <memmove+0x72>
801055cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055ce:	8b 45 10             	mov    0x10(%ebp),%eax
801055d1:	01 d0                	add    %edx,%eax
801055d3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801055d6:	73 47                	jae    8010561f <memmove+0x72>
    s += n;
801055d8:	8b 45 10             	mov    0x10(%ebp),%eax
801055db:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801055de:	8b 45 10             	mov    0x10(%ebp),%eax
801055e1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801055e4:	eb 13                	jmp    801055f9 <memmove+0x4c>
      *--d = *--s;
801055e6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801055ea:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801055ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f1:	0f b6 10             	movzbl (%eax),%edx
801055f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055f7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801055f9:	8b 45 10             	mov    0x10(%ebp),%eax
801055fc:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ff:	89 55 10             	mov    %edx,0x10(%ebp)
80105602:	85 c0                	test   %eax,%eax
80105604:	75 e0                	jne    801055e6 <memmove+0x39>
  if(s < d && s + n > d){
80105606:	eb 24                	jmp    8010562c <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105608:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010560b:	8d 42 01             	lea    0x1(%edx),%eax
8010560e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105611:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105614:	8d 48 01             	lea    0x1(%eax),%ecx
80105617:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010561a:	0f b6 12             	movzbl (%edx),%edx
8010561d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010561f:	8b 45 10             	mov    0x10(%ebp),%eax
80105622:	8d 50 ff             	lea    -0x1(%eax),%edx
80105625:	89 55 10             	mov    %edx,0x10(%ebp)
80105628:	85 c0                	test   %eax,%eax
8010562a:	75 dc                	jne    80105608 <memmove+0x5b>

  return dst;
8010562c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010562f:	c9                   	leave  
80105630:	c3                   	ret    

80105631 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105631:	f3 0f 1e fb          	endbr32 
80105635:	55                   	push   %ebp
80105636:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105638:	ff 75 10             	pushl  0x10(%ebp)
8010563b:	ff 75 0c             	pushl  0xc(%ebp)
8010563e:	ff 75 08             	pushl  0x8(%ebp)
80105641:	e8 67 ff ff ff       	call   801055ad <memmove>
80105646:	83 c4 0c             	add    $0xc,%esp
}
80105649:	c9                   	leave  
8010564a:	c3                   	ret    

8010564b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010564b:	f3 0f 1e fb          	endbr32 
8010564f:	55                   	push   %ebp
80105650:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105652:	eb 0c                	jmp    80105660 <strncmp+0x15>
    n--, p++, q++;
80105654:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105658:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010565c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105660:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105664:	74 1a                	je     80105680 <strncmp+0x35>
80105666:	8b 45 08             	mov    0x8(%ebp),%eax
80105669:	0f b6 00             	movzbl (%eax),%eax
8010566c:	84 c0                	test   %al,%al
8010566e:	74 10                	je     80105680 <strncmp+0x35>
80105670:	8b 45 08             	mov    0x8(%ebp),%eax
80105673:	0f b6 10             	movzbl (%eax),%edx
80105676:	8b 45 0c             	mov    0xc(%ebp),%eax
80105679:	0f b6 00             	movzbl (%eax),%eax
8010567c:	38 c2                	cmp    %al,%dl
8010567e:	74 d4                	je     80105654 <strncmp+0x9>
  if(n == 0)
80105680:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105684:	75 07                	jne    8010568d <strncmp+0x42>
    return 0;
80105686:	b8 00 00 00 00       	mov    $0x0,%eax
8010568b:	eb 16                	jmp    801056a3 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	0f b6 00             	movzbl (%eax),%eax
80105693:	0f b6 d0             	movzbl %al,%edx
80105696:	8b 45 0c             	mov    0xc(%ebp),%eax
80105699:	0f b6 00             	movzbl (%eax),%eax
8010569c:	0f b6 c0             	movzbl %al,%eax
8010569f:	29 c2                	sub    %eax,%edx
801056a1:	89 d0                	mov    %edx,%eax
}
801056a3:	5d                   	pop    %ebp
801056a4:	c3                   	ret    

801056a5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056a5:	f3 0f 1e fb          	endbr32 
801056a9:	55                   	push   %ebp
801056aa:	89 e5                	mov    %esp,%ebp
801056ac:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056af:	8b 45 08             	mov    0x8(%ebp),%eax
801056b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056b5:	90                   	nop
801056b6:	8b 45 10             	mov    0x10(%ebp),%eax
801056b9:	8d 50 ff             	lea    -0x1(%eax),%edx
801056bc:	89 55 10             	mov    %edx,0x10(%ebp)
801056bf:	85 c0                	test   %eax,%eax
801056c1:	7e 2c                	jle    801056ef <strncpy+0x4a>
801056c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801056c6:	8d 42 01             	lea    0x1(%edx),%eax
801056c9:	89 45 0c             	mov    %eax,0xc(%ebp)
801056cc:	8b 45 08             	mov    0x8(%ebp),%eax
801056cf:	8d 48 01             	lea    0x1(%eax),%ecx
801056d2:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056d5:	0f b6 12             	movzbl (%edx),%edx
801056d8:	88 10                	mov    %dl,(%eax)
801056da:	0f b6 00             	movzbl (%eax),%eax
801056dd:	84 c0                	test   %al,%al
801056df:	75 d5                	jne    801056b6 <strncpy+0x11>
    ;
  while(n-- > 0)
801056e1:	eb 0c                	jmp    801056ef <strncpy+0x4a>
    *s++ = 0;
801056e3:	8b 45 08             	mov    0x8(%ebp),%eax
801056e6:	8d 50 01             	lea    0x1(%eax),%edx
801056e9:	89 55 08             	mov    %edx,0x8(%ebp)
801056ec:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801056ef:	8b 45 10             	mov    0x10(%ebp),%eax
801056f2:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f5:	89 55 10             	mov    %edx,0x10(%ebp)
801056f8:	85 c0                	test   %eax,%eax
801056fa:	7f e7                	jg     801056e3 <strncpy+0x3e>
  return os;
801056fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056ff:	c9                   	leave  
80105700:	c3                   	ret    

80105701 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105701:	f3 0f 1e fb          	endbr32 
80105705:	55                   	push   %ebp
80105706:	89 e5                	mov    %esp,%ebp
80105708:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010570b:	8b 45 08             	mov    0x8(%ebp),%eax
8010570e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105711:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105715:	7f 05                	jg     8010571c <safestrcpy+0x1b>
    return os;
80105717:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010571a:	eb 31                	jmp    8010574d <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010571c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105720:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105724:	7e 1e                	jle    80105744 <safestrcpy+0x43>
80105726:	8b 55 0c             	mov    0xc(%ebp),%edx
80105729:	8d 42 01             	lea    0x1(%edx),%eax
8010572c:	89 45 0c             	mov    %eax,0xc(%ebp)
8010572f:	8b 45 08             	mov    0x8(%ebp),%eax
80105732:	8d 48 01             	lea    0x1(%eax),%ecx
80105735:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105738:	0f b6 12             	movzbl (%edx),%edx
8010573b:	88 10                	mov    %dl,(%eax)
8010573d:	0f b6 00             	movzbl (%eax),%eax
80105740:	84 c0                	test   %al,%al
80105742:	75 d8                	jne    8010571c <safestrcpy+0x1b>
    ;
  *s = 0;
80105744:	8b 45 08             	mov    0x8(%ebp),%eax
80105747:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010574a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010574d:	c9                   	leave  
8010574e:	c3                   	ret    

8010574f <strlen>:

int
strlen(const char *s)
{
8010574f:	f3 0f 1e fb          	endbr32 
80105753:	55                   	push   %ebp
80105754:	89 e5                	mov    %esp,%ebp
80105756:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105759:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105760:	eb 04                	jmp    80105766 <strlen+0x17>
80105762:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105766:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105769:	8b 45 08             	mov    0x8(%ebp),%eax
8010576c:	01 d0                	add    %edx,%eax
8010576e:	0f b6 00             	movzbl (%eax),%eax
80105771:	84 c0                	test   %al,%al
80105773:	75 ed                	jne    80105762 <strlen+0x13>
    ;
  return n;
80105775:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105778:	c9                   	leave  
80105779:	c3                   	ret    

8010577a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010577a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010577e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105782:	55                   	push   %ebp
  pushl %ebx
80105783:	53                   	push   %ebx
  pushl %esi
80105784:	56                   	push   %esi
  pushl %edi
80105785:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105786:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105788:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010578a:	5f                   	pop    %edi
  popl %esi
8010578b:	5e                   	pop    %esi
  popl %ebx
8010578c:	5b                   	pop    %ebx
  popl %ebp
8010578d:	5d                   	pop    %ebp
  ret
8010578e:	c3                   	ret    

8010578f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010578f:	f3 0f 1e fb          	endbr32 
80105793:	55                   	push   %ebp
80105794:	89 e5                	mov    %esp,%ebp
80105796:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105799:	e8 0c ed ff ff       	call   801044aa <myproc>
8010579e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a4:	8b 00                	mov    (%eax),%eax
801057a6:	39 45 08             	cmp    %eax,0x8(%ebp)
801057a9:	73 0f                	jae    801057ba <fetchint+0x2b>
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
801057ae:	8d 50 04             	lea    0x4(%eax),%edx
801057b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b4:	8b 00                	mov    (%eax),%eax
801057b6:	39 c2                	cmp    %eax,%edx
801057b8:	76 07                	jbe    801057c1 <fetchint+0x32>
    return -1;
801057ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bf:	eb 0f                	jmp    801057d0 <fetchint+0x41>
  *ip = *(int*)(addr);
801057c1:	8b 45 08             	mov    0x8(%ebp),%eax
801057c4:	8b 10                	mov    (%eax),%edx
801057c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c9:	89 10                	mov    %edx,(%eax)
  return 0;
801057cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057d0:	c9                   	leave  
801057d1:	c3                   	ret    

801057d2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801057d2:	f3 0f 1e fb          	endbr32 
801057d6:	55                   	push   %ebp
801057d7:	89 e5                	mov    %esp,%ebp
801057d9:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801057dc:	e8 c9 ec ff ff       	call   801044aa <myproc>
801057e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e7:	8b 00                	mov    (%eax),%eax
801057e9:	39 45 08             	cmp    %eax,0x8(%ebp)
801057ec:	72 07                	jb     801057f5 <fetchstr+0x23>
    return -1;
801057ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f3:	eb 43                	jmp    80105838 <fetchstr+0x66>
  *pp = (char*)addr;
801057f5:	8b 55 08             	mov    0x8(%ebp),%edx
801057f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057fb:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801057fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105800:	8b 00                	mov    (%eax),%eax
80105802:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105805:	8b 45 0c             	mov    0xc(%ebp),%eax
80105808:	8b 00                	mov    (%eax),%eax
8010580a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580d:	eb 1c                	jmp    8010582b <fetchstr+0x59>
    if(*s == 0)
8010580f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105812:	0f b6 00             	movzbl (%eax),%eax
80105815:	84 c0                	test   %al,%al
80105817:	75 0e                	jne    80105827 <fetchstr+0x55>
      return s - *pp;
80105819:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581c:	8b 00                	mov    (%eax),%eax
8010581e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105821:	29 c2                	sub    %eax,%edx
80105823:	89 d0                	mov    %edx,%eax
80105825:	eb 11                	jmp    80105838 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105827:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105831:	72 dc                	jb     8010580f <fetchstr+0x3d>
  }
  return -1;
80105833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105838:	c9                   	leave  
80105839:	c3                   	ret    

8010583a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010583a:	f3 0f 1e fb          	endbr32 
8010583e:	55                   	push   %ebp
8010583f:	89 e5                	mov    %esp,%ebp
80105841:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105844:	e8 61 ec ff ff       	call   801044aa <myproc>
80105849:	8b 40 18             	mov    0x18(%eax),%eax
8010584c:	8b 40 44             	mov    0x44(%eax),%eax
8010584f:	8b 55 08             	mov    0x8(%ebp),%edx
80105852:	c1 e2 02             	shl    $0x2,%edx
80105855:	01 d0                	add    %edx,%eax
80105857:	83 c0 04             	add    $0x4,%eax
8010585a:	83 ec 08             	sub    $0x8,%esp
8010585d:	ff 75 0c             	pushl  0xc(%ebp)
80105860:	50                   	push   %eax
80105861:	e8 29 ff ff ff       	call   8010578f <fetchint>
80105866:	83 c4 10             	add    $0x10,%esp
}
80105869:	c9                   	leave  
8010586a:	c3                   	ret    

8010586b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010586b:	f3 0f 1e fb          	endbr32 
8010586f:	55                   	push   %ebp
80105870:	89 e5                	mov    %esp,%ebp
80105872:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105875:	e8 30 ec ff ff       	call   801044aa <myproc>
8010587a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010587d:	83 ec 08             	sub    $0x8,%esp
80105880:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105883:	50                   	push   %eax
80105884:	ff 75 08             	pushl  0x8(%ebp)
80105887:	e8 ae ff ff ff       	call   8010583a <argint>
8010588c:	83 c4 10             	add    $0x10,%esp
8010588f:	85 c0                	test   %eax,%eax
80105891:	79 07                	jns    8010589a <argptr+0x2f>
    return -1;
80105893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105898:	eb 3b                	jmp    801058d5 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010589a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010589e:	78 1f                	js     801058bf <argptr+0x54>
801058a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a3:	8b 00                	mov    (%eax),%eax
801058a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058a8:	39 d0                	cmp    %edx,%eax
801058aa:	76 13                	jbe    801058bf <argptr+0x54>
801058ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058af:	89 c2                	mov    %eax,%edx
801058b1:	8b 45 10             	mov    0x10(%ebp),%eax
801058b4:	01 c2                	add    %eax,%edx
801058b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b9:	8b 00                	mov    (%eax),%eax
801058bb:	39 c2                	cmp    %eax,%edx
801058bd:	76 07                	jbe    801058c6 <argptr+0x5b>
    return -1;
801058bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c4:	eb 0f                	jmp    801058d5 <argptr+0x6a>
  *pp = (char*)i;
801058c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c9:	89 c2                	mov    %eax,%edx
801058cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ce:	89 10                	mov    %edx,(%eax)
  return 0;
801058d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d5:	c9                   	leave  
801058d6:	c3                   	ret    

801058d7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058d7:	f3 0f 1e fb          	endbr32 
801058db:	55                   	push   %ebp
801058dc:	89 e5                	mov    %esp,%ebp
801058de:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058e1:	83 ec 08             	sub    $0x8,%esp
801058e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e7:	50                   	push   %eax
801058e8:	ff 75 08             	pushl  0x8(%ebp)
801058eb:	e8 4a ff ff ff       	call   8010583a <argint>
801058f0:	83 c4 10             	add    $0x10,%esp
801058f3:	85 c0                	test   %eax,%eax
801058f5:	79 07                	jns    801058fe <argstr+0x27>
    return -1;
801058f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fc:	eb 12                	jmp    80105910 <argstr+0x39>
  return fetchstr(addr, pp);
801058fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105901:	83 ec 08             	sub    $0x8,%esp
80105904:	ff 75 0c             	pushl  0xc(%ebp)
80105907:	50                   	push   %eax
80105908:	e8 c5 fe ff ff       	call   801057d2 <fetchstr>
8010590d:	83 c4 10             	add    $0x10,%esp
}
80105910:	c9                   	leave  
80105911:	c3                   	ret    

80105912 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
80105912:	f3 0f 1e fb          	endbr32 
80105916:	55                   	push   %ebp
80105917:	89 e5                	mov    %esp,%ebp
80105919:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010591c:	e8 89 eb ff ff       	call   801044aa <myproc>
80105921:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105927:	8b 40 18             	mov    0x18(%eax),%eax
8010592a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010592d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105934:	7e 2f                	jle    80105965 <syscall+0x53>
80105936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105939:	83 f8 18             	cmp    $0x18,%eax
8010593c:	77 27                	ja     80105965 <syscall+0x53>
8010593e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105941:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105948:	85 c0                	test   %eax,%eax
8010594a:	74 19                	je     80105965 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
8010594c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594f:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105956:	ff d0                	call   *%eax
80105958:	89 c2                	mov    %eax,%edx
8010595a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595d:	8b 40 18             	mov    0x18(%eax),%eax
80105960:	89 50 1c             	mov    %edx,0x1c(%eax)
80105963:	eb 2c                	jmp    80105991 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105968:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010596b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596e:	8b 40 10             	mov    0x10(%eax),%eax
80105971:	ff 75 f0             	pushl  -0x10(%ebp)
80105974:	52                   	push   %edx
80105975:	50                   	push   %eax
80105976:	68 2a 91 10 80       	push   $0x8010912a
8010597b:	e8 98 aa ff ff       	call   80100418 <cprintf>
80105980:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105986:	8b 40 18             	mov    0x18(%eax),%eax
80105989:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105990:	90                   	nop
80105991:	90                   	nop
80105992:	c9                   	leave  
80105993:	c3                   	ret    

80105994 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105994:	f3 0f 1e fb          	endbr32 
80105998:	55                   	push   %ebp
80105999:	89 e5                	mov    %esp,%ebp
8010599b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010599e:	83 ec 08             	sub    $0x8,%esp
801059a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a4:	50                   	push   %eax
801059a5:	ff 75 08             	pushl  0x8(%ebp)
801059a8:	e8 8d fe ff ff       	call   8010583a <argint>
801059ad:	83 c4 10             	add    $0x10,%esp
801059b0:	85 c0                	test   %eax,%eax
801059b2:	79 07                	jns    801059bb <argfd+0x27>
    return -1;
801059b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b9:	eb 4f                	jmp    80105a0a <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801059bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059be:	85 c0                	test   %eax,%eax
801059c0:	78 20                	js     801059e2 <argfd+0x4e>
801059c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c5:	83 f8 0f             	cmp    $0xf,%eax
801059c8:	7f 18                	jg     801059e2 <argfd+0x4e>
801059ca:	e8 db ea ff ff       	call   801044aa <myproc>
801059cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d2:	83 c2 08             	add    $0x8,%edx
801059d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059e0:	75 07                	jne    801059e9 <argfd+0x55>
    return -1;
801059e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e7:	eb 21                	jmp    80105a0a <argfd+0x76>
  if(pfd)
801059e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059ed:	74 08                	je     801059f7 <argfd+0x63>
    *pfd = fd;
801059ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f5:	89 10                	mov    %edx,(%eax)
  if(pf)
801059f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059fb:	74 08                	je     80105a05 <argfd+0x71>
    *pf = f;
801059fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105a00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a03:	89 10                	mov    %edx,(%eax)
  return 0;
80105a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a0a:	c9                   	leave  
80105a0b:	c3                   	ret    

80105a0c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a0c:	f3 0f 1e fb          	endbr32 
80105a10:	55                   	push   %ebp
80105a11:	89 e5                	mov    %esp,%ebp
80105a13:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a16:	e8 8f ea ff ff       	call   801044aa <myproc>
80105a1b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a25:	eb 2a                	jmp    80105a51 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a2d:	83 c2 08             	add    $0x8,%edx
80105a30:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a34:	85 c0                	test   %eax,%eax
80105a36:	75 15                	jne    80105a4d <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a3e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a41:	8b 55 08             	mov    0x8(%ebp),%edx
80105a44:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4b:	eb 0f                	jmp    80105a5c <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105a4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a51:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a55:	7e d0                	jle    80105a27 <fdalloc+0x1b>
    }
  }
  return -1;
80105a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a5c:	c9                   	leave  
80105a5d:	c3                   	ret    

80105a5e <sys_dup>:

int
sys_dup(void)
{
80105a5e:	f3 0f 1e fb          	endbr32 
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a68:	83 ec 04             	sub    $0x4,%esp
80105a6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a6e:	50                   	push   %eax
80105a6f:	6a 00                	push   $0x0
80105a71:	6a 00                	push   $0x0
80105a73:	e8 1c ff ff ff       	call   80105994 <argfd>
80105a78:	83 c4 10             	add    $0x10,%esp
80105a7b:	85 c0                	test   %eax,%eax
80105a7d:	79 07                	jns    80105a86 <sys_dup+0x28>
    return -1;
80105a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a84:	eb 31                	jmp    80105ab7 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a89:	83 ec 0c             	sub    $0xc,%esp
80105a8c:	50                   	push   %eax
80105a8d:	e8 7a ff ff ff       	call   80105a0c <fdalloc>
80105a92:	83 c4 10             	add    $0x10,%esp
80105a95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a9c:	79 07                	jns    80105aa5 <sys_dup+0x47>
    return -1;
80105a9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa3:	eb 12                	jmp    80105ab7 <sys_dup+0x59>
  filedup(f);
80105aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa8:	83 ec 0c             	sub    $0xc,%esp
80105aab:	50                   	push   %eax
80105aac:	e8 96 b6 ff ff       	call   80101147 <filedup>
80105ab1:	83 c4 10             	add    $0x10,%esp
  return fd;
80105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ab7:	c9                   	leave  
80105ab8:	c3                   	ret    

80105ab9 <sys_read>:

int
sys_read(void)
{
80105ab9:	f3 0f 1e fb          	endbr32 
80105abd:	55                   	push   %ebp
80105abe:	89 e5                	mov    %esp,%ebp
80105ac0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ac3:	83 ec 04             	sub    $0x4,%esp
80105ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ac9:	50                   	push   %eax
80105aca:	6a 00                	push   $0x0
80105acc:	6a 00                	push   $0x0
80105ace:	e8 c1 fe ff ff       	call   80105994 <argfd>
80105ad3:	83 c4 10             	add    $0x10,%esp
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	78 2e                	js     80105b08 <sys_read+0x4f>
80105ada:	83 ec 08             	sub    $0x8,%esp
80105add:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ae0:	50                   	push   %eax
80105ae1:	6a 02                	push   $0x2
80105ae3:	e8 52 fd ff ff       	call   8010583a <argint>
80105ae8:	83 c4 10             	add    $0x10,%esp
80105aeb:	85 c0                	test   %eax,%eax
80105aed:	78 19                	js     80105b08 <sys_read+0x4f>
80105aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af2:	83 ec 04             	sub    $0x4,%esp
80105af5:	50                   	push   %eax
80105af6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105af9:	50                   	push   %eax
80105afa:	6a 01                	push   $0x1
80105afc:	e8 6a fd ff ff       	call   8010586b <argptr>
80105b01:	83 c4 10             	add    $0x10,%esp
80105b04:	85 c0                	test   %eax,%eax
80105b06:	79 07                	jns    80105b0f <sys_read+0x56>
    return -1;
80105b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0d:	eb 17                	jmp    80105b26 <sys_read+0x6d>
  return fileread(f, p, n);
80105b0f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b12:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b18:	83 ec 04             	sub    $0x4,%esp
80105b1b:	51                   	push   %ecx
80105b1c:	52                   	push   %edx
80105b1d:	50                   	push   %eax
80105b1e:	e8 c0 b7 ff ff       	call   801012e3 <fileread>
80105b23:	83 c4 10             	add    $0x10,%esp
}
80105b26:	c9                   	leave  
80105b27:	c3                   	ret    

80105b28 <sys_write>:

int
sys_write(void)
{
80105b28:	f3 0f 1e fb          	endbr32 
80105b2c:	55                   	push   %ebp
80105b2d:	89 e5                	mov    %esp,%ebp
80105b2f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b32:	83 ec 04             	sub    $0x4,%esp
80105b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b38:	50                   	push   %eax
80105b39:	6a 00                	push   $0x0
80105b3b:	6a 00                	push   $0x0
80105b3d:	e8 52 fe ff ff       	call   80105994 <argfd>
80105b42:	83 c4 10             	add    $0x10,%esp
80105b45:	85 c0                	test   %eax,%eax
80105b47:	78 2e                	js     80105b77 <sys_write+0x4f>
80105b49:	83 ec 08             	sub    $0x8,%esp
80105b4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b4f:	50                   	push   %eax
80105b50:	6a 02                	push   $0x2
80105b52:	e8 e3 fc ff ff       	call   8010583a <argint>
80105b57:	83 c4 10             	add    $0x10,%esp
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	78 19                	js     80105b77 <sys_write+0x4f>
80105b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b61:	83 ec 04             	sub    $0x4,%esp
80105b64:	50                   	push   %eax
80105b65:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b68:	50                   	push   %eax
80105b69:	6a 01                	push   $0x1
80105b6b:	e8 fb fc ff ff       	call   8010586b <argptr>
80105b70:	83 c4 10             	add    $0x10,%esp
80105b73:	85 c0                	test   %eax,%eax
80105b75:	79 07                	jns    80105b7e <sys_write+0x56>
    return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7c:	eb 17                	jmp    80105b95 <sys_write+0x6d>
  return filewrite(f, p, n);
80105b7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b87:	83 ec 04             	sub    $0x4,%esp
80105b8a:	51                   	push   %ecx
80105b8b:	52                   	push   %edx
80105b8c:	50                   	push   %eax
80105b8d:	e8 0d b8 ff ff       	call   8010139f <filewrite>
80105b92:	83 c4 10             	add    $0x10,%esp
}
80105b95:	c9                   	leave  
80105b96:	c3                   	ret    

80105b97 <sys_close>:

int
sys_close(void)
{
80105b97:	f3 0f 1e fb          	endbr32 
80105b9b:	55                   	push   %ebp
80105b9c:	89 e5                	mov    %esp,%ebp
80105b9e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105ba1:	83 ec 04             	sub    $0x4,%esp
80105ba4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ba7:	50                   	push   %eax
80105ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bab:	50                   	push   %eax
80105bac:	6a 00                	push   $0x0
80105bae:	e8 e1 fd ff ff       	call   80105994 <argfd>
80105bb3:	83 c4 10             	add    $0x10,%esp
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	79 07                	jns    80105bc1 <sys_close+0x2a>
    return -1;
80105bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbf:	eb 27                	jmp    80105be8 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105bc1:	e8 e4 e8 ff ff       	call   801044aa <myproc>
80105bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bc9:	83 c2 08             	add    $0x8,%edx
80105bcc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bd3:	00 
  fileclose(f);
80105bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd7:	83 ec 0c             	sub    $0xc,%esp
80105bda:	50                   	push   %eax
80105bdb:	e8 bc b5 ff ff       	call   8010119c <fileclose>
80105be0:	83 c4 10             	add    $0x10,%esp
  return 0;
80105be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105be8:	c9                   	leave  
80105be9:	c3                   	ret    

80105bea <sys_fstat>:

int
sys_fstat(void)
{
80105bea:	f3 0f 1e fb          	endbr32 
80105bee:	55                   	push   %ebp
80105bef:	89 e5                	mov    %esp,%ebp
80105bf1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105bf4:	83 ec 04             	sub    $0x4,%esp
80105bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bfa:	50                   	push   %eax
80105bfb:	6a 00                	push   $0x0
80105bfd:	6a 00                	push   $0x0
80105bff:	e8 90 fd ff ff       	call   80105994 <argfd>
80105c04:	83 c4 10             	add    $0x10,%esp
80105c07:	85 c0                	test   %eax,%eax
80105c09:	78 17                	js     80105c22 <sys_fstat+0x38>
80105c0b:	83 ec 04             	sub    $0x4,%esp
80105c0e:	6a 14                	push   $0x14
80105c10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c13:	50                   	push   %eax
80105c14:	6a 01                	push   $0x1
80105c16:	e8 50 fc ff ff       	call   8010586b <argptr>
80105c1b:	83 c4 10             	add    $0x10,%esp
80105c1e:	85 c0                	test   %eax,%eax
80105c20:	79 07                	jns    80105c29 <sys_fstat+0x3f>
    return -1;
80105c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c27:	eb 13                	jmp    80105c3c <sys_fstat+0x52>
  return filestat(f, st);
80105c29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2f:	83 ec 08             	sub    $0x8,%esp
80105c32:	52                   	push   %edx
80105c33:	50                   	push   %eax
80105c34:	e8 4f b6 ff ff       	call   80101288 <filestat>
80105c39:	83 c4 10             	add    $0x10,%esp
}
80105c3c:	c9                   	leave  
80105c3d:	c3                   	ret    

80105c3e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c3e:	f3 0f 1e fb          	endbr32 
80105c42:	55                   	push   %ebp
80105c43:	89 e5                	mov    %esp,%ebp
80105c45:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c48:	83 ec 08             	sub    $0x8,%esp
80105c4b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c4e:	50                   	push   %eax
80105c4f:	6a 00                	push   $0x0
80105c51:	e8 81 fc ff ff       	call   801058d7 <argstr>
80105c56:	83 c4 10             	add    $0x10,%esp
80105c59:	85 c0                	test   %eax,%eax
80105c5b:	78 15                	js     80105c72 <sys_link+0x34>
80105c5d:	83 ec 08             	sub    $0x8,%esp
80105c60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c63:	50                   	push   %eax
80105c64:	6a 01                	push   $0x1
80105c66:	e8 6c fc ff ff       	call   801058d7 <argstr>
80105c6b:	83 c4 10             	add    $0x10,%esp
80105c6e:	85 c0                	test   %eax,%eax
80105c70:	79 0a                	jns    80105c7c <sys_link+0x3e>
    return -1;
80105c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c77:	e9 68 01 00 00       	jmp    80105de4 <sys_link+0x1a6>

  begin_op();
80105c7c:	e8 6a da ff ff       	call   801036eb <begin_op>
  if((ip = namei(old)) == 0){
80105c81:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c84:	83 ec 0c             	sub    $0xc,%esp
80105c87:	50                   	push   %eax
80105c88:	e8 fa c9 ff ff       	call   80102687 <namei>
80105c8d:	83 c4 10             	add    $0x10,%esp
80105c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c97:	75 0f                	jne    80105ca8 <sys_link+0x6a>
    end_op();
80105c99:	e8 dd da ff ff       	call   8010377b <end_op>
    return -1;
80105c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca3:	e9 3c 01 00 00       	jmp    80105de4 <sys_link+0x1a6>
  }

  ilock(ip);
80105ca8:	83 ec 0c             	sub    $0xc,%esp
80105cab:	ff 75 f4             	pushl  -0xc(%ebp)
80105cae:	e8 69 be ff ff       	call   80101b1c <ilock>
80105cb3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cbd:	66 83 f8 01          	cmp    $0x1,%ax
80105cc1:	75 1d                	jne    80105ce0 <sys_link+0xa2>
    iunlockput(ip);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc9:	e8 8b c0 ff ff       	call   80101d59 <iunlockput>
80105cce:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cd1:	e8 a5 da ff ff       	call   8010377b <end_op>
    return -1;
80105cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdb:	e9 04 01 00 00       	jmp    80105de4 <sys_link+0x1a6>
  }

  ip->nlink++;
80105ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ce7:	83 c0 01             	add    $0x1,%eax
80105cea:	89 c2                	mov    %eax,%edx
80105cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cef:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105cf3:	83 ec 0c             	sub    $0xc,%esp
80105cf6:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf9:	e8 35 bc ff ff       	call   80101933 <iupdate>
80105cfe:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d01:	83 ec 0c             	sub    $0xc,%esp
80105d04:	ff 75 f4             	pushl  -0xc(%ebp)
80105d07:	e8 27 bf ff ff       	call   80101c33 <iunlock>
80105d0c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d12:	83 ec 08             	sub    $0x8,%esp
80105d15:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d18:	52                   	push   %edx
80105d19:	50                   	push   %eax
80105d1a:	e8 88 c9 ff ff       	call   801026a7 <nameiparent>
80105d1f:	83 c4 10             	add    $0x10,%esp
80105d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d29:	74 71                	je     80105d9c <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105d2b:	83 ec 0c             	sub    $0xc,%esp
80105d2e:	ff 75 f0             	pushl  -0x10(%ebp)
80105d31:	e8 e6 bd ff ff       	call   80101b1c <ilock>
80105d36:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3c:	8b 10                	mov    (%eax),%edx
80105d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d41:	8b 00                	mov    (%eax),%eax
80105d43:	39 c2                	cmp    %eax,%edx
80105d45:	75 1d                	jne    80105d64 <sys_link+0x126>
80105d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4a:	8b 40 04             	mov    0x4(%eax),%eax
80105d4d:	83 ec 04             	sub    $0x4,%esp
80105d50:	50                   	push   %eax
80105d51:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d54:	50                   	push   %eax
80105d55:	ff 75 f0             	pushl  -0x10(%ebp)
80105d58:	e8 87 c6 ff ff       	call   801023e4 <dirlink>
80105d5d:	83 c4 10             	add    $0x10,%esp
80105d60:	85 c0                	test   %eax,%eax
80105d62:	79 10                	jns    80105d74 <sys_link+0x136>
    iunlockput(dp);
80105d64:	83 ec 0c             	sub    $0xc,%esp
80105d67:	ff 75 f0             	pushl  -0x10(%ebp)
80105d6a:	e8 ea bf ff ff       	call   80101d59 <iunlockput>
80105d6f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d72:	eb 29                	jmp    80105d9d <sys_link+0x15f>
  }
  iunlockput(dp);
80105d74:	83 ec 0c             	sub    $0xc,%esp
80105d77:	ff 75 f0             	pushl  -0x10(%ebp)
80105d7a:	e8 da bf ff ff       	call   80101d59 <iunlockput>
80105d7f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	ff 75 f4             	pushl  -0xc(%ebp)
80105d88:	e8 f8 be ff ff       	call   80101c85 <iput>
80105d8d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d90:	e8 e6 d9 ff ff       	call   8010377b <end_op>

  return 0;
80105d95:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9a:	eb 48                	jmp    80105de4 <sys_link+0x1a6>
    goto bad;
80105d9c:	90                   	nop

bad:
  ilock(ip);
80105d9d:	83 ec 0c             	sub    $0xc,%esp
80105da0:	ff 75 f4             	pushl  -0xc(%ebp)
80105da3:	e8 74 bd ff ff       	call   80101b1c <ilock>
80105da8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dae:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105db2:	83 e8 01             	sub    $0x1,%eax
80105db5:	89 c2                	mov    %eax,%edx
80105db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dba:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dbe:	83 ec 0c             	sub    $0xc,%esp
80105dc1:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc4:	e8 6a bb ff ff       	call   80101933 <iupdate>
80105dc9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105dcc:	83 ec 0c             	sub    $0xc,%esp
80105dcf:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd2:	e8 82 bf ff ff       	call   80101d59 <iunlockput>
80105dd7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dda:	e8 9c d9 ff ff       	call   8010377b <end_op>
  return -1;
80105ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105de4:	c9                   	leave  
80105de5:	c3                   	ret    

80105de6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105de6:	f3 0f 1e fb          	endbr32 
80105dea:	55                   	push   %ebp
80105deb:	89 e5                	mov    %esp,%ebp
80105ded:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105df0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105df7:	eb 40                	jmp    80105e39 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfc:	6a 10                	push   $0x10
80105dfe:	50                   	push   %eax
80105dff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e02:	50                   	push   %eax
80105e03:	ff 75 08             	pushl  0x8(%ebp)
80105e06:	e8 19 c2 ff ff       	call   80102024 <readi>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	83 f8 10             	cmp    $0x10,%eax
80105e11:	74 0d                	je     80105e20 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e13:	83 ec 0c             	sub    $0xc,%esp
80105e16:	68 46 91 10 80       	push   $0x80109146
80105e1b:	e8 e8 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e20:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e24:	66 85 c0             	test   %ax,%ax
80105e27:	74 07                	je     80105e30 <isdirempty+0x4a>
      return 0;
80105e29:	b8 00 00 00 00       	mov    $0x0,%eax
80105e2e:	eb 1b                	jmp    80105e4b <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e33:	83 c0 10             	add    $0x10,%eax
80105e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e39:	8b 45 08             	mov    0x8(%ebp),%eax
80105e3c:	8b 50 58             	mov    0x58(%eax),%edx
80105e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e42:	39 c2                	cmp    %eax,%edx
80105e44:	77 b3                	ja     80105df9 <isdirempty+0x13>
  }
  return 1;
80105e46:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e4b:	c9                   	leave  
80105e4c:	c3                   	ret    

80105e4d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e4d:	f3 0f 1e fb          	endbr32 
80105e51:	55                   	push   %ebp
80105e52:	89 e5                	mov    %esp,%ebp
80105e54:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e57:	83 ec 08             	sub    $0x8,%esp
80105e5a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e5d:	50                   	push   %eax
80105e5e:	6a 00                	push   $0x0
80105e60:	e8 72 fa ff ff       	call   801058d7 <argstr>
80105e65:	83 c4 10             	add    $0x10,%esp
80105e68:	85 c0                	test   %eax,%eax
80105e6a:	79 0a                	jns    80105e76 <sys_unlink+0x29>
    return -1;
80105e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e71:	e9 bf 01 00 00       	jmp    80106035 <sys_unlink+0x1e8>

  begin_op();
80105e76:	e8 70 d8 ff ff       	call   801036eb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e7b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e7e:	83 ec 08             	sub    $0x8,%esp
80105e81:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e84:	52                   	push   %edx
80105e85:	50                   	push   %eax
80105e86:	e8 1c c8 ff ff       	call   801026a7 <nameiparent>
80105e8b:	83 c4 10             	add    $0x10,%esp
80105e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e95:	75 0f                	jne    80105ea6 <sys_unlink+0x59>
    end_op();
80105e97:	e8 df d8 ff ff       	call   8010377b <end_op>
    return -1;
80105e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea1:	e9 8f 01 00 00       	jmp    80106035 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	ff 75 f4             	pushl  -0xc(%ebp)
80105eac:	e8 6b bc ff ff       	call   80101b1c <ilock>
80105eb1:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105eb4:	83 ec 08             	sub    $0x8,%esp
80105eb7:	68 58 91 10 80       	push   $0x80109158
80105ebc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ebf:	50                   	push   %eax
80105ec0:	e8 42 c4 ff ff       	call   80102307 <namecmp>
80105ec5:	83 c4 10             	add    $0x10,%esp
80105ec8:	85 c0                	test   %eax,%eax
80105eca:	0f 84 49 01 00 00    	je     80106019 <sys_unlink+0x1cc>
80105ed0:	83 ec 08             	sub    $0x8,%esp
80105ed3:	68 5a 91 10 80       	push   $0x8010915a
80105ed8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105edb:	50                   	push   %eax
80105edc:	e8 26 c4 ff ff       	call   80102307 <namecmp>
80105ee1:	83 c4 10             	add    $0x10,%esp
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	0f 84 2d 01 00 00    	je     80106019 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105eec:	83 ec 04             	sub    $0x4,%esp
80105eef:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ef2:	50                   	push   %eax
80105ef3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ef6:	50                   	push   %eax
80105ef7:	ff 75 f4             	pushl  -0xc(%ebp)
80105efa:	e8 27 c4 ff ff       	call   80102326 <dirlookup>
80105eff:	83 c4 10             	add    $0x10,%esp
80105f02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f09:	0f 84 0d 01 00 00    	je     8010601c <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f0f:	83 ec 0c             	sub    $0xc,%esp
80105f12:	ff 75 f0             	pushl  -0x10(%ebp)
80105f15:	e8 02 bc ff ff       	call   80101b1c <ilock>
80105f1a:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f24:	66 85 c0             	test   %ax,%ax
80105f27:	7f 0d                	jg     80105f36 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	68 5d 91 10 80       	push   $0x8010915d
80105f31:	e8 d2 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f3d:	66 83 f8 01          	cmp    $0x1,%ax
80105f41:	75 25                	jne    80105f68 <sys_unlink+0x11b>
80105f43:	83 ec 0c             	sub    $0xc,%esp
80105f46:	ff 75 f0             	pushl  -0x10(%ebp)
80105f49:	e8 98 fe ff ff       	call   80105de6 <isdirempty>
80105f4e:	83 c4 10             	add    $0x10,%esp
80105f51:	85 c0                	test   %eax,%eax
80105f53:	75 13                	jne    80105f68 <sys_unlink+0x11b>
    iunlockput(ip);
80105f55:	83 ec 0c             	sub    $0xc,%esp
80105f58:	ff 75 f0             	pushl  -0x10(%ebp)
80105f5b:	e8 f9 bd ff ff       	call   80101d59 <iunlockput>
80105f60:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105f63:	e9 b5 00 00 00       	jmp    8010601d <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105f68:	83 ec 04             	sub    $0x4,%esp
80105f6b:	6a 10                	push   $0x10
80105f6d:	6a 00                	push   $0x0
80105f6f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f72:	50                   	push   %eax
80105f73:	e8 6e f5 ff ff       	call   801054e6 <memset>
80105f78:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f7b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105f7e:	6a 10                	push   $0x10
80105f80:	50                   	push   %eax
80105f81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	ff 75 f4             	pushl  -0xc(%ebp)
80105f88:	e8 f0 c1 ff ff       	call   8010217d <writei>
80105f8d:	83 c4 10             	add    $0x10,%esp
80105f90:	83 f8 10             	cmp    $0x10,%eax
80105f93:	74 0d                	je     80105fa2 <sys_unlink+0x155>
    panic("unlink: writei");
80105f95:	83 ec 0c             	sub    $0xc,%esp
80105f98:	68 6f 91 10 80       	push   $0x8010916f
80105f9d:	e8 66 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80105fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fa9:	66 83 f8 01          	cmp    $0x1,%ax
80105fad:	75 21                	jne    80105fd0 <sys_unlink+0x183>
    dp->nlink--;
80105faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fb6:	83 e8 01             	sub    $0x1,%eax
80105fb9:	89 c2                	mov    %eax,%edx
80105fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbe:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105fc2:	83 ec 0c             	sub    $0xc,%esp
80105fc5:	ff 75 f4             	pushl  -0xc(%ebp)
80105fc8:	e8 66 b9 ff ff       	call   80101933 <iupdate>
80105fcd:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105fd0:	83 ec 0c             	sub    $0xc,%esp
80105fd3:	ff 75 f4             	pushl  -0xc(%ebp)
80105fd6:	e8 7e bd ff ff       	call   80101d59 <iunlockput>
80105fdb:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fe5:	83 e8 01             	sub    $0x1,%eax
80105fe8:	89 c2                	mov    %eax,%edx
80105fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fed:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ff1:	83 ec 0c             	sub    $0xc,%esp
80105ff4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ff7:	e8 37 b9 ff ff       	call   80101933 <iupdate>
80105ffc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105fff:	83 ec 0c             	sub    $0xc,%esp
80106002:	ff 75 f0             	pushl  -0x10(%ebp)
80106005:	e8 4f bd ff ff       	call   80101d59 <iunlockput>
8010600a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010600d:	e8 69 d7 ff ff       	call   8010377b <end_op>

  return 0;
80106012:	b8 00 00 00 00       	mov    $0x0,%eax
80106017:	eb 1c                	jmp    80106035 <sys_unlink+0x1e8>
    goto bad;
80106019:	90                   	nop
8010601a:	eb 01                	jmp    8010601d <sys_unlink+0x1d0>
    goto bad;
8010601c:	90                   	nop

bad:
  iunlockput(dp);
8010601d:	83 ec 0c             	sub    $0xc,%esp
80106020:	ff 75 f4             	pushl  -0xc(%ebp)
80106023:	e8 31 bd ff ff       	call   80101d59 <iunlockput>
80106028:	83 c4 10             	add    $0x10,%esp
  end_op();
8010602b:	e8 4b d7 ff ff       	call   8010377b <end_op>
  return -1;
80106030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106035:	c9                   	leave  
80106036:	c3                   	ret    

80106037 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106037:	f3 0f 1e fb          	endbr32 
8010603b:	55                   	push   %ebp
8010603c:	89 e5                	mov    %esp,%ebp
8010603e:	83 ec 38             	sub    $0x38,%esp
80106041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106044:	8b 55 10             	mov    0x10(%ebp),%edx
80106047:	8b 45 14             	mov    0x14(%ebp),%eax
8010604a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010604e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106052:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106056:	83 ec 08             	sub    $0x8,%esp
80106059:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010605c:	50                   	push   %eax
8010605d:	ff 75 08             	pushl  0x8(%ebp)
80106060:	e8 42 c6 ff ff       	call   801026a7 <nameiparent>
80106065:	83 c4 10             	add    $0x10,%esp
80106068:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010606b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010606f:	75 0a                	jne    8010607b <create+0x44>
    return 0;
80106071:	b8 00 00 00 00       	mov    $0x0,%eax
80106076:	e9 8e 01 00 00       	jmp    80106209 <create+0x1d2>
  ilock(dp);
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	ff 75 f4             	pushl  -0xc(%ebp)
80106081:	e8 96 ba ff ff       	call   80101b1c <ilock>
80106086:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106089:	83 ec 04             	sub    $0x4,%esp
8010608c:	6a 00                	push   $0x0
8010608e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106091:	50                   	push   %eax
80106092:	ff 75 f4             	pushl  -0xc(%ebp)
80106095:	e8 8c c2 ff ff       	call   80102326 <dirlookup>
8010609a:	83 c4 10             	add    $0x10,%esp
8010609d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060a4:	74 50                	je     801060f6 <create+0xbf>
    iunlockput(dp);
801060a6:	83 ec 0c             	sub    $0xc,%esp
801060a9:	ff 75 f4             	pushl  -0xc(%ebp)
801060ac:	e8 a8 bc ff ff       	call   80101d59 <iunlockput>
801060b1:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801060b4:	83 ec 0c             	sub    $0xc,%esp
801060b7:	ff 75 f0             	pushl  -0x10(%ebp)
801060ba:	e8 5d ba ff ff       	call   80101b1c <ilock>
801060bf:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801060c2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060c7:	75 15                	jne    801060de <create+0xa7>
801060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060d0:	66 83 f8 02          	cmp    $0x2,%ax
801060d4:	75 08                	jne    801060de <create+0xa7>
      return ip;
801060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d9:	e9 2b 01 00 00       	jmp    80106209 <create+0x1d2>
    iunlockput(ip);
801060de:	83 ec 0c             	sub    $0xc,%esp
801060e1:	ff 75 f0             	pushl  -0x10(%ebp)
801060e4:	e8 70 bc ff ff       	call   80101d59 <iunlockput>
801060e9:	83 c4 10             	add    $0x10,%esp
    return 0;
801060ec:	b8 00 00 00 00       	mov    $0x0,%eax
801060f1:	e9 13 01 00 00       	jmp    80106209 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060f6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fd:	8b 00                	mov    (%eax),%eax
801060ff:	83 ec 08             	sub    $0x8,%esp
80106102:	52                   	push   %edx
80106103:	50                   	push   %eax
80106104:	e8 4f b7 ff ff       	call   80101858 <ialloc>
80106109:	83 c4 10             	add    $0x10,%esp
8010610c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010610f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106113:	75 0d                	jne    80106122 <create+0xeb>
    panic("create: ialloc");
80106115:	83 ec 0c             	sub    $0xc,%esp
80106118:	68 7e 91 10 80       	push   $0x8010917e
8010611d:	e8 e6 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
80106122:	83 ec 0c             	sub    $0xc,%esp
80106125:	ff 75 f0             	pushl  -0x10(%ebp)
80106128:	e8 ef b9 ff ff       	call   80101b1c <ilock>
8010612d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106133:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106137:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010613b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106142:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106149:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010614f:	83 ec 0c             	sub    $0xc,%esp
80106152:	ff 75 f0             	pushl  -0x10(%ebp)
80106155:	e8 d9 b7 ff ff       	call   80101933 <iupdate>
8010615a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010615d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106162:	75 6a                	jne    801061ce <create+0x197>
    dp->nlink++;  // for ".."
80106164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106167:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010616b:	83 c0 01             	add    $0x1,%eax
8010616e:	89 c2                	mov    %eax,%edx
80106170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106173:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106177:	83 ec 0c             	sub    $0xc,%esp
8010617a:	ff 75 f4             	pushl  -0xc(%ebp)
8010617d:	e8 b1 b7 ff ff       	call   80101933 <iupdate>
80106182:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106188:	8b 40 04             	mov    0x4(%eax),%eax
8010618b:	83 ec 04             	sub    $0x4,%esp
8010618e:	50                   	push   %eax
8010618f:	68 58 91 10 80       	push   $0x80109158
80106194:	ff 75 f0             	pushl  -0x10(%ebp)
80106197:	e8 48 c2 ff ff       	call   801023e4 <dirlink>
8010619c:	83 c4 10             	add    $0x10,%esp
8010619f:	85 c0                	test   %eax,%eax
801061a1:	78 1e                	js     801061c1 <create+0x18a>
801061a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a6:	8b 40 04             	mov    0x4(%eax),%eax
801061a9:	83 ec 04             	sub    $0x4,%esp
801061ac:	50                   	push   %eax
801061ad:	68 5a 91 10 80       	push   $0x8010915a
801061b2:	ff 75 f0             	pushl  -0x10(%ebp)
801061b5:	e8 2a c2 ff ff       	call   801023e4 <dirlink>
801061ba:	83 c4 10             	add    $0x10,%esp
801061bd:	85 c0                	test   %eax,%eax
801061bf:	79 0d                	jns    801061ce <create+0x197>
      panic("create dots");
801061c1:	83 ec 0c             	sub    $0xc,%esp
801061c4:	68 8d 91 10 80       	push   $0x8010918d
801061c9:	e8 3a a4 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	8b 40 04             	mov    0x4(%eax),%eax
801061d4:	83 ec 04             	sub    $0x4,%esp
801061d7:	50                   	push   %eax
801061d8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061db:	50                   	push   %eax
801061dc:	ff 75 f4             	pushl  -0xc(%ebp)
801061df:	e8 00 c2 ff ff       	call   801023e4 <dirlink>
801061e4:	83 c4 10             	add    $0x10,%esp
801061e7:	85 c0                	test   %eax,%eax
801061e9:	79 0d                	jns    801061f8 <create+0x1c1>
    panic("create: dirlink");
801061eb:	83 ec 0c             	sub    $0xc,%esp
801061ee:	68 99 91 10 80       	push   $0x80109199
801061f3:	e8 10 a4 ff ff       	call   80100608 <panic>

  iunlockput(dp);
801061f8:	83 ec 0c             	sub    $0xc,%esp
801061fb:	ff 75 f4             	pushl  -0xc(%ebp)
801061fe:	e8 56 bb ff ff       	call   80101d59 <iunlockput>
80106203:	83 c4 10             	add    $0x10,%esp

  return ip;
80106206:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106209:	c9                   	leave  
8010620a:	c3                   	ret    

8010620b <sys_open>:

int
sys_open(void)
{
8010620b:	f3 0f 1e fb          	endbr32 
8010620f:	55                   	push   %ebp
80106210:	89 e5                	mov    %esp,%ebp
80106212:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106215:	83 ec 08             	sub    $0x8,%esp
80106218:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010621b:	50                   	push   %eax
8010621c:	6a 00                	push   $0x0
8010621e:	e8 b4 f6 ff ff       	call   801058d7 <argstr>
80106223:	83 c4 10             	add    $0x10,%esp
80106226:	85 c0                	test   %eax,%eax
80106228:	78 15                	js     8010623f <sys_open+0x34>
8010622a:	83 ec 08             	sub    $0x8,%esp
8010622d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106230:	50                   	push   %eax
80106231:	6a 01                	push   $0x1
80106233:	e8 02 f6 ff ff       	call   8010583a <argint>
80106238:	83 c4 10             	add    $0x10,%esp
8010623b:	85 c0                	test   %eax,%eax
8010623d:	79 0a                	jns    80106249 <sys_open+0x3e>
    return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	e9 61 01 00 00       	jmp    801063aa <sys_open+0x19f>

  begin_op();
80106249:	e8 9d d4 ff ff       	call   801036eb <begin_op>

  if(omode & O_CREATE){
8010624e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106251:	25 00 02 00 00       	and    $0x200,%eax
80106256:	85 c0                	test   %eax,%eax
80106258:	74 2a                	je     80106284 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
8010625a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010625d:	6a 00                	push   $0x0
8010625f:	6a 00                	push   $0x0
80106261:	6a 02                	push   $0x2
80106263:	50                   	push   %eax
80106264:	e8 ce fd ff ff       	call   80106037 <create>
80106269:	83 c4 10             	add    $0x10,%esp
8010626c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010626f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106273:	75 75                	jne    801062ea <sys_open+0xdf>
      end_op();
80106275:	e8 01 d5 ff ff       	call   8010377b <end_op>
      return -1;
8010627a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627f:	e9 26 01 00 00       	jmp    801063aa <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106284:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106287:	83 ec 0c             	sub    $0xc,%esp
8010628a:	50                   	push   %eax
8010628b:	e8 f7 c3 ff ff       	call   80102687 <namei>
80106290:	83 c4 10             	add    $0x10,%esp
80106293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106296:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629a:	75 0f                	jne    801062ab <sys_open+0xa0>
      end_op();
8010629c:	e8 da d4 ff ff       	call   8010377b <end_op>
      return -1;
801062a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a6:	e9 ff 00 00 00       	jmp    801063aa <sys_open+0x19f>
    }
    ilock(ip);
801062ab:	83 ec 0c             	sub    $0xc,%esp
801062ae:	ff 75 f4             	pushl  -0xc(%ebp)
801062b1:	e8 66 b8 ff ff       	call   80101b1c <ilock>
801062b6:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801062b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801062c0:	66 83 f8 01          	cmp    $0x1,%ax
801062c4:	75 24                	jne    801062ea <sys_open+0xdf>
801062c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c9:	85 c0                	test   %eax,%eax
801062cb:	74 1d                	je     801062ea <sys_open+0xdf>
      iunlockput(ip);
801062cd:	83 ec 0c             	sub    $0xc,%esp
801062d0:	ff 75 f4             	pushl  -0xc(%ebp)
801062d3:	e8 81 ba ff ff       	call   80101d59 <iunlockput>
801062d8:	83 c4 10             	add    $0x10,%esp
      end_op();
801062db:	e8 9b d4 ff ff       	call   8010377b <end_op>
      return -1;
801062e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e5:	e9 c0 00 00 00       	jmp    801063aa <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062ea:	e8 e7 ad ff ff       	call   801010d6 <filealloc>
801062ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062f6:	74 17                	je     8010630f <sys_open+0x104>
801062f8:	83 ec 0c             	sub    $0xc,%esp
801062fb:	ff 75 f0             	pushl  -0x10(%ebp)
801062fe:	e8 09 f7 ff ff       	call   80105a0c <fdalloc>
80106303:	83 c4 10             	add    $0x10,%esp
80106306:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106309:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010630d:	79 2e                	jns    8010633d <sys_open+0x132>
    if(f)
8010630f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106313:	74 0e                	je     80106323 <sys_open+0x118>
      fileclose(f);
80106315:	83 ec 0c             	sub    $0xc,%esp
80106318:	ff 75 f0             	pushl  -0x10(%ebp)
8010631b:	e8 7c ae ff ff       	call   8010119c <fileclose>
80106320:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106323:	83 ec 0c             	sub    $0xc,%esp
80106326:	ff 75 f4             	pushl  -0xc(%ebp)
80106329:	e8 2b ba ff ff       	call   80101d59 <iunlockput>
8010632e:	83 c4 10             	add    $0x10,%esp
    end_op();
80106331:	e8 45 d4 ff ff       	call   8010377b <end_op>
    return -1;
80106336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633b:	eb 6d                	jmp    801063aa <sys_open+0x19f>
  }
  iunlock(ip);
8010633d:	83 ec 0c             	sub    $0xc,%esp
80106340:	ff 75 f4             	pushl  -0xc(%ebp)
80106343:	e8 eb b8 ff ff       	call   80101c33 <iunlock>
80106348:	83 c4 10             	add    $0x10,%esp
  end_op();
8010634b:	e8 2b d4 ff ff       	call   8010377b <end_op>

  f->type = FD_INODE;
80106350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106353:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010635c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010635f:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106365:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010636c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010636f:	83 e0 01             	and    $0x1,%eax
80106372:	85 c0                	test   %eax,%eax
80106374:	0f 94 c0             	sete   %al
80106377:	89 c2                	mov    %eax,%edx
80106379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637c:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010637f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106382:	83 e0 01             	and    $0x1,%eax
80106385:	85 c0                	test   %eax,%eax
80106387:	75 0a                	jne    80106393 <sys_open+0x188>
80106389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010638c:	83 e0 02             	and    $0x2,%eax
8010638f:	85 c0                	test   %eax,%eax
80106391:	74 07                	je     8010639a <sys_open+0x18f>
80106393:	b8 01 00 00 00       	mov    $0x1,%eax
80106398:	eb 05                	jmp    8010639f <sys_open+0x194>
8010639a:	b8 00 00 00 00       	mov    $0x0,%eax
8010639f:	89 c2                	mov    %eax,%edx
801063a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a4:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801063a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063aa:	c9                   	leave  
801063ab:	c3                   	ret    

801063ac <sys_mkdir>:

int
sys_mkdir(void)
{
801063ac:	f3 0f 1e fb          	endbr32 
801063b0:	55                   	push   %ebp
801063b1:	89 e5                	mov    %esp,%ebp
801063b3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063b6:	e8 30 d3 ff ff       	call   801036eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063bb:	83 ec 08             	sub    $0x8,%esp
801063be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063c1:	50                   	push   %eax
801063c2:	6a 00                	push   $0x0
801063c4:	e8 0e f5 ff ff       	call   801058d7 <argstr>
801063c9:	83 c4 10             	add    $0x10,%esp
801063cc:	85 c0                	test   %eax,%eax
801063ce:	78 1b                	js     801063eb <sys_mkdir+0x3f>
801063d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d3:	6a 00                	push   $0x0
801063d5:	6a 00                	push   $0x0
801063d7:	6a 01                	push   $0x1
801063d9:	50                   	push   %eax
801063da:	e8 58 fc ff ff       	call   80106037 <create>
801063df:	83 c4 10             	add    $0x10,%esp
801063e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063e9:	75 0c                	jne    801063f7 <sys_mkdir+0x4b>
    end_op();
801063eb:	e8 8b d3 ff ff       	call   8010377b <end_op>
    return -1;
801063f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f5:	eb 18                	jmp    8010640f <sys_mkdir+0x63>
  }
  iunlockput(ip);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	ff 75 f4             	pushl  -0xc(%ebp)
801063fd:	e8 57 b9 ff ff       	call   80101d59 <iunlockput>
80106402:	83 c4 10             	add    $0x10,%esp
  end_op();
80106405:	e8 71 d3 ff ff       	call   8010377b <end_op>
  return 0;
8010640a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640f:	c9                   	leave  
80106410:	c3                   	ret    

80106411 <sys_mknod>:

int
sys_mknod(void)
{
80106411:	f3 0f 1e fb          	endbr32 
80106415:	55                   	push   %ebp
80106416:	89 e5                	mov    %esp,%ebp
80106418:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010641b:	e8 cb d2 ff ff       	call   801036eb <begin_op>
  if((argstr(0, &path)) < 0 ||
80106420:	83 ec 08             	sub    $0x8,%esp
80106423:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106426:	50                   	push   %eax
80106427:	6a 00                	push   $0x0
80106429:	e8 a9 f4 ff ff       	call   801058d7 <argstr>
8010642e:	83 c4 10             	add    $0x10,%esp
80106431:	85 c0                	test   %eax,%eax
80106433:	78 4f                	js     80106484 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106435:	83 ec 08             	sub    $0x8,%esp
80106438:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010643b:	50                   	push   %eax
8010643c:	6a 01                	push   $0x1
8010643e:	e8 f7 f3 ff ff       	call   8010583a <argint>
80106443:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106446:	85 c0                	test   %eax,%eax
80106448:	78 3a                	js     80106484 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
8010644a:	83 ec 08             	sub    $0x8,%esp
8010644d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106450:	50                   	push   %eax
80106451:	6a 02                	push   $0x2
80106453:	e8 e2 f3 ff ff       	call   8010583a <argint>
80106458:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010645b:	85 c0                	test   %eax,%eax
8010645d:	78 25                	js     80106484 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010645f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106462:	0f bf c8             	movswl %ax,%ecx
80106465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106468:	0f bf d0             	movswl %ax,%edx
8010646b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646e:	51                   	push   %ecx
8010646f:	52                   	push   %edx
80106470:	6a 03                	push   $0x3
80106472:	50                   	push   %eax
80106473:	e8 bf fb ff ff       	call   80106037 <create>
80106478:	83 c4 10             	add    $0x10,%esp
8010647b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010647e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106482:	75 0c                	jne    80106490 <sys_mknod+0x7f>
    end_op();
80106484:	e8 f2 d2 ff ff       	call   8010377b <end_op>
    return -1;
80106489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648e:	eb 18                	jmp    801064a8 <sys_mknod+0x97>
  }
  iunlockput(ip);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	ff 75 f4             	pushl  -0xc(%ebp)
80106496:	e8 be b8 ff ff       	call   80101d59 <iunlockput>
8010649b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010649e:	e8 d8 d2 ff ff       	call   8010377b <end_op>
  return 0;
801064a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a8:	c9                   	leave  
801064a9:	c3                   	ret    

801064aa <sys_chdir>:

int
sys_chdir(void)
{
801064aa:	f3 0f 1e fb          	endbr32 
801064ae:	55                   	push   %ebp
801064af:	89 e5                	mov    %esp,%ebp
801064b1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801064b4:	e8 f1 df ff ff       	call   801044aa <myproc>
801064b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801064bc:	e8 2a d2 ff ff       	call   801036eb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064c1:	83 ec 08             	sub    $0x8,%esp
801064c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064c7:	50                   	push   %eax
801064c8:	6a 00                	push   $0x0
801064ca:	e8 08 f4 ff ff       	call   801058d7 <argstr>
801064cf:	83 c4 10             	add    $0x10,%esp
801064d2:	85 c0                	test   %eax,%eax
801064d4:	78 18                	js     801064ee <sys_chdir+0x44>
801064d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064d9:	83 ec 0c             	sub    $0xc,%esp
801064dc:	50                   	push   %eax
801064dd:	e8 a5 c1 ff ff       	call   80102687 <namei>
801064e2:	83 c4 10             	add    $0x10,%esp
801064e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ec:	75 0c                	jne    801064fa <sys_chdir+0x50>
    end_op();
801064ee:	e8 88 d2 ff ff       	call   8010377b <end_op>
    return -1;
801064f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f8:	eb 68                	jmp    80106562 <sys_chdir+0xb8>
  }
  ilock(ip);
801064fa:	83 ec 0c             	sub    $0xc,%esp
801064fd:	ff 75 f0             	pushl  -0x10(%ebp)
80106500:	e8 17 b6 ff ff       	call   80101b1c <ilock>
80106505:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010650f:	66 83 f8 01          	cmp    $0x1,%ax
80106513:	74 1a                	je     8010652f <sys_chdir+0x85>
    iunlockput(ip);
80106515:	83 ec 0c             	sub    $0xc,%esp
80106518:	ff 75 f0             	pushl  -0x10(%ebp)
8010651b:	e8 39 b8 ff ff       	call   80101d59 <iunlockput>
80106520:	83 c4 10             	add    $0x10,%esp
    end_op();
80106523:	e8 53 d2 ff ff       	call   8010377b <end_op>
    return -1;
80106528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652d:	eb 33                	jmp    80106562 <sys_chdir+0xb8>
  }
  iunlock(ip);
8010652f:	83 ec 0c             	sub    $0xc,%esp
80106532:	ff 75 f0             	pushl  -0x10(%ebp)
80106535:	e8 f9 b6 ff ff       	call   80101c33 <iunlock>
8010653a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010653d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106540:	8b 40 68             	mov    0x68(%eax),%eax
80106543:	83 ec 0c             	sub    $0xc,%esp
80106546:	50                   	push   %eax
80106547:	e8 39 b7 ff ff       	call   80101c85 <iput>
8010654c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010654f:	e8 27 d2 ff ff       	call   8010377b <end_op>
  curproc->cwd = ip;
80106554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106557:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010655a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010655d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106562:	c9                   	leave  
80106563:	c3                   	ret    

80106564 <sys_exec>:

int
sys_exec(void)
{
80106564:	f3 0f 1e fb          	endbr32 
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106571:	83 ec 08             	sub    $0x8,%esp
80106574:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106577:	50                   	push   %eax
80106578:	6a 00                	push   $0x0
8010657a:	e8 58 f3 ff ff       	call   801058d7 <argstr>
8010657f:	83 c4 10             	add    $0x10,%esp
80106582:	85 c0                	test   %eax,%eax
80106584:	78 18                	js     8010659e <sys_exec+0x3a>
80106586:	83 ec 08             	sub    $0x8,%esp
80106589:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010658f:	50                   	push   %eax
80106590:	6a 01                	push   $0x1
80106592:	e8 a3 f2 ff ff       	call   8010583a <argint>
80106597:	83 c4 10             	add    $0x10,%esp
8010659a:	85 c0                	test   %eax,%eax
8010659c:	79 0a                	jns    801065a8 <sys_exec+0x44>
    return -1;
8010659e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a3:	e9 c6 00 00 00       	jmp    8010666e <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801065a8:	83 ec 04             	sub    $0x4,%esp
801065ab:	68 80 00 00 00       	push   $0x80
801065b0:	6a 00                	push   $0x0
801065b2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065b8:	50                   	push   %eax
801065b9:	e8 28 ef ff ff       	call   801054e6 <memset>
801065be:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801065c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cb:	83 f8 1f             	cmp    $0x1f,%eax
801065ce:	76 0a                	jbe    801065da <sys_exec+0x76>
      return -1;
801065d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d5:	e9 94 00 00 00       	jmp    8010666e <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065dd:	c1 e0 02             	shl    $0x2,%eax
801065e0:	89 c2                	mov    %eax,%edx
801065e2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065e8:	01 c2                	add    %eax,%edx
801065ea:	83 ec 08             	sub    $0x8,%esp
801065ed:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065f3:	50                   	push   %eax
801065f4:	52                   	push   %edx
801065f5:	e8 95 f1 ff ff       	call   8010578f <fetchint>
801065fa:	83 c4 10             	add    $0x10,%esp
801065fd:	85 c0                	test   %eax,%eax
801065ff:	79 07                	jns    80106608 <sys_exec+0xa4>
      return -1;
80106601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106606:	eb 66                	jmp    8010666e <sys_exec+0x10a>
    if(uarg == 0){
80106608:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010660e:	85 c0                	test   %eax,%eax
80106610:	75 27                	jne    80106639 <sys_exec+0xd5>
      argv[i] = 0;
80106612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106615:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010661c:	00 00 00 00 
      break;
80106620:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106624:	83 ec 08             	sub    $0x8,%esp
80106627:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010662d:	52                   	push   %edx
8010662e:	50                   	push   %eax
8010662f:	e8 fc a5 ff ff       	call   80100c30 <exec>
80106634:	83 c4 10             	add    $0x10,%esp
80106637:	eb 35                	jmp    8010666e <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106639:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010663f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106642:	c1 e2 02             	shl    $0x2,%edx
80106645:	01 c2                	add    %eax,%edx
80106647:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010664d:	83 ec 08             	sub    $0x8,%esp
80106650:	52                   	push   %edx
80106651:	50                   	push   %eax
80106652:	e8 7b f1 ff ff       	call   801057d2 <fetchstr>
80106657:	83 c4 10             	add    $0x10,%esp
8010665a:	85 c0                	test   %eax,%eax
8010665c:	79 07                	jns    80106665 <sys_exec+0x101>
      return -1;
8010665e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106663:	eb 09                	jmp    8010666e <sys_exec+0x10a>
  for(i=0;; i++){
80106665:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106669:	e9 5a ff ff ff       	jmp    801065c8 <sys_exec+0x64>
}
8010666e:	c9                   	leave  
8010666f:	c3                   	ret    

80106670 <sys_pipe>:

int
sys_pipe(void)
{
80106670:	f3 0f 1e fb          	endbr32 
80106674:	55                   	push   %ebp
80106675:	89 e5                	mov    %esp,%ebp
80106677:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010667a:	83 ec 04             	sub    $0x4,%esp
8010667d:	6a 08                	push   $0x8
8010667f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106682:	50                   	push   %eax
80106683:	6a 00                	push   $0x0
80106685:	e8 e1 f1 ff ff       	call   8010586b <argptr>
8010668a:	83 c4 10             	add    $0x10,%esp
8010668d:	85 c0                	test   %eax,%eax
8010668f:	79 0a                	jns    8010669b <sys_pipe+0x2b>
    return -1;
80106691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106696:	e9 ae 00 00 00       	jmp    80106749 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010669b:	83 ec 08             	sub    $0x8,%esp
8010669e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066a1:	50                   	push   %eax
801066a2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066a5:	50                   	push   %eax
801066a6:	e8 20 d9 ff ff       	call   80103fcb <pipealloc>
801066ab:	83 c4 10             	add    $0x10,%esp
801066ae:	85 c0                	test   %eax,%eax
801066b0:	79 0a                	jns    801066bc <sys_pipe+0x4c>
    return -1;
801066b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b7:	e9 8d 00 00 00       	jmp    80106749 <sys_pipe+0xd9>
  fd0 = -1;
801066bc:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066c6:	83 ec 0c             	sub    $0xc,%esp
801066c9:	50                   	push   %eax
801066ca:	e8 3d f3 ff ff       	call   80105a0c <fdalloc>
801066cf:	83 c4 10             	add    $0x10,%esp
801066d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066d9:	78 18                	js     801066f3 <sys_pipe+0x83>
801066db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066de:	83 ec 0c             	sub    $0xc,%esp
801066e1:	50                   	push   %eax
801066e2:	e8 25 f3 ff ff       	call   80105a0c <fdalloc>
801066e7:	83 c4 10             	add    $0x10,%esp
801066ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f1:	79 3e                	jns    80106731 <sys_pipe+0xc1>
    if(fd0 >= 0)
801066f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066f7:	78 13                	js     8010670c <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801066f9:	e8 ac dd ff ff       	call   801044aa <myproc>
801066fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106701:	83 c2 08             	add    $0x8,%edx
80106704:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010670b:	00 
    fileclose(rf);
8010670c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010670f:	83 ec 0c             	sub    $0xc,%esp
80106712:	50                   	push   %eax
80106713:	e8 84 aa ff ff       	call   8010119c <fileclose>
80106718:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010671b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010671e:	83 ec 0c             	sub    $0xc,%esp
80106721:	50                   	push   %eax
80106722:	e8 75 aa ff ff       	call   8010119c <fileclose>
80106727:	83 c4 10             	add    $0x10,%esp
    return -1;
8010672a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672f:	eb 18                	jmp    80106749 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106731:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106734:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106737:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106739:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010673c:	8d 50 04             	lea    0x4(%eax),%edx
8010673f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106742:	89 02                	mov    %eax,(%edx)
  return 0;
80106744:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106749:	c9                   	leave  
8010674a:	c3                   	ret    

8010674b <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010674b:	f3 0f 1e fb          	endbr32 
8010674f:	55                   	push   %ebp
80106750:	89 e5                	mov    %esp,%ebp
80106752:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106755:	e8 be e0 ff ff       	call   80104818 <fork>
}
8010675a:	c9                   	leave  
8010675b:	c3                   	ret    

8010675c <sys_exit>:

int
sys_exit(void)
{
8010675c:	f3 0f 1e fb          	endbr32 
80106760:	55                   	push   %ebp
80106761:	89 e5                	mov    %esp,%ebp
80106763:	83 ec 08             	sub    $0x8,%esp
  exit();
80106766:	e8 2a e2 ff ff       	call   80104995 <exit>
  return 0;  // not reached
8010676b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106770:	c9                   	leave  
80106771:	c3                   	ret    

80106772 <sys_wait>:

int
sys_wait(void)
{
80106772:	f3 0f 1e fb          	endbr32 
80106776:	55                   	push   %ebp
80106777:	89 e5                	mov    %esp,%ebp
80106779:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010677c:	e8 38 e3 ff ff       	call   80104ab9 <wait>
}
80106781:	c9                   	leave  
80106782:	c3                   	ret    

80106783 <sys_kill>:

int
sys_kill(void)
{
80106783:	f3 0f 1e fb          	endbr32 
80106787:	55                   	push   %ebp
80106788:	89 e5                	mov    %esp,%ebp
8010678a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010678d:	83 ec 08             	sub    $0x8,%esp
80106790:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106793:	50                   	push   %eax
80106794:	6a 00                	push   $0x0
80106796:	e8 9f f0 ff ff       	call   8010583a <argint>
8010679b:	83 c4 10             	add    $0x10,%esp
8010679e:	85 c0                	test   %eax,%eax
801067a0:	79 07                	jns    801067a9 <sys_kill+0x26>
    return -1;
801067a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a7:	eb 0f                	jmp    801067b8 <sys_kill+0x35>
  return kill(pid);
801067a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ac:	83 ec 0c             	sub    $0xc,%esp
801067af:	50                   	push   %eax
801067b0:	e8 53 e7 ff ff       	call   80104f08 <kill>
801067b5:	83 c4 10             	add    $0x10,%esp
}
801067b8:	c9                   	leave  
801067b9:	c3                   	ret    

801067ba <sys_getpid>:

int
sys_getpid(void)
{
801067ba:	f3 0f 1e fb          	endbr32 
801067be:	55                   	push   %ebp
801067bf:	89 e5                	mov    %esp,%ebp
801067c1:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801067c4:	e8 e1 dc ff ff       	call   801044aa <myproc>
801067c9:	8b 40 10             	mov    0x10(%eax),%eax
}
801067cc:	c9                   	leave  
801067cd:	c3                   	ret    

801067ce <sys_sbrk>:

int
sys_sbrk(void)
{
801067ce:	f3 0f 1e fb          	endbr32 
801067d2:	55                   	push   %ebp
801067d3:	89 e5                	mov    %esp,%ebp
801067d5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801067d8:	83 ec 08             	sub    $0x8,%esp
801067db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067de:	50                   	push   %eax
801067df:	6a 00                	push   $0x0
801067e1:	e8 54 f0 ff ff       	call   8010583a <argint>
801067e6:	83 c4 10             	add    $0x10,%esp
801067e9:	85 c0                	test   %eax,%eax
801067eb:	79 07                	jns    801067f4 <sys_sbrk+0x26>
    return -1;
801067ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f2:	eb 27                	jmp    8010681b <sys_sbrk+0x4d>
  addr = myproc()->sz;
801067f4:	e8 b1 dc ff ff       	call   801044aa <myproc>
801067f9:	8b 00                	mov    (%eax),%eax
801067fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106801:	83 ec 0c             	sub    $0xc,%esp
80106804:	50                   	push   %eax
80106805:	e8 14 df ff ff       	call   8010471e <growproc>
8010680a:	83 c4 10             	add    $0x10,%esp
8010680d:	85 c0                	test   %eax,%eax
8010680f:	79 07                	jns    80106818 <sys_sbrk+0x4a>
    return -1;
80106811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106816:	eb 03                	jmp    8010681b <sys_sbrk+0x4d>
  return addr;
80106818:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010681b:	c9                   	leave  
8010681c:	c3                   	ret    

8010681d <sys_sleep>:

int
sys_sleep(void)
{
8010681d:	f3 0f 1e fb          	endbr32 
80106821:	55                   	push   %ebp
80106822:	89 e5                	mov    %esp,%ebp
80106824:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106827:	83 ec 08             	sub    $0x8,%esp
8010682a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010682d:	50                   	push   %eax
8010682e:	6a 00                	push   $0x0
80106830:	e8 05 f0 ff ff       	call   8010583a <argint>
80106835:	83 c4 10             	add    $0x10,%esp
80106838:	85 c0                	test   %eax,%eax
8010683a:	79 07                	jns    80106843 <sys_sleep+0x26>
    return -1;
8010683c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106841:	eb 76                	jmp    801068b9 <sys_sleep+0x9c>
  acquire(&tickslock);
80106843:	83 ec 0c             	sub    $0xc,%esp
80106846:	68 00 6d 11 80       	push   $0x80116d00
8010684b:	e8 f7 e9 ff ff       	call   80105247 <acquire>
80106850:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106853:	a1 40 75 11 80       	mov    0x80117540,%eax
80106858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010685b:	eb 38                	jmp    80106895 <sys_sleep+0x78>
    if(myproc()->killed){
8010685d:	e8 48 dc ff ff       	call   801044aa <myproc>
80106862:	8b 40 24             	mov    0x24(%eax),%eax
80106865:	85 c0                	test   %eax,%eax
80106867:	74 17                	je     80106880 <sys_sleep+0x63>
      release(&tickslock);
80106869:	83 ec 0c             	sub    $0xc,%esp
8010686c:	68 00 6d 11 80       	push   $0x80116d00
80106871:	e8 43 ea ff ff       	call   801052b9 <release>
80106876:	83 c4 10             	add    $0x10,%esp
      return -1;
80106879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687e:	eb 39                	jmp    801068b9 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106880:	83 ec 08             	sub    $0x8,%esp
80106883:	68 00 6d 11 80       	push   $0x80116d00
80106888:	68 40 75 11 80       	push   $0x80117540
8010688d:	e8 4c e5 ff ff       	call   80104dde <sleep>
80106892:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106895:	a1 40 75 11 80       	mov    0x80117540,%eax
8010689a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010689d:	8b 55 f0             	mov    -0x10(%ebp),%edx
801068a0:	39 d0                	cmp    %edx,%eax
801068a2:	72 b9                	jb     8010685d <sys_sleep+0x40>
  }
  release(&tickslock);
801068a4:	83 ec 0c             	sub    $0xc,%esp
801068a7:	68 00 6d 11 80       	push   $0x80116d00
801068ac:	e8 08 ea ff ff       	call   801052b9 <release>
801068b1:	83 c4 10             	add    $0x10,%esp
  return 0;
801068b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068b9:	c9                   	leave  
801068ba:	c3                   	ret    

801068bb <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801068bb:	f3 0f 1e fb          	endbr32 
801068bf:	55                   	push   %ebp
801068c0:	89 e5                	mov    %esp,%ebp
801068c2:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801068c5:	83 ec 0c             	sub    $0xc,%esp
801068c8:	68 00 6d 11 80       	push   $0x80116d00
801068cd:	e8 75 e9 ff ff       	call   80105247 <acquire>
801068d2:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801068d5:	a1 40 75 11 80       	mov    0x80117540,%eax
801068da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801068dd:	83 ec 0c             	sub    $0xc,%esp
801068e0:	68 00 6d 11 80       	push   $0x80116d00
801068e5:	e8 cf e9 ff ff       	call   801052b9 <release>
801068ea:	83 c4 10             	add    $0x10,%esp
  return xticks;
801068ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068f0:	c9                   	leave  
801068f1:	c3                   	ret    

801068f2 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
801068f2:	f3 0f 1e fb          	endbr32 
801068f6:	55                   	push   %ebp
801068f7:	89 e5                	mov    %esp,%ebp
801068f9:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
801068fc:	83 ec 08             	sub    $0x8,%esp
801068ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106902:	50                   	push   %eax
80106903:	6a 01                	push   $0x1
80106905:	e8 30 ef ff ff       	call   8010583a <argint>
8010690a:	83 c4 10             	add    $0x10,%esp
8010690d:	85 c0                	test   %eax,%eax
8010690f:	79 07                	jns    80106918 <sys_mencrypt+0x26>
    return -1;
80106911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106916:	eb 5e                	jmp    80106976 <sys_mencrypt+0x84>
  if (len == 0) {
80106918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691b:	85 c0                	test   %eax,%eax
8010691d:	75 07                	jne    80106926 <sys_mencrypt+0x34>
    return 0;
8010691f:	b8 00 00 00 00       	mov    $0x0,%eax
80106924:	eb 50                	jmp    80106976 <sys_mencrypt+0x84>
  }
  if (len < 0) {
80106926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106929:	85 c0                	test   %eax,%eax
8010692b:	79 07                	jns    80106934 <sys_mencrypt+0x42>
    return -1;
8010692d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106932:	eb 42                	jmp    80106976 <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
80106934:	83 ec 04             	sub    $0x4,%esp
80106937:	6a 01                	push   $0x1
80106939:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010693c:	50                   	push   %eax
8010693d:	6a 00                	push   $0x0
8010693f:	e8 27 ef ff ff       	call   8010586b <argptr>
80106944:	83 c4 10             	add    $0x10,%esp
80106947:	85 c0                	test   %eax,%eax
80106949:	79 07                	jns    80106952 <sys_mencrypt+0x60>
    return -1;
8010694b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106950:	eb 24                	jmp    80106976 <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
80106952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106955:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010695a:	76 07                	jbe    80106963 <sys_mencrypt+0x71>
    return -1;
8010695c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106961:	eb 13                	jmp    80106976 <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
80106963:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106969:	83 ec 08             	sub    $0x8,%esp
8010696c:	52                   	push   %edx
8010696d:	50                   	push   %eax
8010696e:	e8 c4 1f 00 00       	call   80108937 <mencrypt>
80106973:	83 c4 10             	add    $0x10,%esp
}
80106976:	c9                   	leave  
80106977:	c3                   	ret    

80106978 <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
80106978:	f3 0f 1e fb          	endbr32 
8010697c:	55                   	push   %ebp
8010697d:	89 e5                	mov    %esp,%ebp
8010697f:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;

  if(argint(1, &num) < 0)
80106982:	83 ec 08             	sub    $0x8,%esp
80106985:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106988:	50                   	push   %eax
80106989:	6a 01                	push   $0x1
8010698b:	e8 aa ee ff ff       	call   8010583a <argint>
80106990:	83 c4 10             	add    $0x10,%esp
80106993:	85 c0                	test   %eax,%eax
80106995:	79 07                	jns    8010699e <sys_getpgtable+0x26>

    return -1;
80106997:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699c:	eb 36                	jmp    801069d4 <sys_getpgtable+0x5c>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
8010699e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a1:	c1 e0 03             	shl    $0x3,%eax
801069a4:	83 ec 04             	sub    $0x4,%esp
801069a7:	50                   	push   %eax
801069a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069ab:	50                   	push   %eax
801069ac:	6a 00                	push   $0x0
801069ae:	e8 b8 ee ff ff       	call   8010586b <argptr>
801069b3:	83 c4 10             	add    $0x10,%esp
801069b6:	85 c0                	test   %eax,%eax
801069b8:	79 07                	jns    801069c1 <sys_getpgtable+0x49>
    return -1;
801069ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bf:	eb 13                	jmp    801069d4 <sys_getpgtable+0x5c>
  }
  return getpgtable(entries, num);
801069c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c7:	83 ec 08             	sub    $0x8,%esp
801069ca:	52                   	push   %edx
801069cb:	50                   	push   %eax
801069cc:	e8 89 20 00 00       	call   80108a5a <getpgtable>
801069d1:	83 c4 10             	add    $0x10,%esp
}
801069d4:	c9                   	leave  
801069d5:	c3                   	ret    

801069d6 <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
801069d6:	f3 0f 1e fb          	endbr32 
801069da:	55                   	push   %ebp
801069db:	89 e5                	mov    %esp,%ebp
801069dd:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
801069e0:	83 ec 04             	sub    $0x4,%esp
801069e3:	68 00 10 00 00       	push   $0x1000
801069e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069eb:	50                   	push   %eax
801069ec:	6a 01                	push   $0x1
801069ee:	e8 78 ee ff ff       	call   8010586b <argptr>
801069f3:	83 c4 10             	add    $0x10,%esp
801069f6:	85 c0                	test   %eax,%eax
801069f8:	79 07                	jns    80106a01 <sys_dump_rawphymem+0x2b>
    return -1;
801069fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ff:	eb 2f                	jmp    80106a30 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106a01:	83 ec 08             	sub    $0x8,%esp
80106a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a07:	50                   	push   %eax
80106a08:	6a 00                	push   $0x0
80106a0a:	e8 2b ee ff ff       	call   8010583a <argint>
80106a0f:	83 c4 10             	add    $0x10,%esp
80106a12:	85 c0                	test   %eax,%eax
80106a14:	79 07                	jns    80106a1d <sys_dump_rawphymem+0x47>
    return -1;
80106a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1b:	eb 13                	jmp    80106a30 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106a1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a23:	83 ec 08             	sub    $0x8,%esp
80106a26:	52                   	push   %edx
80106a27:	50                   	push   %eax
80106a28:	e8 ce 21 00 00       	call   80108bfb <dump_rawphymem>
80106a2d:	83 c4 10             	add    $0x10,%esp
80106a30:	c9                   	leave  
80106a31:	c3                   	ret    

80106a32 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a32:	1e                   	push   %ds
  pushl %es
80106a33:	06                   	push   %es
  pushl %fs
80106a34:	0f a0                	push   %fs
  pushl %gs
80106a36:	0f a8                	push   %gs
  pushal
80106a38:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106a39:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a3d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a3f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a41:	54                   	push   %esp
  call trap
80106a42:	e8 df 01 00 00       	call   80106c26 <trap>
  addl $4, %esp
80106a47:	83 c4 04             	add    $0x4,%esp

80106a4a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a4a:	61                   	popa   
  popl %gs
80106a4b:	0f a9                	pop    %gs
  popl %fs
80106a4d:	0f a1                	pop    %fs
  popl %es
80106a4f:	07                   	pop    %es
  popl %ds
80106a50:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a51:	83 c4 08             	add    $0x8,%esp
  iret
80106a54:	cf                   	iret   

80106a55 <lidt>:
{
80106a55:	55                   	push   %ebp
80106a56:	89 e5                	mov    %esp,%ebp
80106a58:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a5e:	83 e8 01             	sub    $0x1,%eax
80106a61:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a65:	8b 45 08             	mov    0x8(%ebp),%eax
80106a68:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6f:	c1 e8 10             	shr    $0x10,%eax
80106a72:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106a76:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a79:	0f 01 18             	lidtl  (%eax)
}
80106a7c:	90                   	nop
80106a7d:	c9                   	leave  
80106a7e:	c3                   	ret    

80106a7f <rcr2>:

static inline uint
rcr2(void)
{
80106a7f:	55                   	push   %ebp
80106a80:	89 e5                	mov    %esp,%ebp
80106a82:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a85:	0f 20 d0             	mov    %cr2,%eax
80106a88:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a8e:	c9                   	leave  
80106a8f:	c3                   	ret    

80106a90 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a90:	f3 0f 1e fb          	endbr32 
80106a94:	55                   	push   %ebp
80106a95:	89 e5                	mov    %esp,%ebp
80106a97:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106a9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106aa1:	e9 c3 00 00 00       	jmp    80106b69 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa9:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106ab0:	89 c2                	mov    %eax,%edx
80106ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab5:	66 89 14 c5 40 6d 11 	mov    %dx,-0x7fee92c0(,%eax,8)
80106abc:	80 
80106abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac0:	66 c7 04 c5 42 6d 11 	movw   $0x8,-0x7fee92be(,%eax,8)
80106ac7:	80 08 00 
80106aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acd:	0f b6 14 c5 44 6d 11 	movzbl -0x7fee92bc(,%eax,8),%edx
80106ad4:	80 
80106ad5:	83 e2 e0             	and    $0xffffffe0,%edx
80106ad8:	88 14 c5 44 6d 11 80 	mov    %dl,-0x7fee92bc(,%eax,8)
80106adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae2:	0f b6 14 c5 44 6d 11 	movzbl -0x7fee92bc(,%eax,8),%edx
80106ae9:	80 
80106aea:	83 e2 1f             	and    $0x1f,%edx
80106aed:	88 14 c5 44 6d 11 80 	mov    %dl,-0x7fee92bc(,%eax,8)
80106af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af7:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106afe:	80 
80106aff:	83 e2 f0             	and    $0xfffffff0,%edx
80106b02:	83 ca 0e             	or     $0xe,%edx
80106b05:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0f:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b16:	80 
80106b17:	83 e2 ef             	and    $0xffffffef,%edx
80106b1a:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b24:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b2b:	80 
80106b2c:	83 e2 9f             	and    $0xffffff9f,%edx
80106b2f:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b39:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b40:	80 
80106b41:	83 ca 80             	or     $0xffffff80,%edx
80106b44:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4e:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b55:	c1 e8 10             	shr    $0x10,%eax
80106b58:	89 c2                	mov    %eax,%edx
80106b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5d:	66 89 14 c5 46 6d 11 	mov    %dx,-0x7fee92ba(,%eax,8)
80106b64:	80 
  for(i = 0; i < 256; i++)
80106b65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b69:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b70:	0f 8e 30 ff ff ff    	jle    80106aa6 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b76:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106b7b:	66 a3 40 6f 11 80    	mov    %ax,0x80116f40
80106b81:	66 c7 05 42 6f 11 80 	movw   $0x8,0x80116f42
80106b88:	08 00 
80106b8a:	0f b6 05 44 6f 11 80 	movzbl 0x80116f44,%eax
80106b91:	83 e0 e0             	and    $0xffffffe0,%eax
80106b94:	a2 44 6f 11 80       	mov    %al,0x80116f44
80106b99:	0f b6 05 44 6f 11 80 	movzbl 0x80116f44,%eax
80106ba0:	83 e0 1f             	and    $0x1f,%eax
80106ba3:	a2 44 6f 11 80       	mov    %al,0x80116f44
80106ba8:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106baf:	83 c8 0f             	or     $0xf,%eax
80106bb2:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bb7:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bbe:	83 e0 ef             	and    $0xffffffef,%eax
80106bc1:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bc6:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bcd:	83 c8 60             	or     $0x60,%eax
80106bd0:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bd5:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bdc:	83 c8 80             	or     $0xffffff80,%eax
80106bdf:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106be4:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106be9:	c1 e8 10             	shr    $0x10,%eax
80106bec:	66 a3 46 6f 11 80    	mov    %ax,0x80116f46

  initlock(&tickslock, "time");
80106bf2:	83 ec 08             	sub    $0x8,%esp
80106bf5:	68 ac 91 10 80       	push   $0x801091ac
80106bfa:	68 00 6d 11 80       	push   $0x80116d00
80106bff:	e8 1d e6 ff ff       	call   80105221 <initlock>
80106c04:	83 c4 10             	add    $0x10,%esp
}
80106c07:	90                   	nop
80106c08:	c9                   	leave  
80106c09:	c3                   	ret    

80106c0a <idtinit>:

void
idtinit(void)
{
80106c0a:	f3 0f 1e fb          	endbr32 
80106c0e:	55                   	push   %ebp
80106c0f:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c11:	68 00 08 00 00       	push   $0x800
80106c16:	68 40 6d 11 80       	push   $0x80116d40
80106c1b:	e8 35 fe ff ff       	call   80106a55 <lidt>
80106c20:	83 c4 08             	add    $0x8,%esp
}
80106c23:	90                   	nop
80106c24:	c9                   	leave  
80106c25:	c3                   	ret    

80106c26 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c26:	f3 0f 1e fb          	endbr32 
80106c2a:	55                   	push   %ebp
80106c2b:	89 e5                	mov    %esp,%ebp
80106c2d:	57                   	push   %edi
80106c2e:	56                   	push   %esi
80106c2f:	53                   	push   %ebx
80106c30:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106c33:	8b 45 08             	mov    0x8(%ebp),%eax
80106c36:	8b 40 30             	mov    0x30(%eax),%eax
80106c39:	83 f8 40             	cmp    $0x40,%eax
80106c3c:	75 3b                	jne    80106c79 <trap+0x53>
    if(myproc()->killed)
80106c3e:	e8 67 d8 ff ff       	call   801044aa <myproc>
80106c43:	8b 40 24             	mov    0x24(%eax),%eax
80106c46:	85 c0                	test   %eax,%eax
80106c48:	74 05                	je     80106c4f <trap+0x29>
      exit();
80106c4a:	e8 46 dd ff ff       	call   80104995 <exit>
    myproc()->tf = tf;
80106c4f:	e8 56 d8 ff ff       	call   801044aa <myproc>
80106c54:	8b 55 08             	mov    0x8(%ebp),%edx
80106c57:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c5a:	e8 b3 ec ff ff       	call   80105912 <syscall>
    if(myproc()->killed)
80106c5f:	e8 46 d8 ff ff       	call   801044aa <myproc>
80106c64:	8b 40 24             	mov    0x24(%eax),%eax
80106c67:	85 c0                	test   %eax,%eax
80106c69:	0f 84 28 02 00 00    	je     80106e97 <trap+0x271>
      exit();
80106c6f:	e8 21 dd ff ff       	call   80104995 <exit>
    return;
80106c74:	e9 1e 02 00 00       	jmp    80106e97 <trap+0x271>
  }
  char *addr;
  switch(tf->trapno){
80106c79:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7c:	8b 40 30             	mov    0x30(%eax),%eax
80106c7f:	83 e8 0e             	sub    $0xe,%eax
80106c82:	83 f8 31             	cmp    $0x31,%eax
80106c85:	0f 87 d4 00 00 00    	ja     80106d5f <trap+0x139>
80106c8b:	8b 04 85 54 92 10 80 	mov    -0x7fef6dac(,%eax,4),%eax
80106c92:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106c95:	e8 75 d7 ff ff       	call   8010440f <cpuid>
80106c9a:	85 c0                	test   %eax,%eax
80106c9c:	75 3d                	jne    80106cdb <trap+0xb5>
      acquire(&tickslock);
80106c9e:	83 ec 0c             	sub    $0xc,%esp
80106ca1:	68 00 6d 11 80       	push   $0x80116d00
80106ca6:	e8 9c e5 ff ff       	call   80105247 <acquire>
80106cab:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106cae:	a1 40 75 11 80       	mov    0x80117540,%eax
80106cb3:	83 c0 01             	add    $0x1,%eax
80106cb6:	a3 40 75 11 80       	mov    %eax,0x80117540
      wakeup(&ticks);
80106cbb:	83 ec 0c             	sub    $0xc,%esp
80106cbe:	68 40 75 11 80       	push   $0x80117540
80106cc3:	e8 05 e2 ff ff       	call   80104ecd <wakeup>
80106cc8:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106ccb:	83 ec 0c             	sub    $0xc,%esp
80106cce:	68 00 6d 11 80       	push   $0x80116d00
80106cd3:	e8 e1 e5 ff ff       	call   801052b9 <release>
80106cd8:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106cdb:	e8 bf c4 ff ff       	call   8010319f <lapiceoi>
    break;
80106ce0:	e9 32 01 00 00       	jmp    80106e17 <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106ce5:	e8 ea bc ff ff       	call   801029d4 <ideintr>
    lapiceoi();
80106cea:	e8 b0 c4 ff ff       	call   8010319f <lapiceoi>
    break;
80106cef:	e9 23 01 00 00       	jmp    80106e17 <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106cf4:	e8 dc c2 ff ff       	call   80102fd5 <kbdintr>
    lapiceoi();
80106cf9:	e8 a1 c4 ff ff       	call   8010319f <lapiceoi>
    break;
80106cfe:	e9 14 01 00 00       	jmp    80106e17 <trap+0x1f1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d03:	e8 71 03 00 00       	call   80107079 <uartintr>
    lapiceoi();
80106d08:	e8 92 c4 ff ff       	call   8010319f <lapiceoi>
    break;
80106d0d:	e9 05 01 00 00       	jmp    80106e17 <trap+0x1f1>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d12:	8b 45 08             	mov    0x8(%ebp),%eax
80106d15:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106d18:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d1f:	0f b7 d8             	movzwl %ax,%ebx
80106d22:	e8 e8 d6 ff ff       	call   8010440f <cpuid>
80106d27:	56                   	push   %esi
80106d28:	53                   	push   %ebx
80106d29:	50                   	push   %eax
80106d2a:	68 b4 91 10 80       	push   $0x801091b4
80106d2f:	e8 e4 96 ff ff       	call   80100418 <cprintf>
80106d34:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106d37:	e8 63 c4 ff ff       	call   8010319f <lapiceoi>
    break;
80106d3c:	e9 d6 00 00 00       	jmp    80106e17 <trap+0x1f1>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106d41:	e8 39 fd ff ff       	call   80106a7f <rcr2>
80106d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!mdecrypt(addr)) {
80106d49:	83 ec 0c             	sub    $0xc,%esp
80106d4c:	ff 75 e4             	pushl  -0x1c(%ebp)
80106d4f:	e8 3d 1b 00 00       	call   80108891 <mdecrypt>
80106d54:	83 c4 10             	add    $0x10,%esp
80106d57:	85 c0                	test   %eax,%eax
80106d59:	0f 84 b7 00 00 00    	je     80106e16 <trap+0x1f0>
      //default kills the process
      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106d5f:	e8 46 d7 ff ff       	call   801044aa <myproc>
80106d64:	85 c0                	test   %eax,%eax
80106d66:	74 11                	je     80106d79 <trap+0x153>
80106d68:	8b 45 08             	mov    0x8(%ebp),%eax
80106d6b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d6f:	0f b7 c0             	movzwl %ax,%eax
80106d72:	83 e0 03             	and    $0x3,%eax
80106d75:	85 c0                	test   %eax,%eax
80106d77:	75 39                	jne    80106db2 <trap+0x18c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d79:	e8 01 fd ff ff       	call   80106a7f <rcr2>
80106d7e:	89 c3                	mov    %eax,%ebx
80106d80:	8b 45 08             	mov    0x8(%ebp),%eax
80106d83:	8b 70 38             	mov    0x38(%eax),%esi
80106d86:	e8 84 d6 ff ff       	call   8010440f <cpuid>
80106d8b:	8b 55 08             	mov    0x8(%ebp),%edx
80106d8e:	8b 52 30             	mov    0x30(%edx),%edx
80106d91:	83 ec 0c             	sub    $0xc,%esp
80106d94:	53                   	push   %ebx
80106d95:	56                   	push   %esi
80106d96:	50                   	push   %eax
80106d97:	52                   	push   %edx
80106d98:	68 d8 91 10 80       	push   $0x801091d8
80106d9d:	e8 76 96 ff ff       	call   80100418 <cprintf>
80106da2:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106da5:	83 ec 0c             	sub    $0xc,%esp
80106da8:	68 0a 92 10 80       	push   $0x8010920a
80106dad:	e8 56 98 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106db2:	e8 c8 fc ff ff       	call   80106a7f <rcr2>
80106db7:	89 c6                	mov    %eax,%esi
80106db9:	8b 45 08             	mov    0x8(%ebp),%eax
80106dbc:	8b 40 38             	mov    0x38(%eax),%eax
80106dbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106dc2:	e8 48 d6 ff ff       	call   8010440f <cpuid>
80106dc7:	89 c3                	mov    %eax,%ebx
80106dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80106dcc:	8b 48 34             	mov    0x34(%eax),%ecx
80106dcf:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd5:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106dd8:	e8 cd d6 ff ff       	call   801044aa <myproc>
80106ddd:	8d 50 6c             	lea    0x6c(%eax),%edx
80106de0:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106de3:	e8 c2 d6 ff ff       	call   801044aa <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106de8:	8b 40 10             	mov    0x10(%eax),%eax
80106deb:	56                   	push   %esi
80106dec:	ff 75 d4             	pushl  -0x2c(%ebp)
80106def:	53                   	push   %ebx
80106df0:	ff 75 d0             	pushl  -0x30(%ebp)
80106df3:	57                   	push   %edi
80106df4:	ff 75 cc             	pushl  -0x34(%ebp)
80106df7:	50                   	push   %eax
80106df8:	68 10 92 10 80       	push   $0x80109210
80106dfd:	e8 16 96 ff ff       	call   80100418 <cprintf>
80106e02:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106e05:	e8 a0 d6 ff ff       	call   801044aa <myproc>
80106e0a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e11:	eb 04                	jmp    80106e17 <trap+0x1f1>
    break;
80106e13:	90                   	nop
80106e14:	eb 01                	jmp    80106e17 <trap+0x1f1>
      break;
80106e16:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e17:	e8 8e d6 ff ff       	call   801044aa <myproc>
80106e1c:	85 c0                	test   %eax,%eax
80106e1e:	74 23                	je     80106e43 <trap+0x21d>
80106e20:	e8 85 d6 ff ff       	call   801044aa <myproc>
80106e25:	8b 40 24             	mov    0x24(%eax),%eax
80106e28:	85 c0                	test   %eax,%eax
80106e2a:	74 17                	je     80106e43 <trap+0x21d>
80106e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e33:	0f b7 c0             	movzwl %ax,%eax
80106e36:	83 e0 03             	and    $0x3,%eax
80106e39:	83 f8 03             	cmp    $0x3,%eax
80106e3c:	75 05                	jne    80106e43 <trap+0x21d>
    exit();
80106e3e:	e8 52 db ff ff       	call   80104995 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106e43:	e8 62 d6 ff ff       	call   801044aa <myproc>
80106e48:	85 c0                	test   %eax,%eax
80106e4a:	74 1d                	je     80106e69 <trap+0x243>
80106e4c:	e8 59 d6 ff ff       	call   801044aa <myproc>
80106e51:	8b 40 0c             	mov    0xc(%eax),%eax
80106e54:	83 f8 04             	cmp    $0x4,%eax
80106e57:	75 10                	jne    80106e69 <trap+0x243>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106e59:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106e5f:	83 f8 20             	cmp    $0x20,%eax
80106e62:	75 05                	jne    80106e69 <trap+0x243>
    yield();
80106e64:	e8 ed de ff ff       	call   80104d56 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e69:	e8 3c d6 ff ff       	call   801044aa <myproc>
80106e6e:	85 c0                	test   %eax,%eax
80106e70:	74 26                	je     80106e98 <trap+0x272>
80106e72:	e8 33 d6 ff ff       	call   801044aa <myproc>
80106e77:	8b 40 24             	mov    0x24(%eax),%eax
80106e7a:	85 c0                	test   %eax,%eax
80106e7c:	74 1a                	je     80106e98 <trap+0x272>
80106e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e81:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e85:	0f b7 c0             	movzwl %ax,%eax
80106e88:	83 e0 03             	and    $0x3,%eax
80106e8b:	83 f8 03             	cmp    $0x3,%eax
80106e8e:	75 08                	jne    80106e98 <trap+0x272>
    exit();
80106e90:	e8 00 db ff ff       	call   80104995 <exit>
80106e95:	eb 01                	jmp    80106e98 <trap+0x272>
    return;
80106e97:	90                   	nop
}
80106e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e9b:	5b                   	pop    %ebx
80106e9c:	5e                   	pop    %esi
80106e9d:	5f                   	pop    %edi
80106e9e:	5d                   	pop    %ebp
80106e9f:	c3                   	ret    

80106ea0 <inb>:
{
80106ea0:	55                   	push   %ebp
80106ea1:	89 e5                	mov    %esp,%ebp
80106ea3:	83 ec 14             	sub    $0x14,%esp
80106ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ead:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106eb1:	89 c2                	mov    %eax,%edx
80106eb3:	ec                   	in     (%dx),%al
80106eb4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106eb7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ebb:	c9                   	leave  
80106ebc:	c3                   	ret    

80106ebd <outb>:
{
80106ebd:	55                   	push   %ebp
80106ebe:	89 e5                	mov    %esp,%ebp
80106ec0:	83 ec 08             	sub    $0x8,%esp
80106ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ec9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106ecd:	89 d0                	mov    %edx,%eax
80106ecf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ed2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ed6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106eda:	ee                   	out    %al,(%dx)
}
80106edb:	90                   	nop
80106edc:	c9                   	leave  
80106edd:	c3                   	ret    

80106ede <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ede:	f3 0f 1e fb          	endbr32 
80106ee2:	55                   	push   %ebp
80106ee3:	89 e5                	mov    %esp,%ebp
80106ee5:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ee8:	6a 00                	push   $0x0
80106eea:	68 fa 03 00 00       	push   $0x3fa
80106eef:	e8 c9 ff ff ff       	call   80106ebd <outb>
80106ef4:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ef7:	68 80 00 00 00       	push   $0x80
80106efc:	68 fb 03 00 00       	push   $0x3fb
80106f01:	e8 b7 ff ff ff       	call   80106ebd <outb>
80106f06:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f09:	6a 0c                	push   $0xc
80106f0b:	68 f8 03 00 00       	push   $0x3f8
80106f10:	e8 a8 ff ff ff       	call   80106ebd <outb>
80106f15:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106f18:	6a 00                	push   $0x0
80106f1a:	68 f9 03 00 00       	push   $0x3f9
80106f1f:	e8 99 ff ff ff       	call   80106ebd <outb>
80106f24:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106f27:	6a 03                	push   $0x3
80106f29:	68 fb 03 00 00       	push   $0x3fb
80106f2e:	e8 8a ff ff ff       	call   80106ebd <outb>
80106f33:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106f36:	6a 00                	push   $0x0
80106f38:	68 fc 03 00 00       	push   $0x3fc
80106f3d:	e8 7b ff ff ff       	call   80106ebd <outb>
80106f42:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106f45:	6a 01                	push   $0x1
80106f47:	68 f9 03 00 00       	push   $0x3f9
80106f4c:	e8 6c ff ff ff       	call   80106ebd <outb>
80106f51:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f54:	68 fd 03 00 00       	push   $0x3fd
80106f59:	e8 42 ff ff ff       	call   80106ea0 <inb>
80106f5e:	83 c4 04             	add    $0x4,%esp
80106f61:	3c ff                	cmp    $0xff,%al
80106f63:	74 61                	je     80106fc6 <uartinit+0xe8>
    return;
  uart = 1;
80106f65:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80106f6c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106f6f:	68 fa 03 00 00       	push   $0x3fa
80106f74:	e8 27 ff ff ff       	call   80106ea0 <inb>
80106f79:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106f7c:	68 f8 03 00 00       	push   $0x3f8
80106f81:	e8 1a ff ff ff       	call   80106ea0 <inb>
80106f86:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106f89:	83 ec 08             	sub    $0x8,%esp
80106f8c:	6a 00                	push   $0x0
80106f8e:	6a 04                	push   $0x4
80106f90:	e8 f1 bc ff ff       	call   80102c86 <ioapicenable>
80106f95:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f98:	c7 45 f4 1c 93 10 80 	movl   $0x8010931c,-0xc(%ebp)
80106f9f:	eb 19                	jmp    80106fba <uartinit+0xdc>
    uartputc(*p);
80106fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa4:	0f b6 00             	movzbl (%eax),%eax
80106fa7:	0f be c0             	movsbl %al,%eax
80106faa:	83 ec 0c             	sub    $0xc,%esp
80106fad:	50                   	push   %eax
80106fae:	e8 16 00 00 00       	call   80106fc9 <uartputc>
80106fb3:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106fb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbd:	0f b6 00             	movzbl (%eax),%eax
80106fc0:	84 c0                	test   %al,%al
80106fc2:	75 dd                	jne    80106fa1 <uartinit+0xc3>
80106fc4:	eb 01                	jmp    80106fc7 <uartinit+0xe9>
    return;
80106fc6:	90                   	nop
}
80106fc7:	c9                   	leave  
80106fc8:	c3                   	ret    

80106fc9 <uartputc>:

void
uartputc(int c)
{
80106fc9:	f3 0f 1e fb          	endbr32 
80106fcd:	55                   	push   %ebp
80106fce:	89 e5                	mov    %esp,%ebp
80106fd0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106fd3:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80106fd8:	85 c0                	test   %eax,%eax
80106fda:	74 53                	je     8010702f <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106fdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fe3:	eb 11                	jmp    80106ff6 <uartputc+0x2d>
    microdelay(10);
80106fe5:	83 ec 0c             	sub    $0xc,%esp
80106fe8:	6a 0a                	push   $0xa
80106fea:	e8 cf c1 ff ff       	call   801031be <microdelay>
80106fef:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ff2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ff6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ffa:	7f 1a                	jg     80107016 <uartputc+0x4d>
80106ffc:	83 ec 0c             	sub    $0xc,%esp
80106fff:	68 fd 03 00 00       	push   $0x3fd
80107004:	e8 97 fe ff ff       	call   80106ea0 <inb>
80107009:	83 c4 10             	add    $0x10,%esp
8010700c:	0f b6 c0             	movzbl %al,%eax
8010700f:	83 e0 20             	and    $0x20,%eax
80107012:	85 c0                	test   %eax,%eax
80107014:	74 cf                	je     80106fe5 <uartputc+0x1c>
  outb(COM1+0, c);
80107016:	8b 45 08             	mov    0x8(%ebp),%eax
80107019:	0f b6 c0             	movzbl %al,%eax
8010701c:	83 ec 08             	sub    $0x8,%esp
8010701f:	50                   	push   %eax
80107020:	68 f8 03 00 00       	push   $0x3f8
80107025:	e8 93 fe ff ff       	call   80106ebd <outb>
8010702a:	83 c4 10             	add    $0x10,%esp
8010702d:	eb 01                	jmp    80107030 <uartputc+0x67>
    return;
8010702f:	90                   	nop
}
80107030:	c9                   	leave  
80107031:	c3                   	ret    

80107032 <uartgetc>:

static int
uartgetc(void)
{
80107032:	f3 0f 1e fb          	endbr32 
80107036:	55                   	push   %ebp
80107037:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107039:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010703e:	85 c0                	test   %eax,%eax
80107040:	75 07                	jne    80107049 <uartgetc+0x17>
    return -1;
80107042:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107047:	eb 2e                	jmp    80107077 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107049:	68 fd 03 00 00       	push   $0x3fd
8010704e:	e8 4d fe ff ff       	call   80106ea0 <inb>
80107053:	83 c4 04             	add    $0x4,%esp
80107056:	0f b6 c0             	movzbl %al,%eax
80107059:	83 e0 01             	and    $0x1,%eax
8010705c:	85 c0                	test   %eax,%eax
8010705e:	75 07                	jne    80107067 <uartgetc+0x35>
    return -1;
80107060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107065:	eb 10                	jmp    80107077 <uartgetc+0x45>
  return inb(COM1+0);
80107067:	68 f8 03 00 00       	push   $0x3f8
8010706c:	e8 2f fe ff ff       	call   80106ea0 <inb>
80107071:	83 c4 04             	add    $0x4,%esp
80107074:	0f b6 c0             	movzbl %al,%eax
}
80107077:	c9                   	leave  
80107078:	c3                   	ret    

80107079 <uartintr>:

void
uartintr(void)
{
80107079:	f3 0f 1e fb          	endbr32 
8010707d:	55                   	push   %ebp
8010707e:	89 e5                	mov    %esp,%ebp
80107080:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107083:	83 ec 0c             	sub    $0xc,%esp
80107086:	68 32 70 10 80       	push   $0x80107032
8010708b:	e8 18 98 ff ff       	call   801008a8 <consoleintr>
80107090:	83 c4 10             	add    $0x10,%esp
}
80107093:	90                   	nop
80107094:	c9                   	leave  
80107095:	c3                   	ret    

80107096 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $0
80107098:	6a 00                	push   $0x0
  jmp alltraps
8010709a:	e9 93 f9 ff ff       	jmp    80106a32 <alltraps>

8010709f <vector1>:
.globl vector1
vector1:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $1
801070a1:	6a 01                	push   $0x1
  jmp alltraps
801070a3:	e9 8a f9 ff ff       	jmp    80106a32 <alltraps>

801070a8 <vector2>:
.globl vector2
vector2:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $2
801070aa:	6a 02                	push   $0x2
  jmp alltraps
801070ac:	e9 81 f9 ff ff       	jmp    80106a32 <alltraps>

801070b1 <vector3>:
.globl vector3
vector3:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $3
801070b3:	6a 03                	push   $0x3
  jmp alltraps
801070b5:	e9 78 f9 ff ff       	jmp    80106a32 <alltraps>

801070ba <vector4>:
.globl vector4
vector4:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $4
801070bc:	6a 04                	push   $0x4
  jmp alltraps
801070be:	e9 6f f9 ff ff       	jmp    80106a32 <alltraps>

801070c3 <vector5>:
.globl vector5
vector5:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $5
801070c5:	6a 05                	push   $0x5
  jmp alltraps
801070c7:	e9 66 f9 ff ff       	jmp    80106a32 <alltraps>

801070cc <vector6>:
.globl vector6
vector6:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $6
801070ce:	6a 06                	push   $0x6
  jmp alltraps
801070d0:	e9 5d f9 ff ff       	jmp    80106a32 <alltraps>

801070d5 <vector7>:
.globl vector7
vector7:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $7
801070d7:	6a 07                	push   $0x7
  jmp alltraps
801070d9:	e9 54 f9 ff ff       	jmp    80106a32 <alltraps>

801070de <vector8>:
.globl vector8
vector8:
  pushl $8
801070de:	6a 08                	push   $0x8
  jmp alltraps
801070e0:	e9 4d f9 ff ff       	jmp    80106a32 <alltraps>

801070e5 <vector9>:
.globl vector9
vector9:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $9
801070e7:	6a 09                	push   $0x9
  jmp alltraps
801070e9:	e9 44 f9 ff ff       	jmp    80106a32 <alltraps>

801070ee <vector10>:
.globl vector10
vector10:
  pushl $10
801070ee:	6a 0a                	push   $0xa
  jmp alltraps
801070f0:	e9 3d f9 ff ff       	jmp    80106a32 <alltraps>

801070f5 <vector11>:
.globl vector11
vector11:
  pushl $11
801070f5:	6a 0b                	push   $0xb
  jmp alltraps
801070f7:	e9 36 f9 ff ff       	jmp    80106a32 <alltraps>

801070fc <vector12>:
.globl vector12
vector12:
  pushl $12
801070fc:	6a 0c                	push   $0xc
  jmp alltraps
801070fe:	e9 2f f9 ff ff       	jmp    80106a32 <alltraps>

80107103 <vector13>:
.globl vector13
vector13:
  pushl $13
80107103:	6a 0d                	push   $0xd
  jmp alltraps
80107105:	e9 28 f9 ff ff       	jmp    80106a32 <alltraps>

8010710a <vector14>:
.globl vector14
vector14:
  pushl $14
8010710a:	6a 0e                	push   $0xe
  jmp alltraps
8010710c:	e9 21 f9 ff ff       	jmp    80106a32 <alltraps>

80107111 <vector15>:
.globl vector15
vector15:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $15
80107113:	6a 0f                	push   $0xf
  jmp alltraps
80107115:	e9 18 f9 ff ff       	jmp    80106a32 <alltraps>

8010711a <vector16>:
.globl vector16
vector16:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $16
8010711c:	6a 10                	push   $0x10
  jmp alltraps
8010711e:	e9 0f f9 ff ff       	jmp    80106a32 <alltraps>

80107123 <vector17>:
.globl vector17
vector17:
  pushl $17
80107123:	6a 11                	push   $0x11
  jmp alltraps
80107125:	e9 08 f9 ff ff       	jmp    80106a32 <alltraps>

8010712a <vector18>:
.globl vector18
vector18:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $18
8010712c:	6a 12                	push   $0x12
  jmp alltraps
8010712e:	e9 ff f8 ff ff       	jmp    80106a32 <alltraps>

80107133 <vector19>:
.globl vector19
vector19:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $19
80107135:	6a 13                	push   $0x13
  jmp alltraps
80107137:	e9 f6 f8 ff ff       	jmp    80106a32 <alltraps>

8010713c <vector20>:
.globl vector20
vector20:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $20
8010713e:	6a 14                	push   $0x14
  jmp alltraps
80107140:	e9 ed f8 ff ff       	jmp    80106a32 <alltraps>

80107145 <vector21>:
.globl vector21
vector21:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $21
80107147:	6a 15                	push   $0x15
  jmp alltraps
80107149:	e9 e4 f8 ff ff       	jmp    80106a32 <alltraps>

8010714e <vector22>:
.globl vector22
vector22:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $22
80107150:	6a 16                	push   $0x16
  jmp alltraps
80107152:	e9 db f8 ff ff       	jmp    80106a32 <alltraps>

80107157 <vector23>:
.globl vector23
vector23:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $23
80107159:	6a 17                	push   $0x17
  jmp alltraps
8010715b:	e9 d2 f8 ff ff       	jmp    80106a32 <alltraps>

80107160 <vector24>:
.globl vector24
vector24:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $24
80107162:	6a 18                	push   $0x18
  jmp alltraps
80107164:	e9 c9 f8 ff ff       	jmp    80106a32 <alltraps>

80107169 <vector25>:
.globl vector25
vector25:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $25
8010716b:	6a 19                	push   $0x19
  jmp alltraps
8010716d:	e9 c0 f8 ff ff       	jmp    80106a32 <alltraps>

80107172 <vector26>:
.globl vector26
vector26:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $26
80107174:	6a 1a                	push   $0x1a
  jmp alltraps
80107176:	e9 b7 f8 ff ff       	jmp    80106a32 <alltraps>

8010717b <vector27>:
.globl vector27
vector27:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $27
8010717d:	6a 1b                	push   $0x1b
  jmp alltraps
8010717f:	e9 ae f8 ff ff       	jmp    80106a32 <alltraps>

80107184 <vector28>:
.globl vector28
vector28:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $28
80107186:	6a 1c                	push   $0x1c
  jmp alltraps
80107188:	e9 a5 f8 ff ff       	jmp    80106a32 <alltraps>

8010718d <vector29>:
.globl vector29
vector29:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $29
8010718f:	6a 1d                	push   $0x1d
  jmp alltraps
80107191:	e9 9c f8 ff ff       	jmp    80106a32 <alltraps>

80107196 <vector30>:
.globl vector30
vector30:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $30
80107198:	6a 1e                	push   $0x1e
  jmp alltraps
8010719a:	e9 93 f8 ff ff       	jmp    80106a32 <alltraps>

8010719f <vector31>:
.globl vector31
vector31:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $31
801071a1:	6a 1f                	push   $0x1f
  jmp alltraps
801071a3:	e9 8a f8 ff ff       	jmp    80106a32 <alltraps>

801071a8 <vector32>:
.globl vector32
vector32:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $32
801071aa:	6a 20                	push   $0x20
  jmp alltraps
801071ac:	e9 81 f8 ff ff       	jmp    80106a32 <alltraps>

801071b1 <vector33>:
.globl vector33
vector33:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $33
801071b3:	6a 21                	push   $0x21
  jmp alltraps
801071b5:	e9 78 f8 ff ff       	jmp    80106a32 <alltraps>

801071ba <vector34>:
.globl vector34
vector34:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $34
801071bc:	6a 22                	push   $0x22
  jmp alltraps
801071be:	e9 6f f8 ff ff       	jmp    80106a32 <alltraps>

801071c3 <vector35>:
.globl vector35
vector35:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $35
801071c5:	6a 23                	push   $0x23
  jmp alltraps
801071c7:	e9 66 f8 ff ff       	jmp    80106a32 <alltraps>

801071cc <vector36>:
.globl vector36
vector36:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $36
801071ce:	6a 24                	push   $0x24
  jmp alltraps
801071d0:	e9 5d f8 ff ff       	jmp    80106a32 <alltraps>

801071d5 <vector37>:
.globl vector37
vector37:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $37
801071d7:	6a 25                	push   $0x25
  jmp alltraps
801071d9:	e9 54 f8 ff ff       	jmp    80106a32 <alltraps>

801071de <vector38>:
.globl vector38
vector38:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $38
801071e0:	6a 26                	push   $0x26
  jmp alltraps
801071e2:	e9 4b f8 ff ff       	jmp    80106a32 <alltraps>

801071e7 <vector39>:
.globl vector39
vector39:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $39
801071e9:	6a 27                	push   $0x27
  jmp alltraps
801071eb:	e9 42 f8 ff ff       	jmp    80106a32 <alltraps>

801071f0 <vector40>:
.globl vector40
vector40:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $40
801071f2:	6a 28                	push   $0x28
  jmp alltraps
801071f4:	e9 39 f8 ff ff       	jmp    80106a32 <alltraps>

801071f9 <vector41>:
.globl vector41
vector41:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $41
801071fb:	6a 29                	push   $0x29
  jmp alltraps
801071fd:	e9 30 f8 ff ff       	jmp    80106a32 <alltraps>

80107202 <vector42>:
.globl vector42
vector42:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $42
80107204:	6a 2a                	push   $0x2a
  jmp alltraps
80107206:	e9 27 f8 ff ff       	jmp    80106a32 <alltraps>

8010720b <vector43>:
.globl vector43
vector43:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $43
8010720d:	6a 2b                	push   $0x2b
  jmp alltraps
8010720f:	e9 1e f8 ff ff       	jmp    80106a32 <alltraps>

80107214 <vector44>:
.globl vector44
vector44:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $44
80107216:	6a 2c                	push   $0x2c
  jmp alltraps
80107218:	e9 15 f8 ff ff       	jmp    80106a32 <alltraps>

8010721d <vector45>:
.globl vector45
vector45:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $45
8010721f:	6a 2d                	push   $0x2d
  jmp alltraps
80107221:	e9 0c f8 ff ff       	jmp    80106a32 <alltraps>

80107226 <vector46>:
.globl vector46
vector46:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $46
80107228:	6a 2e                	push   $0x2e
  jmp alltraps
8010722a:	e9 03 f8 ff ff       	jmp    80106a32 <alltraps>

8010722f <vector47>:
.globl vector47
vector47:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $47
80107231:	6a 2f                	push   $0x2f
  jmp alltraps
80107233:	e9 fa f7 ff ff       	jmp    80106a32 <alltraps>

80107238 <vector48>:
.globl vector48
vector48:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $48
8010723a:	6a 30                	push   $0x30
  jmp alltraps
8010723c:	e9 f1 f7 ff ff       	jmp    80106a32 <alltraps>

80107241 <vector49>:
.globl vector49
vector49:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $49
80107243:	6a 31                	push   $0x31
  jmp alltraps
80107245:	e9 e8 f7 ff ff       	jmp    80106a32 <alltraps>

8010724a <vector50>:
.globl vector50
vector50:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $50
8010724c:	6a 32                	push   $0x32
  jmp alltraps
8010724e:	e9 df f7 ff ff       	jmp    80106a32 <alltraps>

80107253 <vector51>:
.globl vector51
vector51:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $51
80107255:	6a 33                	push   $0x33
  jmp alltraps
80107257:	e9 d6 f7 ff ff       	jmp    80106a32 <alltraps>

8010725c <vector52>:
.globl vector52
vector52:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $52
8010725e:	6a 34                	push   $0x34
  jmp alltraps
80107260:	e9 cd f7 ff ff       	jmp    80106a32 <alltraps>

80107265 <vector53>:
.globl vector53
vector53:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $53
80107267:	6a 35                	push   $0x35
  jmp alltraps
80107269:	e9 c4 f7 ff ff       	jmp    80106a32 <alltraps>

8010726e <vector54>:
.globl vector54
vector54:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $54
80107270:	6a 36                	push   $0x36
  jmp alltraps
80107272:	e9 bb f7 ff ff       	jmp    80106a32 <alltraps>

80107277 <vector55>:
.globl vector55
vector55:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $55
80107279:	6a 37                	push   $0x37
  jmp alltraps
8010727b:	e9 b2 f7 ff ff       	jmp    80106a32 <alltraps>

80107280 <vector56>:
.globl vector56
vector56:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $56
80107282:	6a 38                	push   $0x38
  jmp alltraps
80107284:	e9 a9 f7 ff ff       	jmp    80106a32 <alltraps>

80107289 <vector57>:
.globl vector57
vector57:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $57
8010728b:	6a 39                	push   $0x39
  jmp alltraps
8010728d:	e9 a0 f7 ff ff       	jmp    80106a32 <alltraps>

80107292 <vector58>:
.globl vector58
vector58:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $58
80107294:	6a 3a                	push   $0x3a
  jmp alltraps
80107296:	e9 97 f7 ff ff       	jmp    80106a32 <alltraps>

8010729b <vector59>:
.globl vector59
vector59:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $59
8010729d:	6a 3b                	push   $0x3b
  jmp alltraps
8010729f:	e9 8e f7 ff ff       	jmp    80106a32 <alltraps>

801072a4 <vector60>:
.globl vector60
vector60:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $60
801072a6:	6a 3c                	push   $0x3c
  jmp alltraps
801072a8:	e9 85 f7 ff ff       	jmp    80106a32 <alltraps>

801072ad <vector61>:
.globl vector61
vector61:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $61
801072af:	6a 3d                	push   $0x3d
  jmp alltraps
801072b1:	e9 7c f7 ff ff       	jmp    80106a32 <alltraps>

801072b6 <vector62>:
.globl vector62
vector62:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $62
801072b8:	6a 3e                	push   $0x3e
  jmp alltraps
801072ba:	e9 73 f7 ff ff       	jmp    80106a32 <alltraps>

801072bf <vector63>:
.globl vector63
vector63:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $63
801072c1:	6a 3f                	push   $0x3f
  jmp alltraps
801072c3:	e9 6a f7 ff ff       	jmp    80106a32 <alltraps>

801072c8 <vector64>:
.globl vector64
vector64:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $64
801072ca:	6a 40                	push   $0x40
  jmp alltraps
801072cc:	e9 61 f7 ff ff       	jmp    80106a32 <alltraps>

801072d1 <vector65>:
.globl vector65
vector65:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $65
801072d3:	6a 41                	push   $0x41
  jmp alltraps
801072d5:	e9 58 f7 ff ff       	jmp    80106a32 <alltraps>

801072da <vector66>:
.globl vector66
vector66:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $66
801072dc:	6a 42                	push   $0x42
  jmp alltraps
801072de:	e9 4f f7 ff ff       	jmp    80106a32 <alltraps>

801072e3 <vector67>:
.globl vector67
vector67:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $67
801072e5:	6a 43                	push   $0x43
  jmp alltraps
801072e7:	e9 46 f7 ff ff       	jmp    80106a32 <alltraps>

801072ec <vector68>:
.globl vector68
vector68:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $68
801072ee:	6a 44                	push   $0x44
  jmp alltraps
801072f0:	e9 3d f7 ff ff       	jmp    80106a32 <alltraps>

801072f5 <vector69>:
.globl vector69
vector69:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $69
801072f7:	6a 45                	push   $0x45
  jmp alltraps
801072f9:	e9 34 f7 ff ff       	jmp    80106a32 <alltraps>

801072fe <vector70>:
.globl vector70
vector70:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $70
80107300:	6a 46                	push   $0x46
  jmp alltraps
80107302:	e9 2b f7 ff ff       	jmp    80106a32 <alltraps>

80107307 <vector71>:
.globl vector71
vector71:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $71
80107309:	6a 47                	push   $0x47
  jmp alltraps
8010730b:	e9 22 f7 ff ff       	jmp    80106a32 <alltraps>

80107310 <vector72>:
.globl vector72
vector72:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $72
80107312:	6a 48                	push   $0x48
  jmp alltraps
80107314:	e9 19 f7 ff ff       	jmp    80106a32 <alltraps>

80107319 <vector73>:
.globl vector73
vector73:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $73
8010731b:	6a 49                	push   $0x49
  jmp alltraps
8010731d:	e9 10 f7 ff ff       	jmp    80106a32 <alltraps>

80107322 <vector74>:
.globl vector74
vector74:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $74
80107324:	6a 4a                	push   $0x4a
  jmp alltraps
80107326:	e9 07 f7 ff ff       	jmp    80106a32 <alltraps>

8010732b <vector75>:
.globl vector75
vector75:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $75
8010732d:	6a 4b                	push   $0x4b
  jmp alltraps
8010732f:	e9 fe f6 ff ff       	jmp    80106a32 <alltraps>

80107334 <vector76>:
.globl vector76
vector76:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $76
80107336:	6a 4c                	push   $0x4c
  jmp alltraps
80107338:	e9 f5 f6 ff ff       	jmp    80106a32 <alltraps>

8010733d <vector77>:
.globl vector77
vector77:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $77
8010733f:	6a 4d                	push   $0x4d
  jmp alltraps
80107341:	e9 ec f6 ff ff       	jmp    80106a32 <alltraps>

80107346 <vector78>:
.globl vector78
vector78:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $78
80107348:	6a 4e                	push   $0x4e
  jmp alltraps
8010734a:	e9 e3 f6 ff ff       	jmp    80106a32 <alltraps>

8010734f <vector79>:
.globl vector79
vector79:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $79
80107351:	6a 4f                	push   $0x4f
  jmp alltraps
80107353:	e9 da f6 ff ff       	jmp    80106a32 <alltraps>

80107358 <vector80>:
.globl vector80
vector80:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $80
8010735a:	6a 50                	push   $0x50
  jmp alltraps
8010735c:	e9 d1 f6 ff ff       	jmp    80106a32 <alltraps>

80107361 <vector81>:
.globl vector81
vector81:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $81
80107363:	6a 51                	push   $0x51
  jmp alltraps
80107365:	e9 c8 f6 ff ff       	jmp    80106a32 <alltraps>

8010736a <vector82>:
.globl vector82
vector82:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $82
8010736c:	6a 52                	push   $0x52
  jmp alltraps
8010736e:	e9 bf f6 ff ff       	jmp    80106a32 <alltraps>

80107373 <vector83>:
.globl vector83
vector83:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $83
80107375:	6a 53                	push   $0x53
  jmp alltraps
80107377:	e9 b6 f6 ff ff       	jmp    80106a32 <alltraps>

8010737c <vector84>:
.globl vector84
vector84:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $84
8010737e:	6a 54                	push   $0x54
  jmp alltraps
80107380:	e9 ad f6 ff ff       	jmp    80106a32 <alltraps>

80107385 <vector85>:
.globl vector85
vector85:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $85
80107387:	6a 55                	push   $0x55
  jmp alltraps
80107389:	e9 a4 f6 ff ff       	jmp    80106a32 <alltraps>

8010738e <vector86>:
.globl vector86
vector86:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $86
80107390:	6a 56                	push   $0x56
  jmp alltraps
80107392:	e9 9b f6 ff ff       	jmp    80106a32 <alltraps>

80107397 <vector87>:
.globl vector87
vector87:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $87
80107399:	6a 57                	push   $0x57
  jmp alltraps
8010739b:	e9 92 f6 ff ff       	jmp    80106a32 <alltraps>

801073a0 <vector88>:
.globl vector88
vector88:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $88
801073a2:	6a 58                	push   $0x58
  jmp alltraps
801073a4:	e9 89 f6 ff ff       	jmp    80106a32 <alltraps>

801073a9 <vector89>:
.globl vector89
vector89:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $89
801073ab:	6a 59                	push   $0x59
  jmp alltraps
801073ad:	e9 80 f6 ff ff       	jmp    80106a32 <alltraps>

801073b2 <vector90>:
.globl vector90
vector90:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $90
801073b4:	6a 5a                	push   $0x5a
  jmp alltraps
801073b6:	e9 77 f6 ff ff       	jmp    80106a32 <alltraps>

801073bb <vector91>:
.globl vector91
vector91:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $91
801073bd:	6a 5b                	push   $0x5b
  jmp alltraps
801073bf:	e9 6e f6 ff ff       	jmp    80106a32 <alltraps>

801073c4 <vector92>:
.globl vector92
vector92:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $92
801073c6:	6a 5c                	push   $0x5c
  jmp alltraps
801073c8:	e9 65 f6 ff ff       	jmp    80106a32 <alltraps>

801073cd <vector93>:
.globl vector93
vector93:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $93
801073cf:	6a 5d                	push   $0x5d
  jmp alltraps
801073d1:	e9 5c f6 ff ff       	jmp    80106a32 <alltraps>

801073d6 <vector94>:
.globl vector94
vector94:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $94
801073d8:	6a 5e                	push   $0x5e
  jmp alltraps
801073da:	e9 53 f6 ff ff       	jmp    80106a32 <alltraps>

801073df <vector95>:
.globl vector95
vector95:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $95
801073e1:	6a 5f                	push   $0x5f
  jmp alltraps
801073e3:	e9 4a f6 ff ff       	jmp    80106a32 <alltraps>

801073e8 <vector96>:
.globl vector96
vector96:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $96
801073ea:	6a 60                	push   $0x60
  jmp alltraps
801073ec:	e9 41 f6 ff ff       	jmp    80106a32 <alltraps>

801073f1 <vector97>:
.globl vector97
vector97:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $97
801073f3:	6a 61                	push   $0x61
  jmp alltraps
801073f5:	e9 38 f6 ff ff       	jmp    80106a32 <alltraps>

801073fa <vector98>:
.globl vector98
vector98:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $98
801073fc:	6a 62                	push   $0x62
  jmp alltraps
801073fe:	e9 2f f6 ff ff       	jmp    80106a32 <alltraps>

80107403 <vector99>:
.globl vector99
vector99:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $99
80107405:	6a 63                	push   $0x63
  jmp alltraps
80107407:	e9 26 f6 ff ff       	jmp    80106a32 <alltraps>

8010740c <vector100>:
.globl vector100
vector100:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $100
8010740e:	6a 64                	push   $0x64
  jmp alltraps
80107410:	e9 1d f6 ff ff       	jmp    80106a32 <alltraps>

80107415 <vector101>:
.globl vector101
vector101:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $101
80107417:	6a 65                	push   $0x65
  jmp alltraps
80107419:	e9 14 f6 ff ff       	jmp    80106a32 <alltraps>

8010741e <vector102>:
.globl vector102
vector102:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $102
80107420:	6a 66                	push   $0x66
  jmp alltraps
80107422:	e9 0b f6 ff ff       	jmp    80106a32 <alltraps>

80107427 <vector103>:
.globl vector103
vector103:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $103
80107429:	6a 67                	push   $0x67
  jmp alltraps
8010742b:	e9 02 f6 ff ff       	jmp    80106a32 <alltraps>

80107430 <vector104>:
.globl vector104
vector104:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $104
80107432:	6a 68                	push   $0x68
  jmp alltraps
80107434:	e9 f9 f5 ff ff       	jmp    80106a32 <alltraps>

80107439 <vector105>:
.globl vector105
vector105:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $105
8010743b:	6a 69                	push   $0x69
  jmp alltraps
8010743d:	e9 f0 f5 ff ff       	jmp    80106a32 <alltraps>

80107442 <vector106>:
.globl vector106
vector106:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $106
80107444:	6a 6a                	push   $0x6a
  jmp alltraps
80107446:	e9 e7 f5 ff ff       	jmp    80106a32 <alltraps>

8010744b <vector107>:
.globl vector107
vector107:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $107
8010744d:	6a 6b                	push   $0x6b
  jmp alltraps
8010744f:	e9 de f5 ff ff       	jmp    80106a32 <alltraps>

80107454 <vector108>:
.globl vector108
vector108:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $108
80107456:	6a 6c                	push   $0x6c
  jmp alltraps
80107458:	e9 d5 f5 ff ff       	jmp    80106a32 <alltraps>

8010745d <vector109>:
.globl vector109
vector109:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $109
8010745f:	6a 6d                	push   $0x6d
  jmp alltraps
80107461:	e9 cc f5 ff ff       	jmp    80106a32 <alltraps>

80107466 <vector110>:
.globl vector110
vector110:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $110
80107468:	6a 6e                	push   $0x6e
  jmp alltraps
8010746a:	e9 c3 f5 ff ff       	jmp    80106a32 <alltraps>

8010746f <vector111>:
.globl vector111
vector111:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $111
80107471:	6a 6f                	push   $0x6f
  jmp alltraps
80107473:	e9 ba f5 ff ff       	jmp    80106a32 <alltraps>

80107478 <vector112>:
.globl vector112
vector112:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $112
8010747a:	6a 70                	push   $0x70
  jmp alltraps
8010747c:	e9 b1 f5 ff ff       	jmp    80106a32 <alltraps>

80107481 <vector113>:
.globl vector113
vector113:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $113
80107483:	6a 71                	push   $0x71
  jmp alltraps
80107485:	e9 a8 f5 ff ff       	jmp    80106a32 <alltraps>

8010748a <vector114>:
.globl vector114
vector114:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $114
8010748c:	6a 72                	push   $0x72
  jmp alltraps
8010748e:	e9 9f f5 ff ff       	jmp    80106a32 <alltraps>

80107493 <vector115>:
.globl vector115
vector115:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $115
80107495:	6a 73                	push   $0x73
  jmp alltraps
80107497:	e9 96 f5 ff ff       	jmp    80106a32 <alltraps>

8010749c <vector116>:
.globl vector116
vector116:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $116
8010749e:	6a 74                	push   $0x74
  jmp alltraps
801074a0:	e9 8d f5 ff ff       	jmp    80106a32 <alltraps>

801074a5 <vector117>:
.globl vector117
vector117:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $117
801074a7:	6a 75                	push   $0x75
  jmp alltraps
801074a9:	e9 84 f5 ff ff       	jmp    80106a32 <alltraps>

801074ae <vector118>:
.globl vector118
vector118:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $118
801074b0:	6a 76                	push   $0x76
  jmp alltraps
801074b2:	e9 7b f5 ff ff       	jmp    80106a32 <alltraps>

801074b7 <vector119>:
.globl vector119
vector119:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $119
801074b9:	6a 77                	push   $0x77
  jmp alltraps
801074bb:	e9 72 f5 ff ff       	jmp    80106a32 <alltraps>

801074c0 <vector120>:
.globl vector120
vector120:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $120
801074c2:	6a 78                	push   $0x78
  jmp alltraps
801074c4:	e9 69 f5 ff ff       	jmp    80106a32 <alltraps>

801074c9 <vector121>:
.globl vector121
vector121:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $121
801074cb:	6a 79                	push   $0x79
  jmp alltraps
801074cd:	e9 60 f5 ff ff       	jmp    80106a32 <alltraps>

801074d2 <vector122>:
.globl vector122
vector122:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $122
801074d4:	6a 7a                	push   $0x7a
  jmp alltraps
801074d6:	e9 57 f5 ff ff       	jmp    80106a32 <alltraps>

801074db <vector123>:
.globl vector123
vector123:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $123
801074dd:	6a 7b                	push   $0x7b
  jmp alltraps
801074df:	e9 4e f5 ff ff       	jmp    80106a32 <alltraps>

801074e4 <vector124>:
.globl vector124
vector124:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $124
801074e6:	6a 7c                	push   $0x7c
  jmp alltraps
801074e8:	e9 45 f5 ff ff       	jmp    80106a32 <alltraps>

801074ed <vector125>:
.globl vector125
vector125:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $125
801074ef:	6a 7d                	push   $0x7d
  jmp alltraps
801074f1:	e9 3c f5 ff ff       	jmp    80106a32 <alltraps>

801074f6 <vector126>:
.globl vector126
vector126:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $126
801074f8:	6a 7e                	push   $0x7e
  jmp alltraps
801074fa:	e9 33 f5 ff ff       	jmp    80106a32 <alltraps>

801074ff <vector127>:
.globl vector127
vector127:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $127
80107501:	6a 7f                	push   $0x7f
  jmp alltraps
80107503:	e9 2a f5 ff ff       	jmp    80106a32 <alltraps>

80107508 <vector128>:
.globl vector128
vector128:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $128
8010750a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010750f:	e9 1e f5 ff ff       	jmp    80106a32 <alltraps>

80107514 <vector129>:
.globl vector129
vector129:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $129
80107516:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010751b:	e9 12 f5 ff ff       	jmp    80106a32 <alltraps>

80107520 <vector130>:
.globl vector130
vector130:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $130
80107522:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107527:	e9 06 f5 ff ff       	jmp    80106a32 <alltraps>

8010752c <vector131>:
.globl vector131
vector131:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $131
8010752e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107533:	e9 fa f4 ff ff       	jmp    80106a32 <alltraps>

80107538 <vector132>:
.globl vector132
vector132:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $132
8010753a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010753f:	e9 ee f4 ff ff       	jmp    80106a32 <alltraps>

80107544 <vector133>:
.globl vector133
vector133:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $133
80107546:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010754b:	e9 e2 f4 ff ff       	jmp    80106a32 <alltraps>

80107550 <vector134>:
.globl vector134
vector134:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $134
80107552:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107557:	e9 d6 f4 ff ff       	jmp    80106a32 <alltraps>

8010755c <vector135>:
.globl vector135
vector135:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $135
8010755e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107563:	e9 ca f4 ff ff       	jmp    80106a32 <alltraps>

80107568 <vector136>:
.globl vector136
vector136:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $136
8010756a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010756f:	e9 be f4 ff ff       	jmp    80106a32 <alltraps>

80107574 <vector137>:
.globl vector137
vector137:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $137
80107576:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010757b:	e9 b2 f4 ff ff       	jmp    80106a32 <alltraps>

80107580 <vector138>:
.globl vector138
vector138:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $138
80107582:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107587:	e9 a6 f4 ff ff       	jmp    80106a32 <alltraps>

8010758c <vector139>:
.globl vector139
vector139:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $139
8010758e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107593:	e9 9a f4 ff ff       	jmp    80106a32 <alltraps>

80107598 <vector140>:
.globl vector140
vector140:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $140
8010759a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010759f:	e9 8e f4 ff ff       	jmp    80106a32 <alltraps>

801075a4 <vector141>:
.globl vector141
vector141:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $141
801075a6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801075ab:	e9 82 f4 ff ff       	jmp    80106a32 <alltraps>

801075b0 <vector142>:
.globl vector142
vector142:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $142
801075b2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801075b7:	e9 76 f4 ff ff       	jmp    80106a32 <alltraps>

801075bc <vector143>:
.globl vector143
vector143:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $143
801075be:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801075c3:	e9 6a f4 ff ff       	jmp    80106a32 <alltraps>

801075c8 <vector144>:
.globl vector144
vector144:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $144
801075ca:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801075cf:	e9 5e f4 ff ff       	jmp    80106a32 <alltraps>

801075d4 <vector145>:
.globl vector145
vector145:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $145
801075d6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801075db:	e9 52 f4 ff ff       	jmp    80106a32 <alltraps>

801075e0 <vector146>:
.globl vector146
vector146:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $146
801075e2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801075e7:	e9 46 f4 ff ff       	jmp    80106a32 <alltraps>

801075ec <vector147>:
.globl vector147
vector147:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $147
801075ee:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801075f3:	e9 3a f4 ff ff       	jmp    80106a32 <alltraps>

801075f8 <vector148>:
.globl vector148
vector148:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $148
801075fa:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801075ff:	e9 2e f4 ff ff       	jmp    80106a32 <alltraps>

80107604 <vector149>:
.globl vector149
vector149:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $149
80107606:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010760b:	e9 22 f4 ff ff       	jmp    80106a32 <alltraps>

80107610 <vector150>:
.globl vector150
vector150:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $150
80107612:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107617:	e9 16 f4 ff ff       	jmp    80106a32 <alltraps>

8010761c <vector151>:
.globl vector151
vector151:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $151
8010761e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107623:	e9 0a f4 ff ff       	jmp    80106a32 <alltraps>

80107628 <vector152>:
.globl vector152
vector152:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $152
8010762a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010762f:	e9 fe f3 ff ff       	jmp    80106a32 <alltraps>

80107634 <vector153>:
.globl vector153
vector153:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $153
80107636:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010763b:	e9 f2 f3 ff ff       	jmp    80106a32 <alltraps>

80107640 <vector154>:
.globl vector154
vector154:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $154
80107642:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107647:	e9 e6 f3 ff ff       	jmp    80106a32 <alltraps>

8010764c <vector155>:
.globl vector155
vector155:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $155
8010764e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107653:	e9 da f3 ff ff       	jmp    80106a32 <alltraps>

80107658 <vector156>:
.globl vector156
vector156:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $156
8010765a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010765f:	e9 ce f3 ff ff       	jmp    80106a32 <alltraps>

80107664 <vector157>:
.globl vector157
vector157:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $157
80107666:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010766b:	e9 c2 f3 ff ff       	jmp    80106a32 <alltraps>

80107670 <vector158>:
.globl vector158
vector158:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $158
80107672:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107677:	e9 b6 f3 ff ff       	jmp    80106a32 <alltraps>

8010767c <vector159>:
.globl vector159
vector159:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $159
8010767e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107683:	e9 aa f3 ff ff       	jmp    80106a32 <alltraps>

80107688 <vector160>:
.globl vector160
vector160:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $160
8010768a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010768f:	e9 9e f3 ff ff       	jmp    80106a32 <alltraps>

80107694 <vector161>:
.globl vector161
vector161:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $161
80107696:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010769b:	e9 92 f3 ff ff       	jmp    80106a32 <alltraps>

801076a0 <vector162>:
.globl vector162
vector162:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $162
801076a2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801076a7:	e9 86 f3 ff ff       	jmp    80106a32 <alltraps>

801076ac <vector163>:
.globl vector163
vector163:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $163
801076ae:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801076b3:	e9 7a f3 ff ff       	jmp    80106a32 <alltraps>

801076b8 <vector164>:
.globl vector164
vector164:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $164
801076ba:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801076bf:	e9 6e f3 ff ff       	jmp    80106a32 <alltraps>

801076c4 <vector165>:
.globl vector165
vector165:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $165
801076c6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801076cb:	e9 62 f3 ff ff       	jmp    80106a32 <alltraps>

801076d0 <vector166>:
.globl vector166
vector166:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $166
801076d2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801076d7:	e9 56 f3 ff ff       	jmp    80106a32 <alltraps>

801076dc <vector167>:
.globl vector167
vector167:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $167
801076de:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801076e3:	e9 4a f3 ff ff       	jmp    80106a32 <alltraps>

801076e8 <vector168>:
.globl vector168
vector168:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $168
801076ea:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801076ef:	e9 3e f3 ff ff       	jmp    80106a32 <alltraps>

801076f4 <vector169>:
.globl vector169
vector169:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $169
801076f6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801076fb:	e9 32 f3 ff ff       	jmp    80106a32 <alltraps>

80107700 <vector170>:
.globl vector170
vector170:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $170
80107702:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107707:	e9 26 f3 ff ff       	jmp    80106a32 <alltraps>

8010770c <vector171>:
.globl vector171
vector171:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $171
8010770e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107713:	e9 1a f3 ff ff       	jmp    80106a32 <alltraps>

80107718 <vector172>:
.globl vector172
vector172:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $172
8010771a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010771f:	e9 0e f3 ff ff       	jmp    80106a32 <alltraps>

80107724 <vector173>:
.globl vector173
vector173:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $173
80107726:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010772b:	e9 02 f3 ff ff       	jmp    80106a32 <alltraps>

80107730 <vector174>:
.globl vector174
vector174:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $174
80107732:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107737:	e9 f6 f2 ff ff       	jmp    80106a32 <alltraps>

8010773c <vector175>:
.globl vector175
vector175:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $175
8010773e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107743:	e9 ea f2 ff ff       	jmp    80106a32 <alltraps>

80107748 <vector176>:
.globl vector176
vector176:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $176
8010774a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010774f:	e9 de f2 ff ff       	jmp    80106a32 <alltraps>

80107754 <vector177>:
.globl vector177
vector177:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $177
80107756:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010775b:	e9 d2 f2 ff ff       	jmp    80106a32 <alltraps>

80107760 <vector178>:
.globl vector178
vector178:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $178
80107762:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107767:	e9 c6 f2 ff ff       	jmp    80106a32 <alltraps>

8010776c <vector179>:
.globl vector179
vector179:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $179
8010776e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107773:	e9 ba f2 ff ff       	jmp    80106a32 <alltraps>

80107778 <vector180>:
.globl vector180
vector180:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $180
8010777a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010777f:	e9 ae f2 ff ff       	jmp    80106a32 <alltraps>

80107784 <vector181>:
.globl vector181
vector181:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $181
80107786:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010778b:	e9 a2 f2 ff ff       	jmp    80106a32 <alltraps>

80107790 <vector182>:
.globl vector182
vector182:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $182
80107792:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107797:	e9 96 f2 ff ff       	jmp    80106a32 <alltraps>

8010779c <vector183>:
.globl vector183
vector183:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $183
8010779e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801077a3:	e9 8a f2 ff ff       	jmp    80106a32 <alltraps>

801077a8 <vector184>:
.globl vector184
vector184:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $184
801077aa:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801077af:	e9 7e f2 ff ff       	jmp    80106a32 <alltraps>

801077b4 <vector185>:
.globl vector185
vector185:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $185
801077b6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801077bb:	e9 72 f2 ff ff       	jmp    80106a32 <alltraps>

801077c0 <vector186>:
.globl vector186
vector186:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $186
801077c2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801077c7:	e9 66 f2 ff ff       	jmp    80106a32 <alltraps>

801077cc <vector187>:
.globl vector187
vector187:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $187
801077ce:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801077d3:	e9 5a f2 ff ff       	jmp    80106a32 <alltraps>

801077d8 <vector188>:
.globl vector188
vector188:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $188
801077da:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801077df:	e9 4e f2 ff ff       	jmp    80106a32 <alltraps>

801077e4 <vector189>:
.globl vector189
vector189:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $189
801077e6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801077eb:	e9 42 f2 ff ff       	jmp    80106a32 <alltraps>

801077f0 <vector190>:
.globl vector190
vector190:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $190
801077f2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801077f7:	e9 36 f2 ff ff       	jmp    80106a32 <alltraps>

801077fc <vector191>:
.globl vector191
vector191:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $191
801077fe:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107803:	e9 2a f2 ff ff       	jmp    80106a32 <alltraps>

80107808 <vector192>:
.globl vector192
vector192:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $192
8010780a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010780f:	e9 1e f2 ff ff       	jmp    80106a32 <alltraps>

80107814 <vector193>:
.globl vector193
vector193:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $193
80107816:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010781b:	e9 12 f2 ff ff       	jmp    80106a32 <alltraps>

80107820 <vector194>:
.globl vector194
vector194:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $194
80107822:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107827:	e9 06 f2 ff ff       	jmp    80106a32 <alltraps>

8010782c <vector195>:
.globl vector195
vector195:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $195
8010782e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107833:	e9 fa f1 ff ff       	jmp    80106a32 <alltraps>

80107838 <vector196>:
.globl vector196
vector196:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $196
8010783a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010783f:	e9 ee f1 ff ff       	jmp    80106a32 <alltraps>

80107844 <vector197>:
.globl vector197
vector197:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $197
80107846:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010784b:	e9 e2 f1 ff ff       	jmp    80106a32 <alltraps>

80107850 <vector198>:
.globl vector198
vector198:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $198
80107852:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107857:	e9 d6 f1 ff ff       	jmp    80106a32 <alltraps>

8010785c <vector199>:
.globl vector199
vector199:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $199
8010785e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107863:	e9 ca f1 ff ff       	jmp    80106a32 <alltraps>

80107868 <vector200>:
.globl vector200
vector200:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $200
8010786a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010786f:	e9 be f1 ff ff       	jmp    80106a32 <alltraps>

80107874 <vector201>:
.globl vector201
vector201:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $201
80107876:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010787b:	e9 b2 f1 ff ff       	jmp    80106a32 <alltraps>

80107880 <vector202>:
.globl vector202
vector202:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $202
80107882:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107887:	e9 a6 f1 ff ff       	jmp    80106a32 <alltraps>

8010788c <vector203>:
.globl vector203
vector203:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $203
8010788e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107893:	e9 9a f1 ff ff       	jmp    80106a32 <alltraps>

80107898 <vector204>:
.globl vector204
vector204:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $204
8010789a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010789f:	e9 8e f1 ff ff       	jmp    80106a32 <alltraps>

801078a4 <vector205>:
.globl vector205
vector205:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $205
801078a6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801078ab:	e9 82 f1 ff ff       	jmp    80106a32 <alltraps>

801078b0 <vector206>:
.globl vector206
vector206:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $206
801078b2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801078b7:	e9 76 f1 ff ff       	jmp    80106a32 <alltraps>

801078bc <vector207>:
.globl vector207
vector207:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $207
801078be:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801078c3:	e9 6a f1 ff ff       	jmp    80106a32 <alltraps>

801078c8 <vector208>:
.globl vector208
vector208:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $208
801078ca:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801078cf:	e9 5e f1 ff ff       	jmp    80106a32 <alltraps>

801078d4 <vector209>:
.globl vector209
vector209:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $209
801078d6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801078db:	e9 52 f1 ff ff       	jmp    80106a32 <alltraps>

801078e0 <vector210>:
.globl vector210
vector210:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $210
801078e2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801078e7:	e9 46 f1 ff ff       	jmp    80106a32 <alltraps>

801078ec <vector211>:
.globl vector211
vector211:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $211
801078ee:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801078f3:	e9 3a f1 ff ff       	jmp    80106a32 <alltraps>

801078f8 <vector212>:
.globl vector212
vector212:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $212
801078fa:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801078ff:	e9 2e f1 ff ff       	jmp    80106a32 <alltraps>

80107904 <vector213>:
.globl vector213
vector213:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $213
80107906:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010790b:	e9 22 f1 ff ff       	jmp    80106a32 <alltraps>

80107910 <vector214>:
.globl vector214
vector214:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $214
80107912:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107917:	e9 16 f1 ff ff       	jmp    80106a32 <alltraps>

8010791c <vector215>:
.globl vector215
vector215:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $215
8010791e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107923:	e9 0a f1 ff ff       	jmp    80106a32 <alltraps>

80107928 <vector216>:
.globl vector216
vector216:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $216
8010792a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010792f:	e9 fe f0 ff ff       	jmp    80106a32 <alltraps>

80107934 <vector217>:
.globl vector217
vector217:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $217
80107936:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010793b:	e9 f2 f0 ff ff       	jmp    80106a32 <alltraps>

80107940 <vector218>:
.globl vector218
vector218:
  pushl $0
80107940:	6a 00                	push   $0x0
  pushl $218
80107942:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107947:	e9 e6 f0 ff ff       	jmp    80106a32 <alltraps>

8010794c <vector219>:
.globl vector219
vector219:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $219
8010794e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107953:	e9 da f0 ff ff       	jmp    80106a32 <alltraps>

80107958 <vector220>:
.globl vector220
vector220:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $220
8010795a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010795f:	e9 ce f0 ff ff       	jmp    80106a32 <alltraps>

80107964 <vector221>:
.globl vector221
vector221:
  pushl $0
80107964:	6a 00                	push   $0x0
  pushl $221
80107966:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010796b:	e9 c2 f0 ff ff       	jmp    80106a32 <alltraps>

80107970 <vector222>:
.globl vector222
vector222:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $222
80107972:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107977:	e9 b6 f0 ff ff       	jmp    80106a32 <alltraps>

8010797c <vector223>:
.globl vector223
vector223:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $223
8010797e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107983:	e9 aa f0 ff ff       	jmp    80106a32 <alltraps>

80107988 <vector224>:
.globl vector224
vector224:
  pushl $0
80107988:	6a 00                	push   $0x0
  pushl $224
8010798a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010798f:	e9 9e f0 ff ff       	jmp    80106a32 <alltraps>

80107994 <vector225>:
.globl vector225
vector225:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $225
80107996:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010799b:	e9 92 f0 ff ff       	jmp    80106a32 <alltraps>

801079a0 <vector226>:
.globl vector226
vector226:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $226
801079a2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801079a7:	e9 86 f0 ff ff       	jmp    80106a32 <alltraps>

801079ac <vector227>:
.globl vector227
vector227:
  pushl $0
801079ac:	6a 00                	push   $0x0
  pushl $227
801079ae:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801079b3:	e9 7a f0 ff ff       	jmp    80106a32 <alltraps>

801079b8 <vector228>:
.globl vector228
vector228:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $228
801079ba:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801079bf:	e9 6e f0 ff ff       	jmp    80106a32 <alltraps>

801079c4 <vector229>:
.globl vector229
vector229:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $229
801079c6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801079cb:	e9 62 f0 ff ff       	jmp    80106a32 <alltraps>

801079d0 <vector230>:
.globl vector230
vector230:
  pushl $0
801079d0:	6a 00                	push   $0x0
  pushl $230
801079d2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801079d7:	e9 56 f0 ff ff       	jmp    80106a32 <alltraps>

801079dc <vector231>:
.globl vector231
vector231:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $231
801079de:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801079e3:	e9 4a f0 ff ff       	jmp    80106a32 <alltraps>

801079e8 <vector232>:
.globl vector232
vector232:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $232
801079ea:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801079ef:	e9 3e f0 ff ff       	jmp    80106a32 <alltraps>

801079f4 <vector233>:
.globl vector233
vector233:
  pushl $0
801079f4:	6a 00                	push   $0x0
  pushl $233
801079f6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801079fb:	e9 32 f0 ff ff       	jmp    80106a32 <alltraps>

80107a00 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $234
80107a02:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a07:	e9 26 f0 ff ff       	jmp    80106a32 <alltraps>

80107a0c <vector235>:
.globl vector235
vector235:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $235
80107a0e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a13:	e9 1a f0 ff ff       	jmp    80106a32 <alltraps>

80107a18 <vector236>:
.globl vector236
vector236:
  pushl $0
80107a18:	6a 00                	push   $0x0
  pushl $236
80107a1a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107a1f:	e9 0e f0 ff ff       	jmp    80106a32 <alltraps>

80107a24 <vector237>:
.globl vector237
vector237:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $237
80107a26:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107a2b:	e9 02 f0 ff ff       	jmp    80106a32 <alltraps>

80107a30 <vector238>:
.globl vector238
vector238:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $238
80107a32:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107a37:	e9 f6 ef ff ff       	jmp    80106a32 <alltraps>

80107a3c <vector239>:
.globl vector239
vector239:
  pushl $0
80107a3c:	6a 00                	push   $0x0
  pushl $239
80107a3e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107a43:	e9 ea ef ff ff       	jmp    80106a32 <alltraps>

80107a48 <vector240>:
.globl vector240
vector240:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $240
80107a4a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107a4f:	e9 de ef ff ff       	jmp    80106a32 <alltraps>

80107a54 <vector241>:
.globl vector241
vector241:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $241
80107a56:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a5b:	e9 d2 ef ff ff       	jmp    80106a32 <alltraps>

80107a60 <vector242>:
.globl vector242
vector242:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $242
80107a62:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107a67:	e9 c6 ef ff ff       	jmp    80106a32 <alltraps>

80107a6c <vector243>:
.globl vector243
vector243:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $243
80107a6e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107a73:	e9 ba ef ff ff       	jmp    80106a32 <alltraps>

80107a78 <vector244>:
.globl vector244
vector244:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $244
80107a7a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107a7f:	e9 ae ef ff ff       	jmp    80106a32 <alltraps>

80107a84 <vector245>:
.globl vector245
vector245:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $245
80107a86:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a8b:	e9 a2 ef ff ff       	jmp    80106a32 <alltraps>

80107a90 <vector246>:
.globl vector246
vector246:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $246
80107a92:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a97:	e9 96 ef ff ff       	jmp    80106a32 <alltraps>

80107a9c <vector247>:
.globl vector247
vector247:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $247
80107a9e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107aa3:	e9 8a ef ff ff       	jmp    80106a32 <alltraps>

80107aa8 <vector248>:
.globl vector248
vector248:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $248
80107aaa:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107aaf:	e9 7e ef ff ff       	jmp    80106a32 <alltraps>

80107ab4 <vector249>:
.globl vector249
vector249:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $249
80107ab6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107abb:	e9 72 ef ff ff       	jmp    80106a32 <alltraps>

80107ac0 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $250
80107ac2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ac7:	e9 66 ef ff ff       	jmp    80106a32 <alltraps>

80107acc <vector251>:
.globl vector251
vector251:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $251
80107ace:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ad3:	e9 5a ef ff ff       	jmp    80106a32 <alltraps>

80107ad8 <vector252>:
.globl vector252
vector252:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $252
80107ada:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107adf:	e9 4e ef ff ff       	jmp    80106a32 <alltraps>

80107ae4 <vector253>:
.globl vector253
vector253:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $253
80107ae6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107aeb:	e9 42 ef ff ff       	jmp    80106a32 <alltraps>

80107af0 <vector254>:
.globl vector254
vector254:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $254
80107af2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107af7:	e9 36 ef ff ff       	jmp    80106a32 <alltraps>

80107afc <vector255>:
.globl vector255
vector255:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $255
80107afe:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b03:	e9 2a ef ff ff       	jmp    80106a32 <alltraps>

80107b08 <lgdt>:
{
80107b08:	55                   	push   %ebp
80107b09:	89 e5                	mov    %esp,%ebp
80107b0b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b11:	83 e8 01             	sub    $0x1,%eax
80107b14:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b18:	8b 45 08             	mov    0x8(%ebp),%eax
80107b1b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b22:	c1 e8 10             	shr    $0x10,%eax
80107b25:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107b29:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107b2c:	0f 01 10             	lgdtl  (%eax)
}
80107b2f:	90                   	nop
80107b30:	c9                   	leave  
80107b31:	c3                   	ret    

80107b32 <ltr>:
{
80107b32:	55                   	push   %ebp
80107b33:	89 e5                	mov    %esp,%ebp
80107b35:	83 ec 04             	sub    $0x4,%esp
80107b38:	8b 45 08             	mov    0x8(%ebp),%eax
80107b3b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107b3f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b43:	0f 00 d8             	ltr    %ax
}
80107b46:	90                   	nop
80107b47:	c9                   	leave  
80107b48:	c3                   	ret    

80107b49 <lcr3>:

static inline void
lcr3(uint val)
{
80107b49:	55                   	push   %ebp
80107b4a:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b4f:	0f 22 d8             	mov    %eax,%cr3
}
80107b52:	90                   	nop
80107b53:	5d                   	pop    %ebp
80107b54:	c3                   	ret    

80107b55 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b55:	f3 0f 1e fb          	endbr32 
80107b59:	55                   	push   %ebp
80107b5a:	89 e5                	mov    %esp,%ebp
80107b5c:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107b5f:	e8 ab c8 ff ff       	call   8010440f <cpuid>
80107b64:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107b6a:	05 20 48 11 80       	add    $0x80114820,%eax
80107b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b87:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b92:	83 e2 f0             	and    $0xfffffff0,%edx
80107b95:	83 ca 0a             	or     $0xa,%edx
80107b98:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ba2:	83 ca 10             	or     $0x10,%edx
80107ba5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107baf:	83 e2 9f             	and    $0xffffff9f,%edx
80107bb2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107bbc:	83 ca 80             	or     $0xffffff80,%edx
80107bbf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bc9:	83 ca 0f             	or     $0xf,%edx
80107bcc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bd6:	83 e2 ef             	and    $0xffffffef,%edx
80107bd9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107be3:	83 e2 df             	and    $0xffffffdf,%edx
80107be6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bf0:	83 ca 40             	or     $0x40,%edx
80107bf3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bfd:	83 ca 80             	or     $0xffffff80,%edx
80107c00:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c06:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107c14:	ff ff 
80107c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c19:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107c20:	00 00 
80107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c25:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c36:	83 e2 f0             	and    $0xfffffff0,%edx
80107c39:	83 ca 02             	or     $0x2,%edx
80107c3c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c4c:	83 ca 10             	or     $0x10,%edx
80107c4f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c5f:	83 e2 9f             	and    $0xffffff9f,%edx
80107c62:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c72:	83 ca 80             	or     $0xffffff80,%edx
80107c75:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c85:	83 ca 0f             	or     $0xf,%edx
80107c88:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c91:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c98:	83 e2 ef             	and    $0xffffffef,%edx
80107c9b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cab:	83 e2 df             	and    $0xffffffdf,%edx
80107cae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cbe:	83 ca 40             	or     $0x40,%edx
80107cc1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cd1:	83 ca 80             	or     $0xffffff80,%edx
80107cd4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce7:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107cee:	ff ff 
80107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf3:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107cfa:	00 00 
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d10:	83 e2 f0             	and    $0xfffffff0,%edx
80107d13:	83 ca 0a             	or     $0xa,%edx
80107d16:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d26:	83 ca 10             	or     $0x10,%edx
80107d29:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d39:	83 ca 60             	or     $0x60,%edx
80107d3c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d4c:	83 ca 80             	or     $0xffffff80,%edx
80107d4f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d58:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d5f:	83 ca 0f             	or     $0xf,%edx
80107d62:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d72:	83 e2 ef             	and    $0xffffffef,%edx
80107d75:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d85:	83 e2 df             	and    $0xffffffdf,%edx
80107d88:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d91:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d98:	83 ca 40             	or     $0x40,%edx
80107d9b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107dab:	83 ca 80             	or     $0xffffff80,%edx
80107dae:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107dc8:	ff ff 
80107dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcd:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107dd4:	00 00 
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dea:	83 e2 f0             	and    $0xfffffff0,%edx
80107ded:	83 ca 02             	or     $0x2,%edx
80107df0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e00:	83 ca 10             	or     $0x10,%edx
80107e03:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e13:	83 ca 60             	or     $0x60,%edx
80107e16:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e26:	83 ca 80             	or     $0xffffff80,%edx
80107e29:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e39:	83 ca 0f             	or     $0xf,%edx
80107e3c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e4c:	83 e2 ef             	and    $0xffffffef,%edx
80107e4f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e5f:	83 e2 df             	and    $0xffffffdf,%edx
80107e62:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e72:	83 ca 40             	or     $0x40,%edx
80107e75:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e85:	83 ca 80             	or     $0xffffff80,%edx
80107e88:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9b:	83 c0 70             	add    $0x70,%eax
80107e9e:	83 ec 08             	sub    $0x8,%esp
80107ea1:	6a 30                	push   $0x30
80107ea3:	50                   	push   %eax
80107ea4:	e8 5f fc ff ff       	call   80107b08 <lgdt>
80107ea9:	83 c4 10             	add    $0x10,%esp
}
80107eac:	90                   	nop
80107ead:	c9                   	leave  
80107eae:	c3                   	ret    

80107eaf <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eaf:	f3 0f 1e fb          	endbr32 
80107eb3:	55                   	push   %ebp
80107eb4:	89 e5                	mov    %esp,%ebp
80107eb6:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ebc:	c1 e8 16             	shr    $0x16,%eax
80107ebf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec9:	01 d0                	add    %edx,%eax
80107ecb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
80107ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed1:	8b 00                	mov    (%eax),%eax
80107ed3:	83 e0 01             	and    $0x1,%eax
80107ed6:	85 c0                	test   %eax,%eax
80107ed8:	74 14                	je     80107eee <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107edd:	8b 00                	mov    (%eax),%eax
80107edf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107eec:	eb 42                	jmp    80107f30 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107eee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ef2:	74 0e                	je     80107f02 <walkpgdir+0x53>
80107ef4:	e8 13 af ff ff       	call   80102e0c <kalloc>
80107ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f00:	75 07                	jne    80107f09 <walkpgdir+0x5a>
      return 0;
80107f02:	b8 00 00 00 00       	mov    $0x0,%eax
80107f07:	eb 3e                	jmp    80107f47 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f09:	83 ec 04             	sub    $0x4,%esp
80107f0c:	68 00 10 00 00       	push   $0x1000
80107f11:	6a 00                	push   $0x0
80107f13:	ff 75 f4             	pushl  -0xc(%ebp)
80107f16:	e8 cb d5 ff ff       	call   801054e6 <memset>
80107f1b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	05 00 00 00 80       	add    $0x80000000,%eax
80107f26:	83 c8 07             	or     $0x7,%eax
80107f29:	89 c2                	mov    %eax,%edx
80107f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f2e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f33:	c1 e8 0c             	shr    $0xc,%eax
80107f36:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f45:	01 d0                	add    %edx,%eax
}
80107f47:	c9                   	leave  
80107f48:	c3                   	ret    

80107f49 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f49:	f3 0f 1e fb          	endbr32 
80107f4d:	55                   	push   %ebp
80107f4e:	89 e5                	mov    %esp,%ebp
80107f50:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f61:	8b 45 10             	mov    0x10(%ebp),%eax
80107f64:	01 d0                	add    %edx,%eax
80107f66:	83 e8 01             	sub    $0x1,%eax
80107f69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f71:	83 ec 04             	sub    $0x4,%esp
80107f74:	6a 01                	push   $0x1
80107f76:	ff 75 f4             	pushl  -0xc(%ebp)
80107f79:	ff 75 08             	pushl  0x8(%ebp)
80107f7c:	e8 2e ff ff ff       	call   80107eaf <walkpgdir>
80107f81:	83 c4 10             	add    $0x10,%esp
80107f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f87:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f8b:	75 07                	jne    80107f94 <mappages+0x4b>
      return -1;
80107f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f92:	eb 6f                	jmp    80108003 <mappages+0xba>
    if(*pte & (PTE_P | PTE_E))
80107f94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f97:	8b 00                	mov    (%eax),%eax
80107f99:	25 01 04 00 00       	and    $0x401,%eax
80107f9e:	85 c0                	test   %eax,%eax
80107fa0:	74 0d                	je     80107faf <mappages+0x66>
      panic("remap");
80107fa2:	83 ec 0c             	sub    $0xc,%esp
80107fa5:	68 24 93 10 80       	push   $0x80109324
80107faa:	e8 59 86 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80107faf:	8b 45 18             	mov    0x18(%ebp),%eax
80107fb2:	25 00 04 00 00       	and    $0x400,%eax
80107fb7:	85 c0                	test   %eax,%eax
80107fb9:	74 17                	je     80107fd2 <mappages+0x89>
      *pte = (pa | perm | PTE_E) & ~PTE_P;
80107fbb:	8b 45 18             	mov    0x18(%ebp),%eax
80107fbe:	0b 45 14             	or     0x14(%ebp),%eax
80107fc1:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
80107fc6:	80 cc 04             	or     $0x4,%ah
80107fc9:	89 c2                	mov    %eax,%edx
80107fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fce:	89 10                	mov    %edx,(%eax)
80107fd0:	eb 10                	jmp    80107fe2 <mappages+0x99>
    else
      *pte = pa | perm | PTE_P;
80107fd2:	8b 45 18             	mov    0x18(%ebp),%eax
80107fd5:	0b 45 14             	or     0x14(%ebp),%eax
80107fd8:	83 c8 01             	or     $0x1,%eax
80107fdb:	89 c2                	mov    %eax,%edx
80107fdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe0:	89 10                	mov    %edx,(%eax)


    if(a == last)
80107fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fe8:	74 13                	je     80107ffd <mappages+0xb4>
      break;
    a += PGSIZE;
80107fea:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ff1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ff8:	e9 74 ff ff ff       	jmp    80107f71 <mappages+0x28>
      break;
80107ffd:	90                   	nop
  }
  return 0;
80107ffe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108003:	c9                   	leave  
80108004:	c3                   	ret    

80108005 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108005:	f3 0f 1e fb          	endbr32 
80108009:	55                   	push   %ebp
8010800a:	89 e5                	mov    %esp,%ebp
8010800c:	53                   	push   %ebx
8010800d:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108010:	e8 f7 ad ff ff       	call   80102e0c <kalloc>
80108015:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108018:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010801c:	75 07                	jne    80108025 <setupkvm+0x20>
    return 0;
8010801e:	b8 00 00 00 00       	mov    $0x0,%eax
80108023:	eb 78                	jmp    8010809d <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
80108025:	83 ec 04             	sub    $0x4,%esp
80108028:	68 00 10 00 00       	push   $0x1000
8010802d:	6a 00                	push   $0x0
8010802f:	ff 75 f0             	pushl  -0x10(%ebp)
80108032:	e8 af d4 ff ff       	call   801054e6 <memset>
80108037:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010803a:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108041:	eb 4e                	jmp    80108091 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108046:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80108049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804c:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010804f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108052:	8b 58 08             	mov    0x8(%eax),%ebx
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	8b 40 04             	mov    0x4(%eax),%eax
8010805b:	29 c3                	sub    %eax,%ebx
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108060:	8b 00                	mov    (%eax),%eax
80108062:	83 ec 0c             	sub    $0xc,%esp
80108065:	51                   	push   %ecx
80108066:	52                   	push   %edx
80108067:	53                   	push   %ebx
80108068:	50                   	push   %eax
80108069:	ff 75 f0             	pushl  -0x10(%ebp)
8010806c:	e8 d8 fe ff ff       	call   80107f49 <mappages>
80108071:	83 c4 20             	add    $0x20,%esp
80108074:	85 c0                	test   %eax,%eax
80108076:	79 15                	jns    8010808d <setupkvm+0x88>
      freevm(pgdir);
80108078:	83 ec 0c             	sub    $0xc,%esp
8010807b:	ff 75 f0             	pushl  -0x10(%ebp)
8010807e:	e8 13 05 00 00       	call   80108596 <freevm>
80108083:	83 c4 10             	add    $0x10,%esp
      return 0;
80108086:	b8 00 00 00 00       	mov    $0x0,%eax
8010808b:	eb 10                	jmp    8010809d <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010808d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108091:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108098:	72 a9                	jb     80108043 <setupkvm+0x3e>
    }
  return pgdir;
8010809a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010809d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080a0:	c9                   	leave  
801080a1:	c3                   	ret    

801080a2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080a2:	f3 0f 1e fb          	endbr32 
801080a6:	55                   	push   %ebp
801080a7:	89 e5                	mov    %esp,%ebp
801080a9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080ac:	e8 54 ff ff ff       	call   80108005 <setupkvm>
801080b1:	a3 44 75 11 80       	mov    %eax,0x80117544
  switchkvm();
801080b6:	e8 03 00 00 00       	call   801080be <switchkvm>
}
801080bb:	90                   	nop
801080bc:	c9                   	leave  
801080bd:	c3                   	ret    

801080be <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080be:	f3 0f 1e fb          	endbr32 
801080c2:	55                   	push   %ebp
801080c3:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801080c5:	a1 44 75 11 80       	mov    0x80117544,%eax
801080ca:	05 00 00 00 80       	add    $0x80000000,%eax
801080cf:	50                   	push   %eax
801080d0:	e8 74 fa ff ff       	call   80107b49 <lcr3>
801080d5:	83 c4 04             	add    $0x4,%esp
}
801080d8:	90                   	nop
801080d9:	c9                   	leave  
801080da:	c3                   	ret    

801080db <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080db:	f3 0f 1e fb          	endbr32 
801080df:	55                   	push   %ebp
801080e0:	89 e5                	mov    %esp,%ebp
801080e2:	56                   	push   %esi
801080e3:	53                   	push   %ebx
801080e4:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801080e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080eb:	75 0d                	jne    801080fa <switchuvm+0x1f>
    panic("switchuvm: no process");
801080ed:	83 ec 0c             	sub    $0xc,%esp
801080f0:	68 2a 93 10 80       	push   $0x8010932a
801080f5:	e8 0e 85 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801080fa:	8b 45 08             	mov    0x8(%ebp),%eax
801080fd:	8b 40 08             	mov    0x8(%eax),%eax
80108100:	85 c0                	test   %eax,%eax
80108102:	75 0d                	jne    80108111 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108104:	83 ec 0c             	sub    $0xc,%esp
80108107:	68 40 93 10 80       	push   $0x80109340
8010810c:	e8 f7 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108111:	8b 45 08             	mov    0x8(%ebp),%eax
80108114:	8b 40 04             	mov    0x4(%eax),%eax
80108117:	85 c0                	test   %eax,%eax
80108119:	75 0d                	jne    80108128 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010811b:	83 ec 0c             	sub    $0xc,%esp
8010811e:	68 55 93 10 80       	push   $0x80109355
80108123:	e8 e0 84 ff ff       	call   80100608 <panic>

  pushcli();
80108128:	e8 a6 d2 ff ff       	call   801053d3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010812d:	e8 fc c2 ff ff       	call   8010442e <mycpu>
80108132:	89 c3                	mov    %eax,%ebx
80108134:	e8 f5 c2 ff ff       	call   8010442e <mycpu>
80108139:	83 c0 08             	add    $0x8,%eax
8010813c:	89 c6                	mov    %eax,%esi
8010813e:	e8 eb c2 ff ff       	call   8010442e <mycpu>
80108143:	83 c0 08             	add    $0x8,%eax
80108146:	c1 e8 10             	shr    $0x10,%eax
80108149:	88 45 f7             	mov    %al,-0x9(%ebp)
8010814c:	e8 dd c2 ff ff       	call   8010442e <mycpu>
80108151:	83 c0 08             	add    $0x8,%eax
80108154:	c1 e8 18             	shr    $0x18,%eax
80108157:	89 c2                	mov    %eax,%edx
80108159:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108160:	67 00 
80108162:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108169:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010816d:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108173:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010817a:	83 e0 f0             	and    $0xfffffff0,%eax
8010817d:	83 c8 09             	or     $0x9,%eax
80108180:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108186:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010818d:	83 c8 10             	or     $0x10,%eax
80108190:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108196:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010819d:	83 e0 9f             	and    $0xffffff9f,%eax
801081a0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801081a6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801081ad:	83 c8 80             	or     $0xffffff80,%eax
801081b0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801081b6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081bd:	83 e0 f0             	and    $0xfffffff0,%eax
801081c0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081c6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081cd:	83 e0 ef             	and    $0xffffffef,%eax
801081d0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081d6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081dd:	83 e0 df             	and    $0xffffffdf,%eax
801081e0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081e6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081ed:	83 c8 40             	or     $0x40,%eax
801081f0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081f6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081fd:	83 e0 7f             	and    $0x7f,%eax
80108200:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108206:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010820c:	e8 1d c2 ff ff       	call   8010442e <mycpu>
80108211:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108218:	83 e2 ef             	and    $0xffffffef,%edx
8010821b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108221:	e8 08 c2 ff ff       	call   8010442e <mycpu>
80108226:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010822c:	8b 45 08             	mov    0x8(%ebp),%eax
8010822f:	8b 40 08             	mov    0x8(%eax),%eax
80108232:	89 c3                	mov    %eax,%ebx
80108234:	e8 f5 c1 ff ff       	call   8010442e <mycpu>
80108239:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010823f:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108242:	e8 e7 c1 ff ff       	call   8010442e <mycpu>
80108247:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010824d:	83 ec 0c             	sub    $0xc,%esp
80108250:	6a 28                	push   $0x28
80108252:	e8 db f8 ff ff       	call   80107b32 <ltr>
80108257:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010825a:	8b 45 08             	mov    0x8(%ebp),%eax
8010825d:	8b 40 04             	mov    0x4(%eax),%eax
80108260:	05 00 00 00 80       	add    $0x80000000,%eax
80108265:	83 ec 0c             	sub    $0xc,%esp
80108268:	50                   	push   %eax
80108269:	e8 db f8 ff ff       	call   80107b49 <lcr3>
8010826e:	83 c4 10             	add    $0x10,%esp
  popcli();
80108271:	e8 ae d1 ff ff       	call   80105424 <popcli>
}
80108276:	90                   	nop
80108277:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010827a:	5b                   	pop    %ebx
8010827b:	5e                   	pop    %esi
8010827c:	5d                   	pop    %ebp
8010827d:	c3                   	ret    

8010827e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010827e:	f3 0f 1e fb          	endbr32 
80108282:	55                   	push   %ebp
80108283:	89 e5                	mov    %esp,%ebp
80108285:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108288:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010828f:	76 0d                	jbe    8010829e <inituvm+0x20>
    panic("inituvm: more than a page");
80108291:	83 ec 0c             	sub    $0xc,%esp
80108294:	68 69 93 10 80       	push   $0x80109369
80108299:	e8 6a 83 ff ff       	call   80100608 <panic>
  mem = kalloc();
8010829e:	e8 69 ab ff ff       	call   80102e0c <kalloc>
801082a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082a6:	83 ec 04             	sub    $0x4,%esp
801082a9:	68 00 10 00 00       	push   $0x1000
801082ae:	6a 00                	push   $0x0
801082b0:	ff 75 f4             	pushl  -0xc(%ebp)
801082b3:	e8 2e d2 ff ff       	call   801054e6 <memset>
801082b8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082be:	05 00 00 00 80       	add    $0x80000000,%eax
801082c3:	83 ec 0c             	sub    $0xc,%esp
801082c6:	6a 06                	push   $0x6
801082c8:	50                   	push   %eax
801082c9:	68 00 10 00 00       	push   $0x1000
801082ce:	6a 00                	push   $0x0
801082d0:	ff 75 08             	pushl  0x8(%ebp)
801082d3:	e8 71 fc ff ff       	call   80107f49 <mappages>
801082d8:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801082db:	83 ec 04             	sub    $0x4,%esp
801082de:	ff 75 10             	pushl  0x10(%ebp)
801082e1:	ff 75 0c             	pushl  0xc(%ebp)
801082e4:	ff 75 f4             	pushl  -0xc(%ebp)
801082e7:	e8 c1 d2 ff ff       	call   801055ad <memmove>
801082ec:	83 c4 10             	add    $0x10,%esp
}
801082ef:	90                   	nop
801082f0:	c9                   	leave  
801082f1:	c3                   	ret    

801082f2 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082f2:	f3 0f 1e fb          	endbr32 
801082f6:	55                   	push   %ebp
801082f7:	89 e5                	mov    %esp,%ebp
801082f9:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ff:	25 ff 0f 00 00       	and    $0xfff,%eax
80108304:	85 c0                	test   %eax,%eax
80108306:	74 0d                	je     80108315 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108308:	83 ec 0c             	sub    $0xc,%esp
8010830b:	68 84 93 10 80       	push   $0x80109384
80108310:	e8 f3 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010831c:	e9 8f 00 00 00       	jmp    801083b0 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108321:	8b 55 0c             	mov    0xc(%ebp),%edx
80108324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108327:	01 d0                	add    %edx,%eax
80108329:	83 ec 04             	sub    $0x4,%esp
8010832c:	6a 00                	push   $0x0
8010832e:	50                   	push   %eax
8010832f:	ff 75 08             	pushl  0x8(%ebp)
80108332:	e8 78 fb ff ff       	call   80107eaf <walkpgdir>
80108337:	83 c4 10             	add    $0x10,%esp
8010833a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010833d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108341:	75 0d                	jne    80108350 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108343:	83 ec 0c             	sub    $0xc,%esp
80108346:	68 a7 93 10 80       	push   $0x801093a7
8010834b:	e8 b8 82 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108350:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108353:	8b 00                	mov    (%eax),%eax
80108355:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010835d:	8b 45 18             	mov    0x18(%ebp),%eax
80108360:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108363:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108368:	77 0b                	ja     80108375 <loaduvm+0x83>
      n = sz - i;
8010836a:	8b 45 18             	mov    0x18(%ebp),%eax
8010836d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108370:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108373:	eb 07                	jmp    8010837c <loaduvm+0x8a>
    else
      n = PGSIZE;
80108375:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010837c:	8b 55 14             	mov    0x14(%ebp),%edx
8010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108382:	01 d0                	add    %edx,%eax
80108384:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108387:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010838d:	ff 75 f0             	pushl  -0x10(%ebp)
80108390:	50                   	push   %eax
80108391:	52                   	push   %edx
80108392:	ff 75 10             	pushl  0x10(%ebp)
80108395:	e8 8a 9c ff ff       	call   80102024 <readi>
8010839a:	83 c4 10             	add    $0x10,%esp
8010839d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801083a0:	74 07                	je     801083a9 <loaduvm+0xb7>
      return -1;
801083a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083a7:	eb 18                	jmp    801083c1 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801083a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	3b 45 18             	cmp    0x18(%ebp),%eax
801083b6:	0f 82 65 ff ff ff    	jb     80108321 <loaduvm+0x2f>
  }
  return 0;
801083bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c1:	c9                   	leave  
801083c2:	c3                   	ret    

801083c3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c3:	f3 0f 1e fb          	endbr32 
801083c7:	55                   	push   %ebp
801083c8:	89 e5                	mov    %esp,%ebp
801083ca:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083cd:	8b 45 10             	mov    0x10(%ebp),%eax
801083d0:	85 c0                	test   %eax,%eax
801083d2:	79 0a                	jns    801083de <allocuvm+0x1b>
    return 0;
801083d4:	b8 00 00 00 00       	mov    $0x0,%eax
801083d9:	e9 ec 00 00 00       	jmp    801084ca <allocuvm+0x107>
  if(newsz < oldsz)
801083de:	8b 45 10             	mov    0x10(%ebp),%eax
801083e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083e4:	73 08                	jae    801083ee <allocuvm+0x2b>
    return oldsz;
801083e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e9:	e9 dc 00 00 00       	jmp    801084ca <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801083ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f1:	05 ff 0f 00 00       	add    $0xfff,%eax
801083f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083fe:	e9 b8 00 00 00       	jmp    801084bb <allocuvm+0xf8>
    mem = kalloc();
80108403:	e8 04 aa ff ff       	call   80102e0c <kalloc>
80108408:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010840b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840f:	75 2e                	jne    8010843f <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108411:	83 ec 0c             	sub    $0xc,%esp
80108414:	68 c5 93 10 80       	push   $0x801093c5
80108419:	e8 fa 7f ff ff       	call   80100418 <cprintf>
8010841e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108421:	83 ec 04             	sub    $0x4,%esp
80108424:	ff 75 0c             	pushl  0xc(%ebp)
80108427:	ff 75 10             	pushl  0x10(%ebp)
8010842a:	ff 75 08             	pushl  0x8(%ebp)
8010842d:	e8 9a 00 00 00       	call   801084cc <deallocuvm>
80108432:	83 c4 10             	add    $0x10,%esp
      return 0;
80108435:	b8 00 00 00 00       	mov    $0x0,%eax
8010843a:	e9 8b 00 00 00       	jmp    801084ca <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
8010843f:	83 ec 04             	sub    $0x4,%esp
80108442:	68 00 10 00 00       	push   $0x1000
80108447:	6a 00                	push   $0x0
80108449:	ff 75 f0             	pushl  -0x10(%ebp)
8010844c:	e8 95 d0 ff ff       	call   801054e6 <memset>
80108451:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108454:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108457:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	6a 06                	push   $0x6
80108465:	52                   	push   %edx
80108466:	68 00 10 00 00       	push   $0x1000
8010846b:	50                   	push   %eax
8010846c:	ff 75 08             	pushl  0x8(%ebp)
8010846f:	e8 d5 fa ff ff       	call   80107f49 <mappages>
80108474:	83 c4 20             	add    $0x20,%esp
80108477:	85 c0                	test   %eax,%eax
80108479:	79 39                	jns    801084b4 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010847b:	83 ec 0c             	sub    $0xc,%esp
8010847e:	68 dd 93 10 80       	push   $0x801093dd
80108483:	e8 90 7f ff ff       	call   80100418 <cprintf>
80108488:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010848b:	83 ec 04             	sub    $0x4,%esp
8010848e:	ff 75 0c             	pushl  0xc(%ebp)
80108491:	ff 75 10             	pushl  0x10(%ebp)
80108494:	ff 75 08             	pushl  0x8(%ebp)
80108497:	e8 30 00 00 00       	call   801084cc <deallocuvm>
8010849c:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010849f:	83 ec 0c             	sub    $0xc,%esp
801084a2:	ff 75 f0             	pushl  -0x10(%ebp)
801084a5:	e8 c4 a8 ff ff       	call   80102d6e <kfree>
801084aa:	83 c4 10             	add    $0x10,%esp
      return 0;
801084ad:	b8 00 00 00 00       	mov    $0x0,%eax
801084b2:	eb 16                	jmp    801084ca <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801084b4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084be:	3b 45 10             	cmp    0x10(%ebp),%eax
801084c1:	0f 82 3c ff ff ff    	jb     80108403 <allocuvm+0x40>
    }
  }
  return newsz;
801084c7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084ca:	c9                   	leave  
801084cb:	c3                   	ret    

801084cc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084cc:	f3 0f 1e fb          	endbr32 
801084d0:	55                   	push   %ebp
801084d1:	89 e5                	mov    %esp,%ebp
801084d3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084d6:	8b 45 10             	mov    0x10(%ebp),%eax
801084d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084dc:	72 08                	jb     801084e6 <deallocuvm+0x1a>
    return oldsz;
801084de:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e1:	e9 ae 00 00 00       	jmp    80108594 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
801084e6:	8b 45 10             	mov    0x10(%ebp),%eax
801084e9:	05 ff 0f 00 00       	add    $0xfff,%eax
801084ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084f6:	e9 8a 00 00 00       	jmp    80108585 <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	83 ec 04             	sub    $0x4,%esp
80108501:	6a 00                	push   $0x0
80108503:	50                   	push   %eax
80108504:	ff 75 08             	pushl  0x8(%ebp)
80108507:	e8 a3 f9 ff ff       	call   80107eaf <walkpgdir>
8010850c:	83 c4 10             	add    $0x10,%esp
8010850f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108512:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108516:	75 16                	jne    8010852e <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851b:	c1 e8 16             	shr    $0x16,%eax
8010851e:	83 c0 01             	add    $0x1,%eax
80108521:	c1 e0 16             	shl    $0x16,%eax
80108524:	2d 00 10 00 00       	sub    $0x1000,%eax
80108529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010852c:	eb 50                	jmp    8010857e <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
8010852e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108531:	8b 00                	mov    (%eax),%eax
80108533:	25 01 04 00 00       	and    $0x401,%eax
80108538:	85 c0                	test   %eax,%eax
8010853a:	74 42                	je     8010857e <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
8010853c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853f:	8b 00                	mov    (%eax),%eax
80108541:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108546:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108549:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010854d:	75 0d                	jne    8010855c <deallocuvm+0x90>
        panic("kfree");
8010854f:	83 ec 0c             	sub    $0xc,%esp
80108552:	68 f9 93 10 80       	push   $0x801093f9
80108557:	e8 ac 80 ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
8010855c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855f:	05 00 00 00 80       	add    $0x80000000,%eax
80108564:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108567:	83 ec 0c             	sub    $0xc,%esp
8010856a:	ff 75 e8             	pushl  -0x18(%ebp)
8010856d:	e8 fc a7 ff ff       	call   80102d6e <kfree>
80108572:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108578:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010857e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108588:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010858b:	0f 82 6a ff ff ff    	jb     801084fb <deallocuvm+0x2f>
    }
  }
  return newsz;
80108591:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108594:	c9                   	leave  
80108595:	c3                   	ret    

80108596 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108596:	f3 0f 1e fb          	endbr32 
8010859a:	55                   	push   %ebp
8010859b:	89 e5                	mov    %esp,%ebp
8010859d:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801085a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085a4:	75 0d                	jne    801085b3 <freevm+0x1d>
    panic("freevm: no pgdir");
801085a6:	83 ec 0c             	sub    $0xc,%esp
801085a9:	68 ff 93 10 80       	push   $0x801093ff
801085ae:	e8 55 80 ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085b3:	83 ec 04             	sub    $0x4,%esp
801085b6:	6a 00                	push   $0x0
801085b8:	68 00 00 00 80       	push   $0x80000000
801085bd:	ff 75 08             	pushl  0x8(%ebp)
801085c0:	e8 07 ff ff ff       	call   801084cc <deallocuvm>
801085c5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801085c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085cf:	eb 48                	jmp    80108619 <freevm+0x83>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
801085d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085db:	8b 45 08             	mov    0x8(%ebp),%eax
801085de:	01 d0                	add    %edx,%eax
801085e0:	8b 00                	mov    (%eax),%eax
801085e2:	83 e0 01             	and    $0x1,%eax
801085e5:	85 c0                	test   %eax,%eax
801085e7:	74 2c                	je     80108615 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085f3:	8b 45 08             	mov    0x8(%ebp),%eax
801085f6:	01 d0                	add    %edx,%eax
801085f8:	8b 00                	mov    (%eax),%eax
801085fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ff:	05 00 00 00 80       	add    $0x80000000,%eax
80108604:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108607:	83 ec 0c             	sub    $0xc,%esp
8010860a:	ff 75 f0             	pushl  -0x10(%ebp)
8010860d:	e8 5c a7 ff ff       	call   80102d6e <kfree>
80108612:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108619:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108620:	76 af                	jbe    801085d1 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108622:	83 ec 0c             	sub    $0xc,%esp
80108625:	ff 75 08             	pushl  0x8(%ebp)
80108628:	e8 41 a7 ff ff       	call   80102d6e <kfree>
8010862d:	83 c4 10             	add    $0x10,%esp
}
80108630:	90                   	nop
80108631:	c9                   	leave  
80108632:	c3                   	ret    

80108633 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108633:	f3 0f 1e fb          	endbr32 
80108637:	55                   	push   %ebp
80108638:	89 e5                	mov    %esp,%ebp
8010863a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010863d:	83 ec 04             	sub    $0x4,%esp
80108640:	6a 00                	push   $0x0
80108642:	ff 75 0c             	pushl  0xc(%ebp)
80108645:	ff 75 08             	pushl  0x8(%ebp)
80108648:	e8 62 f8 ff ff       	call   80107eaf <walkpgdir>
8010864d:	83 c4 10             	add    $0x10,%esp
80108650:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108653:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108657:	75 0d                	jne    80108666 <clearpteu+0x33>
    panic("clearpteu");
80108659:	83 ec 0c             	sub    $0xc,%esp
8010865c:	68 10 94 10 80       	push   $0x80109410
80108661:	e8 a2 7f ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	8b 00                	mov    (%eax),%eax
8010866b:	83 e0 fb             	and    $0xfffffffb,%eax
8010866e:	89 c2                	mov    %eax,%edx
80108670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108673:	89 10                	mov    %edx,(%eax)
}
80108675:	90                   	nop
80108676:	c9                   	leave  
80108677:	c3                   	ret    

80108678 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108678:	f3 0f 1e fb          	endbr32 
8010867c:	55                   	push   %ebp
8010867d:	89 e5                	mov    %esp,%ebp
8010867f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108682:	e8 7e f9 ff ff       	call   80108005 <setupkvm>
80108687:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010868a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010868e:	75 0a                	jne    8010869a <copyuvm+0x22>
    return 0;
80108690:	b8 00 00 00 00       	mov    $0x0,%eax
80108695:	e9 fa 00 00 00       	jmp    80108794 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010869a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a1:	e9 c9 00 00 00       	jmp    8010876f <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	83 ec 04             	sub    $0x4,%esp
801086ac:	6a 00                	push   $0x0
801086ae:	50                   	push   %eax
801086af:	ff 75 08             	pushl  0x8(%ebp)
801086b2:	e8 f8 f7 ff ff       	call   80107eaf <walkpgdir>
801086b7:	83 c4 10             	add    $0x10,%esp
801086ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086c1:	75 0d                	jne    801086d0 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801086c3:	83 ec 0c             	sub    $0xc,%esp
801086c6:	68 1a 94 10 80       	push   $0x8010941a
801086cb:	e8 38 7f ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
801086d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d3:	8b 00                	mov    (%eax),%eax
801086d5:	25 01 04 00 00       	and    $0x401,%eax
801086da:	85 c0                	test   %eax,%eax
801086dc:	75 0d                	jne    801086eb <copyuvm+0x73>
      panic("copyuvm: page not present");
801086de:	83 ec 0c             	sub    $0xc,%esp
801086e1:	68 34 94 10 80       	push   $0x80109434
801086e6:	e8 1d 7f ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801086eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ee:	8b 00                	mov    (%eax),%eax
801086f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086fb:	8b 00                	mov    (%eax),%eax
801086fd:	25 ff 0f 00 00       	and    $0xfff,%eax
80108702:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108705:	e8 02 a7 ff ff       	call   80102e0c <kalloc>
8010870a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010870d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108711:	74 6d                	je     80108780 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108713:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108716:	05 00 00 00 80       	add    $0x80000000,%eax
8010871b:	83 ec 04             	sub    $0x4,%esp
8010871e:	68 00 10 00 00       	push   $0x1000
80108723:	50                   	push   %eax
80108724:	ff 75 e0             	pushl  -0x20(%ebp)
80108727:	e8 81 ce ff ff       	call   801055ad <memmove>
8010872c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010872f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108732:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108735:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	83 ec 0c             	sub    $0xc,%esp
80108741:	52                   	push   %edx
80108742:	51                   	push   %ecx
80108743:	68 00 10 00 00       	push   $0x1000
80108748:	50                   	push   %eax
80108749:	ff 75 f0             	pushl  -0x10(%ebp)
8010874c:	e8 f8 f7 ff ff       	call   80107f49 <mappages>
80108751:	83 c4 20             	add    $0x20,%esp
80108754:	85 c0                	test   %eax,%eax
80108756:	79 10                	jns    80108768 <copyuvm+0xf0>
      kfree(mem);
80108758:	83 ec 0c             	sub    $0xc,%esp
8010875b:	ff 75 e0             	pushl  -0x20(%ebp)
8010875e:	e8 0b a6 ff ff       	call   80102d6e <kfree>
80108763:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108766:	eb 19                	jmp    80108781 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108768:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010876f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108772:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108775:	0f 82 2b ff ff ff    	jb     801086a6 <copyuvm+0x2e>
    }
  }
  return d;
8010877b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010877e:	eb 14                	jmp    80108794 <copyuvm+0x11c>
      goto bad;
80108780:	90                   	nop

bad:
  freevm(d);
80108781:	83 ec 0c             	sub    $0xc,%esp
80108784:	ff 75 f0             	pushl  -0x10(%ebp)
80108787:	e8 0a fe ff ff       	call   80108596 <freevm>
8010878c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010878f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108794:	c9                   	leave  
80108795:	c3                   	ret    

80108796 <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108796:	f3 0f 1e fb          	endbr32 
8010879a:	55                   	push   %ebp
8010879b:	89 e5                	mov    %esp,%ebp
8010879d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087a0:	83 ec 04             	sub    $0x4,%esp
801087a3:	6a 00                	push   $0x0
801087a5:	ff 75 0c             	pushl  0xc(%ebp)
801087a8:	ff 75 08             	pushl  0x8(%ebp)
801087ab:	e8 ff f6 ff ff       	call   80107eaf <walkpgdir>
801087b0:	83 c4 10             	add    $0x10,%esp
801087b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	8b 00                	mov    (%eax),%eax
801087bb:	25 01 04 00 00       	and    $0x401,%eax
801087c0:	85 c0                	test   %eax,%eax
801087c2:	75 07                	jne    801087cb <uva2ka+0x35>
    return 0;
801087c4:	b8 00 00 00 00       	mov    $0x0,%eax
801087c9:	eb 22                	jmp    801087ed <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	8b 00                	mov    (%eax),%eax
801087d0:	83 e0 04             	and    $0x4,%eax
801087d3:	85 c0                	test   %eax,%eax
801087d5:	75 07                	jne    801087de <uva2ka+0x48>
    return 0;
801087d7:	b8 00 00 00 00       	mov    $0x0,%eax
801087dc:	eb 0f                	jmp    801087ed <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	8b 00                	mov    (%eax),%eax
801087e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087e8:	05 00 00 00 80       	add    $0x80000000,%eax
}
801087ed:	c9                   	leave  
801087ee:	c3                   	ret    

801087ef <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087ef:	f3 0f 1e fb          	endbr32 
801087f3:	55                   	push   %ebp
801087f4:	89 e5                	mov    %esp,%ebp
801087f6:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087f9:	8b 45 10             	mov    0x10(%ebp),%eax
801087fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087ff:	eb 7f                	jmp    80108880 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108801:	8b 45 0c             	mov    0xc(%ebp),%eax
80108804:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108809:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
8010880c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880f:	83 ec 08             	sub    $0x8,%esp
80108812:	50                   	push   %eax
80108813:	ff 75 08             	pushl  0x8(%ebp)
80108816:	e8 7b ff ff ff       	call   80108796 <uva2ka>
8010881b:	83 c4 10             	add    $0x10,%esp
8010881e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108821:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108825:	75 07                	jne    8010882e <copyout+0x3f>
      return -1;
80108827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010882c:	eb 61                	jmp    8010888f <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
8010882e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108831:	2b 45 0c             	sub    0xc(%ebp),%eax
80108834:	05 00 10 00 00       	add    $0x1000,%eax
80108839:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010883c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883f:	3b 45 14             	cmp    0x14(%ebp),%eax
80108842:	76 06                	jbe    8010884a <copyout+0x5b>
      n = len;
80108844:	8b 45 14             	mov    0x14(%ebp),%eax
80108847:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010884a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010884d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108850:	89 c2                	mov    %eax,%edx
80108852:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108855:	01 d0                	add    %edx,%eax
80108857:	83 ec 04             	sub    $0x4,%esp
8010885a:	ff 75 f0             	pushl  -0x10(%ebp)
8010885d:	ff 75 f4             	pushl  -0xc(%ebp)
80108860:	50                   	push   %eax
80108861:	e8 47 cd ff ff       	call   801055ad <memmove>
80108866:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010886f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108872:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108878:	05 00 10 00 00       	add    $0x1000,%eax
8010887d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108880:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108884:	0f 85 77 ff ff ff    	jne    80108801 <copyout+0x12>
  }
  return 0;
8010888a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010888f:	c9                   	leave  
80108890:	c3                   	ret    

80108891 <mdecrypt>:


//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108891:	f3 0f 1e fb          	endbr32 
80108895:	55                   	push   %ebp
80108896:	89 e5                	mov    %esp,%ebp
80108898:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
8010889b:	e8 0a bc ff ff       	call   801044aa <myproc>
801088a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
801088a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a6:	8b 40 04             	mov    0x4(%eax),%eax
801088a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
801088ac:	83 ec 04             	sub    $0x4,%esp
801088af:	6a 00                	push   $0x0
801088b1:	ff 75 08             	pushl  0x8(%ebp)
801088b4:	ff 75 e8             	pushl  -0x18(%ebp)
801088b7:	e8 f3 f5 ff ff       	call   80107eaf <walkpgdir>
801088bc:	83 c4 10             	add    $0x10,%esp
801088bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
801088c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801088c6:	74 09                	je     801088d1 <mdecrypt+0x40>
801088c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088cb:	8b 00                	mov    (%eax),%eax
801088cd:	85 c0                	test   %eax,%eax
801088cf:	75 07                	jne    801088d8 <mdecrypt+0x47>
    return -1;
801088d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088d6:	eb 5d                	jmp    80108935 <mdecrypt+0xa4>
  }

  *pte = *pte & ~PTE_E;
801088d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088db:	8b 00                	mov    (%eax),%eax
801088dd:	80 e4 fb             	and    $0xfb,%ah
801088e0:	89 c2                	mov    %eax,%edx
801088e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088e5:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
801088e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088ea:	8b 00                	mov    (%eax),%eax
801088ec:	83 c8 01             	or     $0x1,%eax
801088ef:	89 c2                	mov    %eax,%edx
801088f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088f4:	89 10                	mov    %edx,(%eax)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
801088f6:	8b 45 08             	mov    0x8(%ebp),%eax
801088f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088fe:	89 45 08             	mov    %eax,0x8(%ebp)

  char * slider = virtual_addr;
80108901:	8b 45 08             	mov    0x8(%ebp),%eax
80108904:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108907:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010890e:	eb 17                	jmp    80108927 <mdecrypt+0x96>
    *slider = ~*slider;
80108910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108913:	0f b6 00             	movzbl (%eax),%eax
80108916:	f7 d0                	not    %eax
80108918:	89 c2                	mov    %eax,%edx
8010891a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891d:	88 10                	mov    %dl,(%eax)
    slider++;
8010891f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108923:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108927:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010892e:	7e e0                	jle    80108910 <mdecrypt+0x7f>
  }

  return 0;
80108930:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108935:	c9                   	leave  
80108936:	c3                   	ret    

80108937 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108937:	f3 0f 1e fb          	endbr32 
8010893b:	55                   	push   %ebp
8010893c:	89 e5                	mov    %esp,%ebp
8010893e:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108941:	e8 64 bb ff ff       	call   801044aa <myproc>
80108946:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108949:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010894c:	8b 40 04             	mov    0x4(%eax),%eax
8010894f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108952:	8b 45 08             	mov    0x8(%ebp),%eax
80108955:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010895a:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
8010895d:	8b 45 08             	mov    0x8(%ebp),%eax
80108960:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108963:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010896a:	eb 3f                	jmp    801089ab <mencrypt+0x74>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
8010896c:	83 ec 08             	sub    $0x8,%esp
8010896f:	ff 75 f4             	pushl  -0xc(%ebp)
80108972:	ff 75 e0             	pushl  -0x20(%ebp)
80108975:	e8 1c fe ff ff       	call   80108796 <uva2ka>
8010897a:	83 c4 10             	add    $0x10,%esp
8010897d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108980:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108984:	75 1a                	jne    801089a0 <mencrypt+0x69>
      cprintf("mencrypt: Could not access address\n");
80108986:	83 ec 0c             	sub    $0xc,%esp
80108989:	68 50 94 10 80       	push   $0x80109450
8010898e:	e8 85 7a ff ff       	call   80100418 <cprintf>
80108993:	83 c4 10             	add    $0x10,%esp
      return -1;
80108996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010899b:	e9 b8 00 00 00       	jmp    80108a58 <mencrypt+0x121>
    }
    slider = slider + PGSIZE;
801089a0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
801089a7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089b1:	7c b9                	jl     8010896c <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
801089b3:	8b 45 08             	mov    0x8(%ebp),%eax
801089b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
801089b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801089c0:	eb 78                	jmp    80108a3a <mencrypt+0x103>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
801089c2:	83 ec 04             	sub    $0x4,%esp
801089c5:	6a 00                	push   $0x0
801089c7:	ff 75 f4             	pushl  -0xc(%ebp)
801089ca:	ff 75 e0             	pushl  -0x20(%ebp)
801089cd:	e8 dd f4 ff ff       	call   80107eaf <walkpgdir>
801089d2:	83 c4 10             	add    $0x10,%esp
801089d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
801089d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089db:	8b 00                	mov    (%eax),%eax
801089dd:	25 00 04 00 00       	and    $0x400,%eax
801089e2:	85 c0                	test   %eax,%eax
801089e4:	74 09                	je     801089ef <mencrypt+0xb8>
      slider += PGSIZE;
801089e6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
801089ed:	eb 47                	jmp    80108a36 <mencrypt+0xff>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
801089ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801089f6:	eb 17                	jmp    80108a0f <mencrypt+0xd8>
      *slider = ~*slider;
801089f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fb:	0f b6 00             	movzbl (%eax),%eax
801089fe:	f7 d0                	not    %eax
80108a00:	89 c2                	mov    %eax,%edx
80108a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a05:	88 10                	mov    %dl,(%eax)
      slider++;
80108a07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108a0b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108a0f:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108a16:	7e e0                	jle    801089f8 <mencrypt+0xc1>
    }
    *mypte = *mypte & ~PTE_P;
80108a18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a1b:	8b 00                	mov    (%eax),%eax
80108a1d:	83 e0 fe             	and    $0xfffffffe,%eax
80108a20:	89 c2                	mov    %eax,%edx
80108a22:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a25:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
80108a27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a2a:	8b 00                	mov    (%eax),%eax
80108a2c:	80 cc 04             	or     $0x4,%ah
80108a2f:	89 c2                	mov    %eax,%edx
80108a31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a34:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
80108a36:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a3d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a40:	7c 80                	jl     801089c2 <mencrypt+0x8b>
  }

  switchuvm(myproc());
80108a42:	e8 63 ba ff ff       	call   801044aa <myproc>
80108a47:	83 ec 0c             	sub    $0xc,%esp
80108a4a:	50                   	push   %eax
80108a4b:	e8 8b f6 ff ff       	call   801080db <switchuvm>
80108a50:	83 c4 10             	add    $0x10,%esp
  return 0;
80108a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a58:	c9                   	leave  
80108a59:	c3                   	ret    

80108a5a <getpgtable>:

int getpgtable(struct pt_entry* entries, int num) {
80108a5a:	f3 0f 1e fb          	endbr32 
80108a5e:	55                   	push   %ebp
80108a5f:	89 e5                	mov    %esp,%ebp
80108a61:	83 ec 18             	sub    $0x18,%esp
  struct proc * me = myproc();
80108a64:	e8 41 ba ff ff       	call   801044aa <myproc>
80108a69:	89 45 ec             	mov    %eax,-0x14(%ebp)

  int index = 0;
80108a6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t * curr_pte;
  //reverse order

  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80108a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a76:	8b 00                	mov    (%eax),%eax
80108a78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a80:	e9 65 01 00 00       	jmp    80108bea <getpgtable+0x190>
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);
80108a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a88:	8b 40 04             	mov    0x4(%eax),%eax
80108a8b:	83 ec 04             	sub    $0x4,%esp
80108a8e:	6a 00                	push   $0x0
80108a90:	ff 75 f0             	pushl  -0x10(%ebp)
80108a93:	50                   	push   %eax
80108a94:	e8 16 f4 ff ff       	call   80107eaf <walkpgdir>
80108a99:	83 c4 10             	add    $0x10,%esp
80108a9c:	89 45 e8             	mov    %eax,-0x18(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
80108a9f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108aa3:	0f 84 3a 01 00 00    	je     80108be3 <getpgtable+0x189>
80108aa9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aac:	8b 00                	mov    (%eax),%eax
80108aae:	85 c0                	test   %eax,%eax
80108ab0:	0f 84 2d 01 00 00    	je     80108be3 <getpgtable+0x189>
      //this is the same for all pt_entries... right?
      entries[index].pdx = PDX(i); 
80108ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab9:	c1 e8 16             	shr    $0x16,%eax
80108abc:	89 c1                	mov    %eax,%ecx
80108abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80108acb:	01 c2                	add    %eax,%edx
80108acd:	89 c8                	mov    %ecx,%eax
80108acf:	66 25 ff 03          	and    $0x3ff,%ax
80108ad3:	66 25 ff 03          	and    $0x3ff,%ax
80108ad7:	89 c1                	mov    %eax,%ecx
80108ad9:	0f b7 02             	movzwl (%edx),%eax
80108adc:	66 25 00 fc          	and    $0xfc00,%ax
80108ae0:	09 c8                	or     %ecx,%eax
80108ae2:	66 89 02             	mov    %ax,(%edx)
      entries[index].ptx = PTX(i);
80108ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae8:	c1 e8 0c             	shr    $0xc,%eax
80108aeb:	89 c1                	mov    %eax,%ecx
80108aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108af7:	8b 45 08             	mov    0x8(%ebp),%eax
80108afa:	01 c2                	add    %eax,%edx
80108afc:	89 c8                	mov    %ecx,%eax
80108afe:	66 25 ff 03          	and    $0x3ff,%ax
80108b02:	0f b7 c0             	movzwl %ax,%eax
80108b05:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b0a:	c1 e0 0a             	shl    $0xa,%eax
80108b0d:	89 c1                	mov    %eax,%ecx
80108b0f:	8b 02                	mov    (%edx),%eax
80108b11:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108b16:	09 c8                	or     %ecx,%eax
80108b18:	89 02                	mov    %eax,(%edx)
      //convert to physical addr then shift to get PPN 
      entries[index].ppage = PPN(*curr_pte);
80108b1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b1d:	8b 00                	mov    (%eax),%eax
80108b1f:	c1 e8 0c             	shr    $0xc,%eax
80108b22:	89 c2                	mov    %eax,%edx
80108b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b27:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108b31:	01 c8                	add    %ecx,%eax
80108b33:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80108b39:	89 d1                	mov    %edx,%ecx
80108b3b:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80108b41:	8b 50 04             	mov    0x4(%eax),%edx
80108b44:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80108b4a:	09 ca                	or     %ecx,%edx
80108b4c:	89 50 04             	mov    %edx,0x4(%eax)
      //have to set it like this because these are 1 bit wide fields
      entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
80108b4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b52:	8b 08                	mov    (%eax),%ecx
80108b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b57:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80108b61:	01 c2                	add    %eax,%edx
80108b63:	89 c8                	mov    %ecx,%eax
80108b65:	83 e0 01             	and    $0x1,%eax
80108b68:	83 e0 01             	and    $0x1,%eax
80108b6b:	c1 e0 04             	shl    $0x4,%eax
80108b6e:	89 c1                	mov    %eax,%ecx
80108b70:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108b74:	83 e0 ef             	and    $0xffffffef,%eax
80108b77:	09 c8                	or     %ecx,%eax
80108b79:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
80108b7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b7f:	8b 00                	mov    (%eax),%eax
80108b81:	d1 e8                	shr    %eax
80108b83:	89 c1                	mov    %eax,%ecx
80108b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b88:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108b92:	01 c2                	add    %eax,%edx
80108b94:	89 c8                	mov    %ecx,%eax
80108b96:	83 e0 01             	and    $0x1,%eax
80108b99:	83 e0 01             	and    $0x1,%eax
80108b9c:	c1 e0 05             	shl    $0x5,%eax
80108b9f:	89 c1                	mov    %eax,%ecx
80108ba1:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108ba5:	83 e0 df             	and    $0xffffffdf,%eax
80108ba8:	09 c8                	or     %ecx,%eax
80108baa:	88 42 06             	mov    %al,0x6(%edx)
      entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
80108bad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bb0:	8b 00                	mov    (%eax),%eax
80108bb2:	c1 e8 0a             	shr    $0xa,%eax
80108bb5:	89 c1                	mov    %eax,%ecx
80108bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80108bc4:	01 c2                	add    %eax,%edx
80108bc6:	89 c8                	mov    %ecx,%eax
80108bc8:	83 e0 01             	and    $0x1,%eax
80108bcb:	83 e0 01             	and    $0x1,%eax
80108bce:	c1 e0 06             	shl    $0x6,%eax
80108bd1:	89 c1                	mov    %eax,%ecx
80108bd3:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108bd7:	83 e0 bf             	and    $0xffffffbf,%eax
80108bda:	09 c8                	or     %ecx,%eax
80108bdc:	88 42 06             	mov    %al,0x6(%edx)
      index++;
80108bdf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80108be3:	81 6d f0 00 10 00 00 	subl   $0x1000,-0x10(%ebp)
80108bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bed:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108bf0:	0f 8c 8f fe ff ff    	jl     80108a85 <getpgtable+0x2b>
    }
  }
  //index is the number of ptes copied
  return index;
80108bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108bf9:	c9                   	leave  
80108bfa:	c3                   	ret    

80108bfb <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
80108bfb:	f3 0f 1e fb          	endbr32 
80108bff:	55                   	push   %ebp
80108c00:	89 e5                	mov    %esp,%ebp
80108c02:	56                   	push   %esi
80108c03:	53                   	push   %ebx
80108c04:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
80108c07:	8b 45 08             	mov    0x8(%ebp),%eax
80108c0a:	05 00 00 00 80       	add    $0x80000000,%eax
80108c0f:	89 c6                	mov    %eax,%esi
80108c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80108c14:	e8 91 b8 ff ff       	call   801044aa <myproc>
80108c19:	8b 40 04             	mov    0x4(%eax),%eax
80108c1c:	68 00 10 00 00       	push   $0x1000
80108c21:	56                   	push   %esi
80108c22:	53                   	push   %ebx
80108c23:	50                   	push   %eax
80108c24:	e8 c6 fb ff ff       	call   801087ef <copyout>
80108c29:	83 c4 10             	add    $0x10,%esp
80108c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80108c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c33:	74 07                	je     80108c3c <dump_rawphymem+0x41>
    return -1;
80108c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c3a:	eb 05                	jmp    80108c41 <dump_rawphymem+0x46>
  return 0;
80108c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c41:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c44:	5b                   	pop    %ebx
80108c45:	5e                   	pop    %esi
80108c46:	5d                   	pop    %ebp
80108c47:	c3                   	ret    
