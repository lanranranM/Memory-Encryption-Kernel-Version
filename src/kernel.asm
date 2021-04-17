
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
8010002d:	b8 1e 3a 10 80       	mov    $0x80103a1e,%eax
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
80100041:	68 7c 92 10 80       	push   $0x8010927c
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 8b 52 00 00       	call   801052db <initlock>
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
8010008f:	68 83 92 10 80       	push   $0x80109283
80100094:	50                   	push   %eax
80100095:	e8 ae 50 00 00       	call   80105148 <initsleeplock>
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
801000d7:	e8 25 52 00 00       	call   80105301 <acquire>
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
80100116:	e8 58 52 00 00       	call   80105373 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 5b 50 00 00       	call   80105188 <acquiresleep>
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
80100197:	e8 d7 51 00 00       	call   80105373 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 da 4f 00 00       	call   80105188 <acquiresleep>
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
801001cb:	68 8a 92 10 80       	push   $0x8010928a
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
80100207:	e8 97 28 00 00       	call   80102aa3 <iderw>
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
80100228:	e8 15 50 00 00       	call   80105242 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 9b 92 10 80       	push   $0x8010929b
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
80100256:	e8 48 28 00 00       	call   80102aa3 <iderw>
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
80100275:	e8 c8 4f 00 00       	call   80105242 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 a2 92 10 80       	push   $0x801092a2
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 53 4f 00 00       	call   801051f0 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 54 50 00 00       	call   80105301 <acquire>
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
80100318:	e8 56 50 00 00       	call   80105373 <release>
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
80100438:	e8 0b 50 00 00       	call   80105448 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 b0 4e 00 00       	call   80105301 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 ac 92 10 80       	push   $0x801092ac
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
801004ee:	8b 04 85 bc 92 10 80 	mov    -0x7fef6d44(,%eax,4),%eax
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
8010054c:	c7 45 ec b5 92 10 80 	movl   $0x801092b5,-0x14(%ebp)
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
801005fd:	e8 71 4d 00 00       	call   80105373 <release>
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
80100621:	e8 49 2b 00 00       	call   8010316f <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 14 93 10 80       	push   $0x80109314
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
80100649:	68 28 93 10 80       	push   $0x80109328
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 63 4d 00 00       	call   801053c9 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 2a 93 10 80       	push   $0x8010932a
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
80100772:	68 2e 93 10 80       	push   $0x8010932e
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
8010079f:	e8 c3 4e 00 00       	call   80105667 <memmove>
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
801007c9:	e8 d2 4d 00 00       	call   801055a0 <memset>
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
80100865:	e8 32 68 00 00       	call   8010709c <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 25 68 00 00       	call   8010709c <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 18 68 00 00       	call   8010709c <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 08 68 00 00       	call   8010709c <uartputc>
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
801008c1:	e8 3b 4a 00 00       	call   80105301 <acquire>
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
80100a17:	e8 57 45 00 00       	call   80104f73 <wakeup>
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
80100a3a:	e8 34 49 00 00       	call   80105373 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 fa 45 00 00       	call   80105047 <procdump>
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
80100a60:	e8 c4 11 00 00       	call   80101c29 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 86 48 00 00       	call   80105301 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 18 3a 00 00       	call   801044a0 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 d7 48 00 00       	call   80105373 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 68 10 00 00       	call   80101b12 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 b8 43 00 00       	call   80104e81 <sleep>
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
80100b42:	e8 2c 48 00 00       	call   80105373 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 bd 0f 00 00       	call   80101b12 <ilock>
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
80100b74:	e8 b0 10 00 00       	call   80101c29 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 78 47 00 00       	call   80105301 <acquire>
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
80100bc6:	e8 a8 47 00 00       	call   80105373 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 39 0f 00 00       	call   80101b12 <ilock>
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
80100bee:	68 41 93 10 80       	push   $0x80109341
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 de 46 00 00       	call   801052db <initlock>
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
80100c25:	e8 52 20 00 00       	call   80102c7c <ioapicenable>
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
80100c3d:	e8 5e 38 00 00       	call   801044a0 <myproc>
80100c42:	89 45 cc             	mov    %eax,-0x34(%ebp)

  begin_op();
80100c45:	e8 97 2a 00 00       	call   801036e1 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 28 1a 00 00       	call   8010267d <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 0b 2b 00 00       	call   80103771 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 49 93 10 80       	push   $0x80109349
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 28 04 00 00       	jmp    801010a8 <exec+0x478>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 87 0e 00 00       	call   80101b12 <ilock>
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
80100ca3:	e8 72 13 00 00       	call   8010201a <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 9d 03 00 00    	jne    80101051 <exec+0x421>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 8f 03 00 00    	jne    80101054 <exec+0x424>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 0e 74 00 00       	call   801080d8 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 80 03 00 00    	je     80101057 <exec+0x427>
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
80100d03:	e8 12 13 00 00       	call   8010201a <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 46 03 00 00    	jne    8010105a <exec+0x42a>
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
80100d31:	0f 82 26 03 00 00    	jb     8010105d <exec+0x42d>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d3d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 0d 03 00 00    	jb     80101060 <exec+0x430>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d59:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 26 77 00 00       	call   80108496 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 e3 02 00 00    	je     80101063 <exec+0x433>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 d3 02 00 00    	jne    80101066 <exec+0x436>
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
80100db1:	e8 0f 76 00 00       	call   801083c5 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 a8 02 00 00    	js     80101069 <exec+0x439>
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
80100dea:	e8 60 0f 00 00       	call   80101d4f <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 7a 29 00 00       	call   80103771 <end_op>
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
80100e20:	e8 71 76 00 00       	call   80108496 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 37 02 00 00    	je     8010106c <exec+0x43c>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 cb 78 00 00       	call   80108714 <clearpteu>
80100e49:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  //p6-melody-changes
  //int record_sz=sz;
  //ends
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e59:	e9 96 00 00 00       	jmp    80100ef4 <exec+0x2c4>
    if(argc >= MAXARG)
80100e5e:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e62:	0f 87 07 02 00 00    	ja     8010106f <exec+0x43f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 87 49 00 00       	call   80105809 <strlen>
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
80100eaa:	e8 5a 49 00 00       	call   80105809 <strlen>
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
80100ed0:	e8 fb 79 00 00       	call   801088d0 <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 92 01 00 00    	js     80101072 <exec+0x442>
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
80100f6c:	e8 5f 79 00 00       	call   801088d0 <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 f9 00 00 00    	js     80101075 <exec+0x445>
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
80100fab:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fae:	83 c0 6c             	add    $0x6c,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 fc 47 00 00       	call   801057bb <safestrcpy>
80100fbf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  cq_init(curproc);
80100fc2:	83 ec 0c             	sub    $0xc,%esp
80100fc5:	ff 75 cc             	pushl  -0x34(%ebp)
80100fc8:	e8 a5 79 00 00       	call   80108972 <cq_init>
80100fcd:	83 c4 10             	add    $0x10,%esp
  oldpgdir = curproc->pgdir;
80100fd0:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fd3:	8b 40 04             	mov    0x4(%eax),%eax
80100fd6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100fd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fdc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fdf:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fe2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fe5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fe8:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fea:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fed:	8b 40 18             	mov    0x18(%eax),%eax
80100ff0:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100ff6:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ff9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100ffc:	8b 40 18             	mov    0x18(%eax),%eax
80100fff:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101002:	89 50 44             	mov    %edx,0x44(%eax)
  
  switchuvm(curproc);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 cc             	pushl  -0x34(%ebp)
8010100b:	e8 9e 71 00 00       	call   801081ae <switchuvm>
80101010:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<sz;i+=PGSIZE)
80101013:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010101a:	eb 18                	jmp    80101034 <exec+0x404>
    mencrypt((char*)i,1);
8010101c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101f:	83 ec 08             	sub    $0x8,%esp
80101022:	6a 01                	push   $0x1
80101024:	50                   	push   %eax
80101025:	e8 48 7e 00 00       	call   80108e72 <mencrypt>
8010102a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<sz;i+=PGSIZE)
8010102d:	81 45 d0 00 10 00 00 	addl   $0x1000,-0x30(%ebp)
80101034:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101037:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010103a:	77 e0                	ja     8010101c <exec+0x3ec>
  freevm(oldpgdir);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	ff 75 c8             	pushl  -0x38(%ebp)
80101042:	e8 30 76 00 00       	call   80108677 <freevm>
80101047:	83 c4 10             	add    $0x10,%esp
  //p6 melody changes
  //uint page_num=1;
  //cprintf("exec-page_num:%d\n",page_num);
  //if(mencrypt((char*)PGROUNDUP(sz-PGSIZE),page_num)!=0) return -1;
  //ends
  return 0;
8010104a:	b8 00 00 00 00       	mov    $0x0,%eax
8010104f:	eb 57                	jmp    801010a8 <exec+0x478>
    goto bad;
80101051:	90                   	nop
80101052:	eb 22                	jmp    80101076 <exec+0x446>
    goto bad;
80101054:	90                   	nop
80101055:	eb 1f                	jmp    80101076 <exec+0x446>
    goto bad;
80101057:	90                   	nop
80101058:	eb 1c                	jmp    80101076 <exec+0x446>
      goto bad;
8010105a:	90                   	nop
8010105b:	eb 19                	jmp    80101076 <exec+0x446>
      goto bad;
8010105d:	90                   	nop
8010105e:	eb 16                	jmp    80101076 <exec+0x446>
      goto bad;
80101060:	90                   	nop
80101061:	eb 13                	jmp    80101076 <exec+0x446>
      goto bad;
80101063:	90                   	nop
80101064:	eb 10                	jmp    80101076 <exec+0x446>
      goto bad;
80101066:	90                   	nop
80101067:	eb 0d                	jmp    80101076 <exec+0x446>
      goto bad;
80101069:	90                   	nop
8010106a:	eb 0a                	jmp    80101076 <exec+0x446>
    goto bad;
8010106c:	90                   	nop
8010106d:	eb 07                	jmp    80101076 <exec+0x446>
      goto bad;
8010106f:	90                   	nop
80101070:	eb 04                	jmp    80101076 <exec+0x446>
      goto bad;
80101072:	90                   	nop
80101073:	eb 01                	jmp    80101076 <exec+0x446>
    goto bad;
80101075:	90                   	nop

 bad:
  if(pgdir)
80101076:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010107a:	74 0e                	je     8010108a <exec+0x45a>
    freevm(pgdir);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101082:	e8 f0 75 00 00       	call   80108677 <freevm>
80101087:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010108a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010108e:	74 13                	je     801010a3 <exec+0x473>
    iunlockput(ip);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	ff 75 d8             	pushl  -0x28(%ebp)
80101096:	e8 b4 0c 00 00       	call   80101d4f <iunlockput>
8010109b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010109e:	e8 ce 26 00 00       	call   80103771 <end_op>
  }
  return -1;
801010a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010a8:	c9                   	leave  
801010a9:	c3                   	ret    

801010aa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010aa:	f3 0f 1e fb          	endbr32 
801010ae:	55                   	push   %ebp
801010af:	89 e5                	mov    %esp,%ebp
801010b1:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010b4:	83 ec 08             	sub    $0x8,%esp
801010b7:	68 55 93 10 80       	push   $0x80109355
801010bc:	68 60 20 11 80       	push   $0x80112060
801010c1:	e8 15 42 00 00       	call   801052db <initlock>
801010c6:	83 c4 10             	add    $0x10,%esp
}
801010c9:	90                   	nop
801010ca:	c9                   	leave  
801010cb:	c3                   	ret    

801010cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010cc:	f3 0f 1e fb          	endbr32 
801010d0:	55                   	push   %ebp
801010d1:	89 e5                	mov    %esp,%ebp
801010d3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010d6:	83 ec 0c             	sub    $0xc,%esp
801010d9:	68 60 20 11 80       	push   $0x80112060
801010de:	e8 1e 42 00 00       	call   80105301 <acquire>
801010e3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010e6:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010ed:	eb 2d                	jmp    8010111c <filealloc+0x50>
    if(f->ref == 0){
801010ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f2:	8b 40 04             	mov    0x4(%eax),%eax
801010f5:	85 c0                	test   %eax,%eax
801010f7:	75 1f                	jne    80101118 <filealloc+0x4c>
      f->ref = 1;
801010f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010fc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101103:	83 ec 0c             	sub    $0xc,%esp
80101106:	68 60 20 11 80       	push   $0x80112060
8010110b:	e8 63 42 00 00       	call   80105373 <release>
80101110:	83 c4 10             	add    $0x10,%esp
      return f;
80101113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101116:	eb 23                	jmp    8010113b <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101118:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010111c:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101121:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101124:	72 c9                	jb     801010ef <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	68 60 20 11 80       	push   $0x80112060
8010112e:	e8 40 42 00 00       	call   80105373 <release>
80101133:	83 c4 10             	add    $0x10,%esp
  return 0;
80101136:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010113b:	c9                   	leave  
8010113c:	c3                   	ret    

8010113d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010113d:	f3 0f 1e fb          	endbr32 
80101141:	55                   	push   %ebp
80101142:	89 e5                	mov    %esp,%ebp
80101144:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101147:	83 ec 0c             	sub    $0xc,%esp
8010114a:	68 60 20 11 80       	push   $0x80112060
8010114f:	e8 ad 41 00 00       	call   80105301 <acquire>
80101154:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 04             	mov    0x4(%eax),%eax
8010115d:	85 c0                	test   %eax,%eax
8010115f:	7f 0d                	jg     8010116e <filedup+0x31>
    panic("filedup");
80101161:	83 ec 0c             	sub    $0xc,%esp
80101164:	68 5c 93 10 80       	push   $0x8010935c
80101169:	e8 9a f4 ff ff       	call   80100608 <panic>
  f->ref++;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	8b 40 04             	mov    0x4(%eax),%eax
80101174:	8d 50 01             	lea    0x1(%eax),%edx
80101177:	8b 45 08             	mov    0x8(%ebp),%eax
8010117a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010117d:	83 ec 0c             	sub    $0xc,%esp
80101180:	68 60 20 11 80       	push   $0x80112060
80101185:	e8 e9 41 00 00       	call   80105373 <release>
8010118a:	83 c4 10             	add    $0x10,%esp
  return f;
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101190:	c9                   	leave  
80101191:	c3                   	ret    

80101192 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101192:	f3 0f 1e fb          	endbr32 
80101196:	55                   	push   %ebp
80101197:	89 e5                	mov    %esp,%ebp
80101199:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010119c:	83 ec 0c             	sub    $0xc,%esp
8010119f:	68 60 20 11 80       	push   $0x80112060
801011a4:	e8 58 41 00 00       	call   80105301 <acquire>
801011a9:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	8b 40 04             	mov    0x4(%eax),%eax
801011b2:	85 c0                	test   %eax,%eax
801011b4:	7f 0d                	jg     801011c3 <fileclose+0x31>
    panic("fileclose");
801011b6:	83 ec 0c             	sub    $0xc,%esp
801011b9:	68 64 93 10 80       	push   $0x80109364
801011be:	e8 45 f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	8b 40 04             	mov    0x4(%eax),%eax
801011c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	89 50 04             	mov    %edx,0x4(%eax)
801011d2:	8b 45 08             	mov    0x8(%ebp),%eax
801011d5:	8b 40 04             	mov    0x4(%eax),%eax
801011d8:	85 c0                	test   %eax,%eax
801011da:	7e 15                	jle    801011f1 <fileclose+0x5f>
    release(&ftable.lock);
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	68 60 20 11 80       	push   $0x80112060
801011e4:	e8 8a 41 00 00       	call   80105373 <release>
801011e9:	83 c4 10             	add    $0x10,%esp
801011ec:	e9 8b 00 00 00       	jmp    8010127c <fileclose+0xea>
    return;
  }
  ff = *f;
801011f1:	8b 45 08             	mov    0x8(%ebp),%eax
801011f4:	8b 10                	mov    (%eax),%edx
801011f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011f9:	8b 50 04             	mov    0x4(%eax),%edx
801011fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011ff:	8b 50 08             	mov    0x8(%eax),%edx
80101202:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101205:	8b 50 0c             	mov    0xc(%eax),%edx
80101208:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010120b:	8b 50 10             	mov    0x10(%eax),%edx
8010120e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101211:	8b 40 14             	mov    0x14(%eax),%eax
80101214:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101217:	8b 45 08             	mov    0x8(%ebp),%eax
8010121a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101221:	8b 45 08             	mov    0x8(%ebp),%eax
80101224:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	68 60 20 11 80       	push   $0x80112060
80101232:	e8 3c 41 00 00       	call   80105373 <release>
80101237:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010123a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010123d:	83 f8 01             	cmp    $0x1,%eax
80101240:	75 19                	jne    8010125b <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101242:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101246:	0f be d0             	movsbl %al,%edx
80101249:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124c:	83 ec 08             	sub    $0x8,%esp
8010124f:	52                   	push   %edx
80101250:	50                   	push   %eax
80101251:	e8 c1 2e 00 00       	call   80104117 <pipeclose>
80101256:	83 c4 10             	add    $0x10,%esp
80101259:	eb 21                	jmp    8010127c <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010125b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010125e:	83 f8 02             	cmp    $0x2,%eax
80101261:	75 19                	jne    8010127c <fileclose+0xea>
    begin_op();
80101263:	e8 79 24 00 00       	call   801036e1 <begin_op>
    iput(ff.ip);
80101268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010126b:	83 ec 0c             	sub    $0xc,%esp
8010126e:	50                   	push   %eax
8010126f:	e8 07 0a 00 00       	call   80101c7b <iput>
80101274:	83 c4 10             	add    $0x10,%esp
    end_op();
80101277:	e8 f5 24 00 00       	call   80103771 <end_op>
  }
}
8010127c:	c9                   	leave  
8010127d:	c3                   	ret    

8010127e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010127e:	f3 0f 1e fb          	endbr32 
80101282:	55                   	push   %ebp
80101283:	89 e5                	mov    %esp,%ebp
80101285:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 00                	mov    (%eax),%eax
8010128d:	83 f8 02             	cmp    $0x2,%eax
80101290:	75 40                	jne    801012d2 <filestat+0x54>
    ilock(f->ip);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	83 ec 0c             	sub    $0xc,%esp
8010129b:	50                   	push   %eax
8010129c:	e8 71 08 00 00       	call   80101b12 <ilock>
801012a1:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012a4:	8b 45 08             	mov    0x8(%ebp),%eax
801012a7:	8b 40 10             	mov    0x10(%eax),%eax
801012aa:	83 ec 08             	sub    $0x8,%esp
801012ad:	ff 75 0c             	pushl  0xc(%ebp)
801012b0:	50                   	push   %eax
801012b1:	e8 1a 0d 00 00       	call   80101fd0 <stati>
801012b6:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 40 10             	mov    0x10(%eax),%eax
801012bf:	83 ec 0c             	sub    $0xc,%esp
801012c2:	50                   	push   %eax
801012c3:	e8 61 09 00 00       	call   80101c29 <iunlock>
801012c8:	83 c4 10             	add    $0x10,%esp
    return 0;
801012cb:	b8 00 00 00 00       	mov    $0x0,%eax
801012d0:	eb 05                	jmp    801012d7 <filestat+0x59>
  }
  return -1;
801012d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012d7:	c9                   	leave  
801012d8:	c3                   	ret    

801012d9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012d9:	f3 0f 1e fb          	endbr32 
801012dd:	55                   	push   %ebp
801012de:	89 e5                	mov    %esp,%ebp
801012e0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012ea:	84 c0                	test   %al,%al
801012ec:	75 0a                	jne    801012f8 <fileread+0x1f>
    return -1;
801012ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f3:	e9 9b 00 00 00       	jmp    80101393 <fileread+0xba>
  if(f->type == FD_PIPE)
801012f8:	8b 45 08             	mov    0x8(%ebp),%eax
801012fb:	8b 00                	mov    (%eax),%eax
801012fd:	83 f8 01             	cmp    $0x1,%eax
80101300:	75 1a                	jne    8010131c <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101302:	8b 45 08             	mov    0x8(%ebp),%eax
80101305:	8b 40 0c             	mov    0xc(%eax),%eax
80101308:	83 ec 04             	sub    $0x4,%esp
8010130b:	ff 75 10             	pushl  0x10(%ebp)
8010130e:	ff 75 0c             	pushl  0xc(%ebp)
80101311:	50                   	push   %eax
80101312:	e8 b5 2f 00 00       	call   801042cc <piperead>
80101317:	83 c4 10             	add    $0x10,%esp
8010131a:	eb 77                	jmp    80101393 <fileread+0xba>
  if(f->type == FD_INODE){
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 00                	mov    (%eax),%eax
80101321:	83 f8 02             	cmp    $0x2,%eax
80101324:	75 60                	jne    80101386 <fileread+0xad>
    ilock(f->ip);
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	83 ec 0c             	sub    $0xc,%esp
8010132f:	50                   	push   %eax
80101330:	e8 dd 07 00 00       	call   80101b12 <ilock>
80101335:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101338:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010133b:	8b 45 08             	mov    0x8(%ebp),%eax
8010133e:	8b 50 14             	mov    0x14(%eax),%edx
80101341:	8b 45 08             	mov    0x8(%ebp),%eax
80101344:	8b 40 10             	mov    0x10(%eax),%eax
80101347:	51                   	push   %ecx
80101348:	52                   	push   %edx
80101349:	ff 75 0c             	pushl  0xc(%ebp)
8010134c:	50                   	push   %eax
8010134d:	e8 c8 0c 00 00       	call   8010201a <readi>
80101352:	83 c4 10             	add    $0x10,%esp
80101355:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101358:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010135c:	7e 11                	jle    8010136f <fileread+0x96>
      f->off += r;
8010135e:	8b 45 08             	mov    0x8(%ebp),%eax
80101361:	8b 50 14             	mov    0x14(%eax),%edx
80101364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101367:	01 c2                	add    %eax,%edx
80101369:	8b 45 08             	mov    0x8(%ebp),%eax
8010136c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	8b 40 10             	mov    0x10(%eax),%eax
80101375:	83 ec 0c             	sub    $0xc,%esp
80101378:	50                   	push   %eax
80101379:	e8 ab 08 00 00       	call   80101c29 <iunlock>
8010137e:	83 c4 10             	add    $0x10,%esp
    return r;
80101381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101384:	eb 0d                	jmp    80101393 <fileread+0xba>
  }
  panic("fileread");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 6e 93 10 80       	push   $0x8010936e
8010138e:	e8 75 f2 ff ff       	call   80100608 <panic>
}
80101393:	c9                   	leave  
80101394:	c3                   	ret    

80101395 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101395:	f3 0f 1e fb          	endbr32 
80101399:	55                   	push   %ebp
8010139a:	89 e5                	mov    %esp,%ebp
8010139c:	53                   	push   %ebx
8010139d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013a7:	84 c0                	test   %al,%al
801013a9:	75 0a                	jne    801013b5 <filewrite+0x20>
    return -1;
801013ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013b0:	e9 1b 01 00 00       	jmp    801014d0 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013b5:	8b 45 08             	mov    0x8(%ebp),%eax
801013b8:	8b 00                	mov    (%eax),%eax
801013ba:	83 f8 01             	cmp    $0x1,%eax
801013bd:	75 1d                	jne    801013dc <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 0c             	mov    0xc(%eax),%eax
801013c5:	83 ec 04             	sub    $0x4,%esp
801013c8:	ff 75 10             	pushl  0x10(%ebp)
801013cb:	ff 75 0c             	pushl  0xc(%ebp)
801013ce:	50                   	push   %eax
801013cf:	e8 f2 2d 00 00       	call   801041c6 <pipewrite>
801013d4:	83 c4 10             	add    $0x10,%esp
801013d7:	e9 f4 00 00 00       	jmp    801014d0 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013dc:	8b 45 08             	mov    0x8(%ebp),%eax
801013df:	8b 00                	mov    (%eax),%eax
801013e1:	83 f8 02             	cmp    $0x2,%eax
801013e4:	0f 85 d9 00 00 00    	jne    801014c3 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013ea:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013f8:	e9 a3 00 00 00       	jmp    801014a0 <filewrite+0x10b>
      int n1 = n - i;
801013fd:	8b 45 10             	mov    0x10(%ebp),%eax
80101400:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101403:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101409:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010140c:	7e 06                	jle    80101414 <filewrite+0x7f>
        n1 = max;
8010140e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101411:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101414:	e8 c8 22 00 00       	call   801036e1 <begin_op>
      ilock(f->ip);
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	8b 40 10             	mov    0x10(%eax),%eax
8010141f:	83 ec 0c             	sub    $0xc,%esp
80101422:	50                   	push   %eax
80101423:	e8 ea 06 00 00       	call   80101b12 <ilock>
80101428:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010142b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010142e:	8b 45 08             	mov    0x8(%ebp),%eax
80101431:	8b 50 14             	mov    0x14(%eax),%edx
80101434:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010143a:	01 c3                	add    %eax,%ebx
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	8b 40 10             	mov    0x10(%eax),%eax
80101442:	51                   	push   %ecx
80101443:	52                   	push   %edx
80101444:	53                   	push   %ebx
80101445:	50                   	push   %eax
80101446:	e8 28 0d 00 00       	call   80102173 <writei>
8010144b:	83 c4 10             	add    $0x10,%esp
8010144e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101451:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101455:	7e 11                	jle    80101468 <filewrite+0xd3>
        f->off += r;
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	8b 50 14             	mov    0x14(%eax),%edx
8010145d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101460:	01 c2                	add    %eax,%edx
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101468:	8b 45 08             	mov    0x8(%ebp),%eax
8010146b:	8b 40 10             	mov    0x10(%eax),%eax
8010146e:	83 ec 0c             	sub    $0xc,%esp
80101471:	50                   	push   %eax
80101472:	e8 b2 07 00 00       	call   80101c29 <iunlock>
80101477:	83 c4 10             	add    $0x10,%esp
      end_op();
8010147a:	e8 f2 22 00 00       	call   80103771 <end_op>

      if(r < 0)
8010147f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101483:	78 29                	js     801014ae <filewrite+0x119>
        break;
      if(r != n1)
80101485:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101488:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010148b:	74 0d                	je     8010149a <filewrite+0x105>
        panic("short filewrite");
8010148d:	83 ec 0c             	sub    $0xc,%esp
80101490:	68 77 93 10 80       	push   $0x80109377
80101495:	e8 6e f1 ff ff       	call   80100608 <panic>
      i += r;
8010149a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010149d:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a3:	3b 45 10             	cmp    0x10(%ebp),%eax
801014a6:	0f 8c 51 ff ff ff    	jl     801013fd <filewrite+0x68>
801014ac:	eb 01                	jmp    801014af <filewrite+0x11a>
        break;
801014ae:	90                   	nop
    }
    return i == n ? n : -1;
801014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801014b5:	75 05                	jne    801014bc <filewrite+0x127>
801014b7:	8b 45 10             	mov    0x10(%ebp),%eax
801014ba:	eb 14                	jmp    801014d0 <filewrite+0x13b>
801014bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014c1:	eb 0d                	jmp    801014d0 <filewrite+0x13b>
  }
  panic("filewrite");
801014c3:	83 ec 0c             	sub    $0xc,%esp
801014c6:	68 87 93 10 80       	push   $0x80109387
801014cb:	e8 38 f1 ff ff       	call   80100608 <panic>
}
801014d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014d3:	c9                   	leave  
801014d4:	c3                   	ret    

801014d5 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014d5:	f3 0f 1e fb          	endbr32 
801014d9:	55                   	push   %ebp
801014da:	89 e5                	mov    %esp,%ebp
801014dc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014df:	8b 45 08             	mov    0x8(%ebp),%eax
801014e2:	83 ec 08             	sub    $0x8,%esp
801014e5:	6a 01                	push   $0x1
801014e7:	50                   	push   %eax
801014e8:	e8 ea ec ff ff       	call   801001d7 <bread>
801014ed:	83 c4 10             	add    $0x10,%esp
801014f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014f6:	83 c0 5c             	add    $0x5c,%eax
801014f9:	83 ec 04             	sub    $0x4,%esp
801014fc:	6a 1c                	push   $0x1c
801014fe:	50                   	push   %eax
801014ff:	ff 75 0c             	pushl  0xc(%ebp)
80101502:	e8 60 41 00 00       	call   80105667 <memmove>
80101507:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010150a:	83 ec 0c             	sub    $0xc,%esp
8010150d:	ff 75 f4             	pushl  -0xc(%ebp)
80101510:	e8 4c ed ff ff       	call   80100261 <brelse>
80101515:	83 c4 10             	add    $0x10,%esp
}
80101518:	90                   	nop
80101519:	c9                   	leave  
8010151a:	c3                   	ret    

8010151b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010151b:	f3 0f 1e fb          	endbr32 
8010151f:	55                   	push   %ebp
80101520:	89 e5                	mov    %esp,%ebp
80101522:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101525:	8b 55 0c             	mov    0xc(%ebp),%edx
80101528:	8b 45 08             	mov    0x8(%ebp),%eax
8010152b:	83 ec 08             	sub    $0x8,%esp
8010152e:	52                   	push   %edx
8010152f:	50                   	push   %eax
80101530:	e8 a2 ec ff ff       	call   801001d7 <bread>
80101535:	83 c4 10             	add    $0x10,%esp
80101538:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010153b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010153e:	83 c0 5c             	add    $0x5c,%eax
80101541:	83 ec 04             	sub    $0x4,%esp
80101544:	68 00 02 00 00       	push   $0x200
80101549:	6a 00                	push   $0x0
8010154b:	50                   	push   %eax
8010154c:	e8 4f 40 00 00       	call   801055a0 <memset>
80101551:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101554:	83 ec 0c             	sub    $0xc,%esp
80101557:	ff 75 f4             	pushl  -0xc(%ebp)
8010155a:	e8 cb 23 00 00       	call   8010392a <log_write>
8010155f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 f4             	pushl  -0xc(%ebp)
80101568:	e8 f4 ec ff ff       	call   80100261 <brelse>
8010156d:	83 c4 10             	add    $0x10,%esp
}
80101570:	90                   	nop
80101571:	c9                   	leave  
80101572:	c3                   	ret    

80101573 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101573:	f3 0f 1e fb          	endbr32 
80101577:	55                   	push   %ebp
80101578:	89 e5                	mov    %esp,%ebp
8010157a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010157d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010158b:	e9 13 01 00 00       	jmp    801016a3 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101593:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101599:	85 c0                	test   %eax,%eax
8010159b:	0f 48 c2             	cmovs  %edx,%eax
8010159e:	c1 f8 0c             	sar    $0xc,%eax
801015a1:	89 c2                	mov    %eax,%edx
801015a3:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015a8:	01 d0                	add    %edx,%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	50                   	push   %eax
801015ae:	ff 75 08             	pushl  0x8(%ebp)
801015b1:	e8 21 ec ff ff       	call   801001d7 <bread>
801015b6:	83 c4 10             	add    $0x10,%esp
801015b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015c3:	e9 a6 00 00 00       	jmp    8010166e <balloc+0xfb>
      m = 1 << (bi % 8);
801015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cb:	99                   	cltd   
801015cc:	c1 ea 1d             	shr    $0x1d,%edx
801015cf:	01 d0                	add    %edx,%eax
801015d1:	83 e0 07             	and    $0x7,%eax
801015d4:	29 d0                	sub    %edx,%eax
801015d6:	ba 01 00 00 00       	mov    $0x1,%edx
801015db:	89 c1                	mov    %eax,%ecx
801015dd:	d3 e2                	shl    %cl,%edx
801015df:	89 d0                	mov    %edx,%eax
801015e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e7:	8d 50 07             	lea    0x7(%eax),%edx
801015ea:	85 c0                	test   %eax,%eax
801015ec:	0f 48 c2             	cmovs  %edx,%eax
801015ef:	c1 f8 03             	sar    $0x3,%eax
801015f2:	89 c2                	mov    %eax,%edx
801015f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015f7:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015fc:	0f b6 c0             	movzbl %al,%eax
801015ff:	23 45 e8             	and    -0x18(%ebp),%eax
80101602:	85 c0                	test   %eax,%eax
80101604:	75 64                	jne    8010166a <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101609:	8d 50 07             	lea    0x7(%eax),%edx
8010160c:	85 c0                	test   %eax,%eax
8010160e:	0f 48 c2             	cmovs  %edx,%eax
80101611:	c1 f8 03             	sar    $0x3,%eax
80101614:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101617:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010161c:	89 d1                	mov    %edx,%ecx
8010161e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101621:	09 ca                	or     %ecx,%edx
80101623:	89 d1                	mov    %edx,%ecx
80101625:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101628:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010162c:	83 ec 0c             	sub    $0xc,%esp
8010162f:	ff 75 ec             	pushl  -0x14(%ebp)
80101632:	e8 f3 22 00 00       	call   8010392a <log_write>
80101637:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010163a:	83 ec 0c             	sub    $0xc,%esp
8010163d:	ff 75 ec             	pushl  -0x14(%ebp)
80101640:	e8 1c ec ff ff       	call   80100261 <brelse>
80101645:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164e:	01 c2                	add    %eax,%edx
80101650:	8b 45 08             	mov    0x8(%ebp),%eax
80101653:	83 ec 08             	sub    $0x8,%esp
80101656:	52                   	push   %edx
80101657:	50                   	push   %eax
80101658:	e8 be fe ff ff       	call   8010151b <bzero>
8010165d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101666:	01 d0                	add    %edx,%eax
80101668:	eb 57                	jmp    801016c1 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010166a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010166e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101675:	7f 17                	jg     8010168e <balloc+0x11b>
80101677:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167d:	01 d0                	add    %edx,%eax
8010167f:	89 c2                	mov    %eax,%edx
80101681:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101686:	39 c2                	cmp    %eax,%edx
80101688:	0f 82 3a ff ff ff    	jb     801015c8 <balloc+0x55>
      }
    }
    brelse(bp);
8010168e:	83 ec 0c             	sub    $0xc,%esp
80101691:	ff 75 ec             	pushl  -0x14(%ebp)
80101694:	e8 c8 eb ff ff       	call   80100261 <brelse>
80101699:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010169c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016a3:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ac:	39 c2                	cmp    %eax,%edx
801016ae:	0f 87 dc fe ff ff    	ja     80101590 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016b4:	83 ec 0c             	sub    $0xc,%esp
801016b7:	68 94 93 10 80       	push   $0x80109394
801016bc:	e8 47 ef ff ff       	call   80100608 <panic>
}
801016c1:	c9                   	leave  
801016c2:	c3                   	ret    

801016c3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016c3:	f3 0f 1e fb          	endbr32 
801016c7:	55                   	push   %ebp
801016c8:	89 e5                	mov    %esp,%ebp
801016ca:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801016d0:	c1 e8 0c             	shr    $0xc,%eax
801016d3:	89 c2                	mov    %eax,%edx
801016d5:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016da:	01 c2                	add    %eax,%edx
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	83 ec 08             	sub    $0x8,%esp
801016e2:	52                   	push   %edx
801016e3:	50                   	push   %eax
801016e4:	e8 ee ea ff ff       	call   801001d7 <bread>
801016e9:	83 c4 10             	add    $0x10,%esp
801016ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801016f2:	25 ff 0f 00 00       	and    $0xfff,%eax
801016f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fd:	99                   	cltd   
801016fe:	c1 ea 1d             	shr    $0x1d,%edx
80101701:	01 d0                	add    %edx,%eax
80101703:	83 e0 07             	and    $0x7,%eax
80101706:	29 d0                	sub    %edx,%eax
80101708:	ba 01 00 00 00       	mov    $0x1,%edx
8010170d:	89 c1                	mov    %eax,%ecx
8010170f:	d3 e2                	shl    %cl,%edx
80101711:	89 d0                	mov    %edx,%eax
80101713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101716:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101719:	8d 50 07             	lea    0x7(%eax),%edx
8010171c:	85 c0                	test   %eax,%eax
8010171e:	0f 48 c2             	cmovs  %edx,%eax
80101721:	c1 f8 03             	sar    $0x3,%eax
80101724:	89 c2                	mov    %eax,%edx
80101726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101729:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010172e:	0f b6 c0             	movzbl %al,%eax
80101731:	23 45 ec             	and    -0x14(%ebp),%eax
80101734:	85 c0                	test   %eax,%eax
80101736:	75 0d                	jne    80101745 <bfree+0x82>
    panic("freeing free block");
80101738:	83 ec 0c             	sub    $0xc,%esp
8010173b:	68 aa 93 10 80       	push   $0x801093aa
80101740:	e8 c3 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
80101745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101748:	8d 50 07             	lea    0x7(%eax),%edx
8010174b:	85 c0                	test   %eax,%eax
8010174d:	0f 48 c2             	cmovs  %edx,%eax
80101750:	c1 f8 03             	sar    $0x3,%eax
80101753:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101756:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010175b:	89 d1                	mov    %edx,%ecx
8010175d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101760:	f7 d2                	not    %edx
80101762:	21 ca                	and    %ecx,%edx
80101764:	89 d1                	mov    %edx,%ecx
80101766:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101769:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010176d:	83 ec 0c             	sub    $0xc,%esp
80101770:	ff 75 f4             	pushl  -0xc(%ebp)
80101773:	e8 b2 21 00 00       	call   8010392a <log_write>
80101778:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010177b:	83 ec 0c             	sub    $0xc,%esp
8010177e:	ff 75 f4             	pushl  -0xc(%ebp)
80101781:	e8 db ea ff ff       	call   80100261 <brelse>
80101786:	83 c4 10             	add    $0x10,%esp
}
80101789:	90                   	nop
8010178a:	c9                   	leave  
8010178b:	c3                   	ret    

8010178c <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010178c:	f3 0f 1e fb          	endbr32 
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	57                   	push   %edi
80101794:	56                   	push   %esi
80101795:	53                   	push   %ebx
80101796:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101799:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017a0:	83 ec 08             	sub    $0x8,%esp
801017a3:	68 bd 93 10 80       	push   $0x801093bd
801017a8:	68 80 2a 11 80       	push   $0x80112a80
801017ad:	e8 29 3b 00 00       	call   801052db <initlock>
801017b2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017bc:	eb 2d                	jmp    801017eb <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017c1:	89 d0                	mov    %edx,%eax
801017c3:	c1 e0 03             	shl    $0x3,%eax
801017c6:	01 d0                	add    %edx,%eax
801017c8:	c1 e0 04             	shl    $0x4,%eax
801017cb:	83 c0 30             	add    $0x30,%eax
801017ce:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017d3:	83 c0 10             	add    $0x10,%eax
801017d6:	83 ec 08             	sub    $0x8,%esp
801017d9:	68 c4 93 10 80       	push   $0x801093c4
801017de:	50                   	push   %eax
801017df:	e8 64 39 00 00       	call   80105148 <initsleeplock>
801017e4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017e7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017eb:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017ef:	7e cd                	jle    801017be <iinit+0x32>
  }

  readsb(dev, &sb);
801017f1:	83 ec 08             	sub    $0x8,%esp
801017f4:	68 60 2a 11 80       	push   $0x80112a60
801017f9:	ff 75 08             	pushl  0x8(%ebp)
801017fc:	e8 d4 fc ff ff       	call   801014d5 <readsb>
80101801:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101804:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101809:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010180c:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101812:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101818:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
8010181e:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
80101824:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
8010182a:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010182f:	ff 75 d4             	pushl  -0x2c(%ebp)
80101832:	57                   	push   %edi
80101833:	56                   	push   %esi
80101834:	53                   	push   %ebx
80101835:	51                   	push   %ecx
80101836:	52                   	push   %edx
80101837:	50                   	push   %eax
80101838:	68 cc 93 10 80       	push   $0x801093cc
8010183d:	e8 d6 eb ff ff       	call   80100418 <cprintf>
80101842:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101845:	90                   	nop
80101846:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101849:	5b                   	pop    %ebx
8010184a:	5e                   	pop    %esi
8010184b:	5f                   	pop    %edi
8010184c:	5d                   	pop    %ebp
8010184d:	c3                   	ret    

8010184e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010184e:	f3 0f 1e fb          	endbr32 
80101852:	55                   	push   %ebp
80101853:	89 e5                	mov    %esp,%ebp
80101855:	83 ec 28             	sub    $0x28,%esp
80101858:	8b 45 0c             	mov    0xc(%ebp),%eax
8010185b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010185f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101866:	e9 9e 00 00 00       	jmp    80101909 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186e:	c1 e8 03             	shr    $0x3,%eax
80101871:	89 c2                	mov    %eax,%edx
80101873:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101878:	01 d0                	add    %edx,%eax
8010187a:	83 ec 08             	sub    $0x8,%esp
8010187d:	50                   	push   %eax
8010187e:	ff 75 08             	pushl  0x8(%ebp)
80101881:	e8 51 e9 ff ff       	call   801001d7 <bread>
80101886:	83 c4 10             	add    $0x10,%esp
80101889:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101895:	83 e0 07             	and    $0x7,%eax
80101898:	c1 e0 06             	shl    $0x6,%eax
8010189b:	01 d0                	add    %edx,%eax
8010189d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018a3:	0f b7 00             	movzwl (%eax),%eax
801018a6:	66 85 c0             	test   %ax,%ax
801018a9:	75 4c                	jne    801018f7 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018ab:	83 ec 04             	sub    $0x4,%esp
801018ae:	6a 40                	push   $0x40
801018b0:	6a 00                	push   $0x0
801018b2:	ff 75 ec             	pushl  -0x14(%ebp)
801018b5:	e8 e6 3c 00 00       	call   801055a0 <memset>
801018ba:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018c0:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018c4:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018c7:	83 ec 0c             	sub    $0xc,%esp
801018ca:	ff 75 f0             	pushl  -0x10(%ebp)
801018cd:	e8 58 20 00 00       	call   8010392a <log_write>
801018d2:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018d5:	83 ec 0c             	sub    $0xc,%esp
801018d8:	ff 75 f0             	pushl  -0x10(%ebp)
801018db:	e8 81 e9 ff ff       	call   80100261 <brelse>
801018e0:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e6:	83 ec 08             	sub    $0x8,%esp
801018e9:	50                   	push   %eax
801018ea:	ff 75 08             	pushl  0x8(%ebp)
801018ed:	e8 fc 00 00 00       	call   801019ee <iget>
801018f2:	83 c4 10             	add    $0x10,%esp
801018f5:	eb 30                	jmp    80101927 <ialloc+0xd9>
    }
    brelse(bp);
801018f7:	83 ec 0c             	sub    $0xc,%esp
801018fa:	ff 75 f0             	pushl  -0x10(%ebp)
801018fd:	e8 5f e9 ff ff       	call   80100261 <brelse>
80101902:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101905:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101909:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
8010190f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101912:	39 c2                	cmp    %eax,%edx
80101914:	0f 87 51 ff ff ff    	ja     8010186b <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010191a:	83 ec 0c             	sub    $0xc,%esp
8010191d:	68 1f 94 10 80       	push   $0x8010941f
80101922:	e8 e1 ec ff ff       	call   80100608 <panic>
}
80101927:	c9                   	leave  
80101928:	c3                   	ret    

80101929 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101929:	f3 0f 1e fb          	endbr32 
8010192d:	55                   	push   %ebp
8010192e:	89 e5                	mov    %esp,%ebp
80101930:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	8b 40 04             	mov    0x4(%eax),%eax
80101939:	c1 e8 03             	shr    $0x3,%eax
8010193c:	89 c2                	mov    %eax,%edx
8010193e:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101943:	01 c2                	add    %eax,%edx
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	8b 00                	mov    (%eax),%eax
8010194a:	83 ec 08             	sub    $0x8,%esp
8010194d:	52                   	push   %edx
8010194e:	50                   	push   %eax
8010194f:	e8 83 e8 ff ff       	call   801001d7 <bread>
80101954:	83 c4 10             	add    $0x10,%esp
80101957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101960:	8b 45 08             	mov    0x8(%ebp),%eax
80101963:	8b 40 04             	mov    0x4(%eax),%eax
80101966:	83 e0 07             	and    $0x7,%eax
80101969:	c1 e0 06             	shl    $0x6,%eax
8010196c:	01 d0                	add    %edx,%eax
8010196e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101988:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010198c:	8b 45 08             	mov    0x8(%ebp),%eax
8010198f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101996:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a4:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	8b 50 58             	mov    0x58(%eax),%edx
801019ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bd:	83 c0 0c             	add    $0xc,%eax
801019c0:	83 ec 04             	sub    $0x4,%esp
801019c3:	6a 34                	push   $0x34
801019c5:	52                   	push   %edx
801019c6:	50                   	push   %eax
801019c7:	e8 9b 3c 00 00       	call   80105667 <memmove>
801019cc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019cf:	83 ec 0c             	sub    $0xc,%esp
801019d2:	ff 75 f4             	pushl  -0xc(%ebp)
801019d5:	e8 50 1f 00 00       	call   8010392a <log_write>
801019da:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	ff 75 f4             	pushl  -0xc(%ebp)
801019e3:	e8 79 e8 ff ff       	call   80100261 <brelse>
801019e8:	83 c4 10             	add    $0x10,%esp
}
801019eb:	90                   	nop
801019ec:	c9                   	leave  
801019ed:	c3                   	ret    

801019ee <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019ee:	f3 0f 1e fb          	endbr32 
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019f8:	83 ec 0c             	sub    $0xc,%esp
801019fb:	68 80 2a 11 80       	push   $0x80112a80
80101a00:	e8 fc 38 00 00       	call   80105301 <acquire>
80101a05:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a08:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a0f:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a16:	eb 60                	jmp    80101a78 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8b 40 08             	mov    0x8(%eax),%eax
80101a1e:	85 c0                	test   %eax,%eax
80101a20:	7e 39                	jle    80101a5b <iget+0x6d>
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 00                	mov    (%eax),%eax
80101a27:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a2a:	75 2f                	jne    80101a5b <iget+0x6d>
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	8b 40 04             	mov    0x4(%eax),%eax
80101a32:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a35:	75 24                	jne    80101a5b <iget+0x6d>
      ip->ref++;
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8b 40 08             	mov    0x8(%eax),%eax
80101a3d:	8d 50 01             	lea    0x1(%eax),%edx
80101a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a43:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a46:	83 ec 0c             	sub    $0xc,%esp
80101a49:	68 80 2a 11 80       	push   $0x80112a80
80101a4e:	e8 20 39 00 00       	call   80105373 <release>
80101a53:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a59:	eb 77                	jmp    80101ad2 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a5f:	75 10                	jne    80101a71 <iget+0x83>
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	8b 40 08             	mov    0x8(%eax),%eax
80101a67:	85 c0                	test   %eax,%eax
80101a69:	75 06                	jne    80101a71 <iget+0x83>
      empty = ip;
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a71:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a78:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a7f:	72 97                	jb     80101a18 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a85:	75 0d                	jne    80101a94 <iget+0xa6>
    panic("iget: no inodes");
80101a87:	83 ec 0c             	sub    $0xc,%esp
80101a8a:	68 31 94 10 80       	push   $0x80109431
80101a8f:	e8 74 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9d:	8b 55 08             	mov    0x8(%ebp),%edx
80101aa0:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aa8:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101abf:	83 ec 0c             	sub    $0xc,%esp
80101ac2:	68 80 2a 11 80       	push   $0x80112a80
80101ac7:	e8 a7 38 00 00       	call   80105373 <release>
80101acc:	83 c4 10             	add    $0x10,%esp

  return ip;
80101acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ad2:	c9                   	leave  
80101ad3:	c3                   	ret    

80101ad4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ad4:	f3 0f 1e fb          	endbr32 
80101ad8:	55                   	push   %ebp
80101ad9:	89 e5                	mov    %esp,%ebp
80101adb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ade:	83 ec 0c             	sub    $0xc,%esp
80101ae1:	68 80 2a 11 80       	push   $0x80112a80
80101ae6:	e8 16 38 00 00       	call   80105301 <acquire>
80101aeb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101aee:	8b 45 08             	mov    0x8(%ebp),%eax
80101af1:	8b 40 08             	mov    0x8(%eax),%eax
80101af4:	8d 50 01             	lea    0x1(%eax),%edx
80101af7:	8b 45 08             	mov    0x8(%ebp),%eax
80101afa:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101afd:	83 ec 0c             	sub    $0xc,%esp
80101b00:	68 80 2a 11 80       	push   $0x80112a80
80101b05:	e8 69 38 00 00       	call   80105373 <release>
80101b0a:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b10:	c9                   	leave  
80101b11:	c3                   	ret    

80101b12 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b12:	f3 0f 1e fb          	endbr32 
80101b16:	55                   	push   %ebp
80101b17:	89 e5                	mov    %esp,%ebp
80101b19:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b20:	74 0a                	je     80101b2c <ilock+0x1a>
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	8b 40 08             	mov    0x8(%eax),%eax
80101b28:	85 c0                	test   %eax,%eax
80101b2a:	7f 0d                	jg     80101b39 <ilock+0x27>
    panic("ilock");
80101b2c:	83 ec 0c             	sub    $0xc,%esp
80101b2f:	68 41 94 10 80       	push   $0x80109441
80101b34:	e8 cf ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	83 c0 0c             	add    $0xc,%eax
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	50                   	push   %eax
80101b43:	e8 40 36 00 00       	call   80105188 <acquiresleep>
80101b48:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b51:	85 c0                	test   %eax,%eax
80101b53:	0f 85 cd 00 00 00    	jne    80101c26 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	8b 40 04             	mov    0x4(%eax),%eax
80101b5f:	c1 e8 03             	shr    $0x3,%eax
80101b62:	89 c2                	mov    %eax,%edx
80101b64:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b69:	01 c2                	add    %eax,%edx
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 00                	mov    (%eax),%eax
80101b70:	83 ec 08             	sub    $0x8,%esp
80101b73:	52                   	push   %edx
80101b74:	50                   	push   %eax
80101b75:	e8 5d e6 ff ff       	call   801001d7 <bread>
80101b7a:	83 c4 10             	add    $0x10,%esp
80101b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b83:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b86:	8b 45 08             	mov    0x8(%ebp),%eax
80101b89:	8b 40 04             	mov    0x4(%eax),%eax
80101b8c:	83 e0 07             	and    $0x7,%eax
80101b8f:	c1 e0 06             	shl    $0x6,%eax
80101b92:	01 d0                	add    %edx,%eax
80101b94:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9a:	0f b7 10             	movzwl (%eax),%edx
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bca:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd1:	8b 50 08             	mov    0x8(%eax),%edx
80101bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd7:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bdd:	8d 50 0c             	lea    0xc(%eax),%edx
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	83 c0 5c             	add    $0x5c,%eax
80101be6:	83 ec 04             	sub    $0x4,%esp
80101be9:	6a 34                	push   $0x34
80101beb:	52                   	push   %edx
80101bec:	50                   	push   %eax
80101bed:	e8 75 3a 00 00       	call   80105667 <memmove>
80101bf2:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	ff 75 f4             	pushl  -0xc(%ebp)
80101bfb:	e8 61 e6 ff ff       	call   80100261 <brelse>
80101c00:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c14:	66 85 c0             	test   %ax,%ax
80101c17:	75 0d                	jne    80101c26 <ilock+0x114>
      panic("ilock: no type");
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	68 47 94 10 80       	push   $0x80109447
80101c21:	e8 e2 e9 ff ff       	call   80100608 <panic>
  }
}
80101c26:	90                   	nop
80101c27:	c9                   	leave  
80101c28:	c3                   	ret    

80101c29 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c29:	f3 0f 1e fb          	endbr32 
80101c2d:	55                   	push   %ebp
80101c2e:	89 e5                	mov    %esp,%ebp
80101c30:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c37:	74 20                	je     80101c59 <iunlock+0x30>
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	83 c0 0c             	add    $0xc,%eax
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	50                   	push   %eax
80101c43:	e8 fa 35 00 00       	call   80105242 <holdingsleep>
80101c48:	83 c4 10             	add    $0x10,%esp
80101c4b:	85 c0                	test   %eax,%eax
80101c4d:	74 0a                	je     80101c59 <iunlock+0x30>
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 08             	mov    0x8(%eax),%eax
80101c55:	85 c0                	test   %eax,%eax
80101c57:	7f 0d                	jg     80101c66 <iunlock+0x3d>
    panic("iunlock");
80101c59:	83 ec 0c             	sub    $0xc,%esp
80101c5c:	68 56 94 10 80       	push   $0x80109456
80101c61:	e8 a2 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	83 c0 0c             	add    $0xc,%eax
80101c6c:	83 ec 0c             	sub    $0xc,%esp
80101c6f:	50                   	push   %eax
80101c70:	e8 7b 35 00 00       	call   801051f0 <releasesleep>
80101c75:	83 c4 10             	add    $0x10,%esp
}
80101c78:	90                   	nop
80101c79:	c9                   	leave  
80101c7a:	c3                   	ret    

80101c7b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c7b:	f3 0f 1e fb          	endbr32 
80101c7f:	55                   	push   %ebp
80101c80:	89 e5                	mov    %esp,%ebp
80101c82:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	83 c0 0c             	add    $0xc,%eax
80101c8b:	83 ec 0c             	sub    $0xc,%esp
80101c8e:	50                   	push   %eax
80101c8f:	e8 f4 34 00 00       	call   80105188 <acquiresleep>
80101c94:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c9d:	85 c0                	test   %eax,%eax
80101c9f:	74 6a                	je     80101d0b <iput+0x90>
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101ca8:	66 85 c0             	test   %ax,%ax
80101cab:	75 5e                	jne    80101d0b <iput+0x90>
    acquire(&icache.lock);
80101cad:	83 ec 0c             	sub    $0xc,%esp
80101cb0:	68 80 2a 11 80       	push   $0x80112a80
80101cb5:	e8 47 36 00 00       	call   80105301 <acquire>
80101cba:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 40 08             	mov    0x8(%eax),%eax
80101cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cc6:	83 ec 0c             	sub    $0xc,%esp
80101cc9:	68 80 2a 11 80       	push   $0x80112a80
80101cce:	e8 a0 36 00 00       	call   80105373 <release>
80101cd3:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101cd6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cda:	75 2f                	jne    80101d0b <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cdc:	83 ec 0c             	sub    $0xc,%esp
80101cdf:	ff 75 08             	pushl  0x8(%ebp)
80101ce2:	e8 b5 01 00 00       	call   80101e9c <itrunc>
80101ce7:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cf3:	83 ec 0c             	sub    $0xc,%esp
80101cf6:	ff 75 08             	pushl  0x8(%ebp)
80101cf9:	e8 2b fc ff ff       	call   80101929 <iupdate>
80101cfe:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	83 c0 0c             	add    $0xc,%eax
80101d11:	83 ec 0c             	sub    $0xc,%esp
80101d14:	50                   	push   %eax
80101d15:	e8 d6 34 00 00       	call   801051f0 <releasesleep>
80101d1a:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d1d:	83 ec 0c             	sub    $0xc,%esp
80101d20:	68 80 2a 11 80       	push   $0x80112a80
80101d25:	e8 d7 35 00 00       	call   80105301 <acquire>
80101d2a:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d30:	8b 40 08             	mov    0x8(%eax),%eax
80101d33:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d3c:	83 ec 0c             	sub    $0xc,%esp
80101d3f:	68 80 2a 11 80       	push   $0x80112a80
80101d44:	e8 2a 36 00 00       	call   80105373 <release>
80101d49:	83 c4 10             	add    $0x10,%esp
}
80101d4c:	90                   	nop
80101d4d:	c9                   	leave  
80101d4e:	c3                   	ret    

80101d4f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d4f:	f3 0f 1e fb          	endbr32 
80101d53:	55                   	push   %ebp
80101d54:	89 e5                	mov    %esp,%ebp
80101d56:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	ff 75 08             	pushl  0x8(%ebp)
80101d5f:	e8 c5 fe ff ff       	call   80101c29 <iunlock>
80101d64:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d67:	83 ec 0c             	sub    $0xc,%esp
80101d6a:	ff 75 08             	pushl  0x8(%ebp)
80101d6d:	e8 09 ff ff ff       	call   80101c7b <iput>
80101d72:	83 c4 10             	add    $0x10,%esp
}
80101d75:	90                   	nop
80101d76:	c9                   	leave  
80101d77:	c3                   	ret    

80101d78 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d78:	f3 0f 1e fb          	endbr32 
80101d7c:	55                   	push   %ebp
80101d7d:	89 e5                	mov    %esp,%ebp
80101d7f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d82:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d86:	77 42                	ja     80101dca <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9c:	75 24                	jne    80101dc2 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101da1:	8b 00                	mov    (%eax),%eax
80101da3:	83 ec 0c             	sub    $0xc,%esp
80101da6:	50                   	push   %eax
80101da7:	e8 c7 f7 ff ff       	call   80101573 <balloc>
80101dac:	83 c4 10             	add    $0x10,%esp
80101daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101db8:	8d 4a 14             	lea    0x14(%edx),%ecx
80101dbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dbe:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc5:	e9 d0 00 00 00       	jmp    80101e9a <bmap+0x122>
  }
  bn -= NDIRECT;
80101dca:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dce:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101dd2:	0f 87 b5 00 00 00    	ja     80101e8d <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddb:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101de1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101de8:	75 20                	jne    80101e0a <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	8b 00                	mov    (%eax),%eax
80101def:	83 ec 0c             	sub    $0xc,%esp
80101df2:	50                   	push   %eax
80101df3:	e8 7b f7 ff ff       	call   80101573 <balloc>
80101df8:	83 c4 10             	add    $0x10,%esp
80101dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e04:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	8b 00                	mov    (%eax),%eax
80101e0f:	83 ec 08             	sub    $0x8,%esp
80101e12:	ff 75 f4             	pushl  -0xc(%ebp)
80101e15:	50                   	push   %eax
80101e16:	e8 bc e3 ff ff       	call   801001d7 <bread>
80101e1b:	83 c4 10             	add    $0x10,%esp
80101e1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e24:	83 c0 5c             	add    $0x5c,%eax
80101e27:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e37:	01 d0                	add    %edx,%eax
80101e39:	8b 00                	mov    (%eax),%eax
80101e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e42:	75 36                	jne    80101e7a <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	8b 00                	mov    (%eax),%eax
80101e49:	83 ec 0c             	sub    $0xc,%esp
80101e4c:	50                   	push   %eax
80101e4d:	e8 21 f7 ff ff       	call   80101573 <balloc>
80101e52:	83 c4 10             	add    $0x10,%esp
80101e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e65:	01 c2                	add    %eax,%edx
80101e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6a:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e6c:	83 ec 0c             	sub    $0xc,%esp
80101e6f:	ff 75 f0             	pushl  -0x10(%ebp)
80101e72:	e8 b3 1a 00 00       	call   8010392a <log_write>
80101e77:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e7a:	83 ec 0c             	sub    $0xc,%esp
80101e7d:	ff 75 f0             	pushl  -0x10(%ebp)
80101e80:	e8 dc e3 ff ff       	call   80100261 <brelse>
80101e85:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8b:	eb 0d                	jmp    80101e9a <bmap+0x122>
  }

  panic("bmap: out of range");
80101e8d:	83 ec 0c             	sub    $0xc,%esp
80101e90:	68 5e 94 10 80       	push   $0x8010945e
80101e95:	e8 6e e7 ff ff       	call   80100608 <panic>
}
80101e9a:	c9                   	leave  
80101e9b:	c3                   	ret    

80101e9c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e9c:	f3 0f 1e fb          	endbr32 
80101ea0:	55                   	push   %ebp
80101ea1:	89 e5                	mov    %esp,%ebp
80101ea3:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ea6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ead:	eb 45                	jmp    80101ef4 <itrunc+0x58>
    if(ip->addrs[i]){
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eb5:	83 c2 14             	add    $0x14,%edx
80101eb8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ebc:	85 c0                	test   %eax,%eax
80101ebe:	74 30                	je     80101ef0 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ec6:	83 c2 14             	add    $0x14,%edx
80101ec9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ecd:	8b 55 08             	mov    0x8(%ebp),%edx
80101ed0:	8b 12                	mov    (%edx),%edx
80101ed2:	83 ec 08             	sub    $0x8,%esp
80101ed5:	50                   	push   %eax
80101ed6:	52                   	push   %edx
80101ed7:	e8 e7 f7 ff ff       	call   801016c3 <bfree>
80101edc:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee5:	83 c2 14             	add    $0x14,%edx
80101ee8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101eef:	00 
  for(i = 0; i < NDIRECT; i++){
80101ef0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ef4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ef8:	7e b5                	jle    80101eaf <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101efa:	8b 45 08             	mov    0x8(%ebp),%eax
80101efd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	0f 84 aa 00 00 00    	je     80101fb5 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f14:	8b 45 08             	mov    0x8(%ebp),%eax
80101f17:	8b 00                	mov    (%eax),%eax
80101f19:	83 ec 08             	sub    $0x8,%esp
80101f1c:	52                   	push   %edx
80101f1d:	50                   	push   %eax
80101f1e:	e8 b4 e2 ff ff       	call   801001d7 <bread>
80101f23:	83 c4 10             	add    $0x10,%esp
80101f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2c:	83 c0 5c             	add    $0x5c,%eax
80101f2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f39:	eb 3c                	jmp    80101f77 <itrunc+0xdb>
      if(a[j])
80101f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f48:	01 d0                	add    %edx,%eax
80101f4a:	8b 00                	mov    (%eax),%eax
80101f4c:	85 c0                	test   %eax,%eax
80101f4e:	74 23                	je     80101f73 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f53:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f5d:	01 d0                	add    %edx,%eax
80101f5f:	8b 00                	mov    (%eax),%eax
80101f61:	8b 55 08             	mov    0x8(%ebp),%edx
80101f64:	8b 12                	mov    (%edx),%edx
80101f66:	83 ec 08             	sub    $0x8,%esp
80101f69:	50                   	push   %eax
80101f6a:	52                   	push   %edx
80101f6b:	e8 53 f7 ff ff       	call   801016c3 <bfree>
80101f70:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f73:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f7a:	83 f8 7f             	cmp    $0x7f,%eax
80101f7d:	76 bc                	jbe    80101f3b <itrunc+0x9f>
    }
    brelse(bp);
80101f7f:	83 ec 0c             	sub    $0xc,%esp
80101f82:	ff 75 ec             	pushl  -0x14(%ebp)
80101f85:	e8 d7 e2 ff ff       	call   80100261 <brelse>
80101f8a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f96:	8b 55 08             	mov    0x8(%ebp),%edx
80101f99:	8b 12                	mov    (%edx),%edx
80101f9b:	83 ec 08             	sub    $0x8,%esp
80101f9e:	50                   	push   %eax
80101f9f:	52                   	push   %edx
80101fa0:	e8 1e f7 ff ff       	call   801016c3 <bfree>
80101fa5:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fab:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fb2:	00 00 00 
  }

  ip->size = 0;
80101fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fbf:	83 ec 0c             	sub    $0xc,%esp
80101fc2:	ff 75 08             	pushl  0x8(%ebp)
80101fc5:	e8 5f f9 ff ff       	call   80101929 <iupdate>
80101fca:	83 c4 10             	add    $0x10,%esp
}
80101fcd:	90                   	nop
80101fce:	c9                   	leave  
80101fcf:	c3                   	ret    

80101fd0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fd0:	f3 0f 1e fb          	endbr32 
80101fd4:	55                   	push   %ebp
80101fd5:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fda:	8b 00                	mov    (%eax),%eax
80101fdc:	89 c2                	mov    %eax,%edx
80101fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe1:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe7:	8b 50 04             	mov    0x4(%eax),%edx
80101fea:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fed:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff3:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffa:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80102000:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102004:	8b 45 0c             	mov    0xc(%ebp),%eax
80102007:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010200b:	8b 45 08             	mov    0x8(%ebp),%eax
8010200e:	8b 50 58             	mov    0x58(%eax),%edx
80102011:	8b 45 0c             	mov    0xc(%ebp),%eax
80102014:	89 50 10             	mov    %edx,0x10(%eax)
}
80102017:	90                   	nop
80102018:	5d                   	pop    %ebp
80102019:	c3                   	ret    

8010201a <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010201a:	f3 0f 1e fb          	endbr32 
8010201e:	55                   	push   %ebp
8010201f:	89 e5                	mov    %esp,%ebp
80102021:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102024:	8b 45 08             	mov    0x8(%ebp),%eax
80102027:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010202b:	66 83 f8 03          	cmp    $0x3,%ax
8010202f:	75 5c                	jne    8010208d <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102038:	66 85 c0             	test   %ax,%ax
8010203b:	78 20                	js     8010205d <readi+0x43>
8010203d:	8b 45 08             	mov    0x8(%ebp),%eax
80102040:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102044:	66 83 f8 09          	cmp    $0x9,%ax
80102048:	7f 13                	jg     8010205d <readi+0x43>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	98                   	cwtl   
80102052:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102059:	85 c0                	test   %eax,%eax
8010205b:	75 0a                	jne    80102067 <readi+0x4d>
      return -1;
8010205d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102062:	e9 0a 01 00 00       	jmp    80102171 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206e:	98                   	cwtl   
8010206f:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102076:	8b 55 14             	mov    0x14(%ebp),%edx
80102079:	83 ec 04             	sub    $0x4,%esp
8010207c:	52                   	push   %edx
8010207d:	ff 75 0c             	pushl  0xc(%ebp)
80102080:	ff 75 08             	pushl  0x8(%ebp)
80102083:	ff d0                	call   *%eax
80102085:	83 c4 10             	add    $0x10,%esp
80102088:	e9 e4 00 00 00       	jmp    80102171 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
8010208d:	8b 45 08             	mov    0x8(%ebp),%eax
80102090:	8b 40 58             	mov    0x58(%eax),%eax
80102093:	39 45 10             	cmp    %eax,0x10(%ebp)
80102096:	77 0d                	ja     801020a5 <readi+0x8b>
80102098:	8b 55 10             	mov    0x10(%ebp),%edx
8010209b:	8b 45 14             	mov    0x14(%ebp),%eax
8010209e:	01 d0                	add    %edx,%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	76 0a                	jbe    801020af <readi+0x95>
    return -1;
801020a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020aa:	e9 c2 00 00 00       	jmp    80102171 <readi+0x157>
  if(off + n > ip->size)
801020af:	8b 55 10             	mov    0x10(%ebp),%edx
801020b2:	8b 45 14             	mov    0x14(%ebp),%eax
801020b5:	01 c2                	add    %eax,%edx
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	8b 40 58             	mov    0x58(%eax),%eax
801020bd:	39 c2                	cmp    %eax,%edx
801020bf:	76 0c                	jbe    801020cd <readi+0xb3>
    n = ip->size - off;
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	8b 40 58             	mov    0x58(%eax),%eax
801020c7:	2b 45 10             	sub    0x10(%ebp),%eax
801020ca:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020d4:	e9 89 00 00 00       	jmp    80102162 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d9:	8b 45 10             	mov    0x10(%ebp),%eax
801020dc:	c1 e8 09             	shr    $0x9,%eax
801020df:	83 ec 08             	sub    $0x8,%esp
801020e2:	50                   	push   %eax
801020e3:	ff 75 08             	pushl  0x8(%ebp)
801020e6:	e8 8d fc ff ff       	call   80101d78 <bmap>
801020eb:	83 c4 10             	add    $0x10,%esp
801020ee:	8b 55 08             	mov    0x8(%ebp),%edx
801020f1:	8b 12                	mov    (%edx),%edx
801020f3:	83 ec 08             	sub    $0x8,%esp
801020f6:	50                   	push   %eax
801020f7:	52                   	push   %edx
801020f8:	e8 da e0 ff ff       	call   801001d7 <bread>
801020fd:	83 c4 10             	add    $0x10,%esp
80102100:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102103:	8b 45 10             	mov    0x10(%ebp),%eax
80102106:	25 ff 01 00 00       	and    $0x1ff,%eax
8010210b:	ba 00 02 00 00       	mov    $0x200,%edx
80102110:	29 c2                	sub    %eax,%edx
80102112:	8b 45 14             	mov    0x14(%ebp),%eax
80102115:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102118:	39 c2                	cmp    %eax,%edx
8010211a:	0f 46 c2             	cmovbe %edx,%eax
8010211d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102123:	8d 50 5c             	lea    0x5c(%eax),%edx
80102126:	8b 45 10             	mov    0x10(%ebp),%eax
80102129:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212e:	01 d0                	add    %edx,%eax
80102130:	83 ec 04             	sub    $0x4,%esp
80102133:	ff 75 ec             	pushl  -0x14(%ebp)
80102136:	50                   	push   %eax
80102137:	ff 75 0c             	pushl  0xc(%ebp)
8010213a:	e8 28 35 00 00       	call   80105667 <memmove>
8010213f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102142:	83 ec 0c             	sub    $0xc,%esp
80102145:	ff 75 f0             	pushl  -0x10(%ebp)
80102148:	e8 14 e1 ff ff       	call   80100261 <brelse>
8010214d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102150:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102153:	01 45 f4             	add    %eax,-0xc(%ebp)
80102156:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102159:	01 45 10             	add    %eax,0x10(%ebp)
8010215c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215f:	01 45 0c             	add    %eax,0xc(%ebp)
80102162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102165:	3b 45 14             	cmp    0x14(%ebp),%eax
80102168:	0f 82 6b ff ff ff    	jb     801020d9 <readi+0xbf>
  }
  return n;
8010216e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102171:	c9                   	leave  
80102172:	c3                   	ret    

80102173 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102173:	f3 0f 1e fb          	endbr32 
80102177:	55                   	push   %ebp
80102178:	89 e5                	mov    %esp,%ebp
8010217a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010217d:	8b 45 08             	mov    0x8(%ebp),%eax
80102180:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102184:	66 83 f8 03          	cmp    $0x3,%ax
80102188:	75 5c                	jne    801021e6 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102191:	66 85 c0             	test   %ax,%ax
80102194:	78 20                	js     801021b6 <writei+0x43>
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010219d:	66 83 f8 09          	cmp    $0x9,%ax
801021a1:	7f 13                	jg     801021b6 <writei+0x43>
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021aa:	98                   	cwtl   
801021ab:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021b2:	85 c0                	test   %eax,%eax
801021b4:	75 0a                	jne    801021c0 <writei+0x4d>
      return -1;
801021b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021bb:	e9 3b 01 00 00       	jmp    801022fb <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021c0:	8b 45 08             	mov    0x8(%ebp),%eax
801021c3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021c7:	98                   	cwtl   
801021c8:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021cf:	8b 55 14             	mov    0x14(%ebp),%edx
801021d2:	83 ec 04             	sub    $0x4,%esp
801021d5:	52                   	push   %edx
801021d6:	ff 75 0c             	pushl  0xc(%ebp)
801021d9:	ff 75 08             	pushl  0x8(%ebp)
801021dc:	ff d0                	call   *%eax
801021de:	83 c4 10             	add    $0x10,%esp
801021e1:	e9 15 01 00 00       	jmp    801022fb <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021e6:	8b 45 08             	mov    0x8(%ebp),%eax
801021e9:	8b 40 58             	mov    0x58(%eax),%eax
801021ec:	39 45 10             	cmp    %eax,0x10(%ebp)
801021ef:	77 0d                	ja     801021fe <writei+0x8b>
801021f1:	8b 55 10             	mov    0x10(%ebp),%edx
801021f4:	8b 45 14             	mov    0x14(%ebp),%eax
801021f7:	01 d0                	add    %edx,%eax
801021f9:	39 45 10             	cmp    %eax,0x10(%ebp)
801021fc:	76 0a                	jbe    80102208 <writei+0x95>
    return -1;
801021fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102203:	e9 f3 00 00 00       	jmp    801022fb <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102208:	8b 55 10             	mov    0x10(%ebp),%edx
8010220b:	8b 45 14             	mov    0x14(%ebp),%eax
8010220e:	01 d0                	add    %edx,%eax
80102210:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102215:	76 0a                	jbe    80102221 <writei+0xae>
    return -1;
80102217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010221c:	e9 da 00 00 00       	jmp    801022fb <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102228:	e9 97 00 00 00       	jmp    801022c4 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010222d:	8b 45 10             	mov    0x10(%ebp),%eax
80102230:	c1 e8 09             	shr    $0x9,%eax
80102233:	83 ec 08             	sub    $0x8,%esp
80102236:	50                   	push   %eax
80102237:	ff 75 08             	pushl  0x8(%ebp)
8010223a:	e8 39 fb ff ff       	call   80101d78 <bmap>
8010223f:	83 c4 10             	add    $0x10,%esp
80102242:	8b 55 08             	mov    0x8(%ebp),%edx
80102245:	8b 12                	mov    (%edx),%edx
80102247:	83 ec 08             	sub    $0x8,%esp
8010224a:	50                   	push   %eax
8010224b:	52                   	push   %edx
8010224c:	e8 86 df ff ff       	call   801001d7 <bread>
80102251:	83 c4 10             	add    $0x10,%esp
80102254:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102257:	8b 45 10             	mov    0x10(%ebp),%eax
8010225a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010225f:	ba 00 02 00 00       	mov    $0x200,%edx
80102264:	29 c2                	sub    %eax,%edx
80102266:	8b 45 14             	mov    0x14(%ebp),%eax
80102269:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010226c:	39 c2                	cmp    %eax,%edx
8010226e:	0f 46 c2             	cmovbe %edx,%eax
80102271:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102274:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102277:	8d 50 5c             	lea    0x5c(%eax),%edx
8010227a:	8b 45 10             	mov    0x10(%ebp),%eax
8010227d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102282:	01 d0                	add    %edx,%eax
80102284:	83 ec 04             	sub    $0x4,%esp
80102287:	ff 75 ec             	pushl  -0x14(%ebp)
8010228a:	ff 75 0c             	pushl  0xc(%ebp)
8010228d:	50                   	push   %eax
8010228e:	e8 d4 33 00 00       	call   80105667 <memmove>
80102293:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102296:	83 ec 0c             	sub    $0xc,%esp
80102299:	ff 75 f0             	pushl  -0x10(%ebp)
8010229c:	e8 89 16 00 00       	call   8010392a <log_write>
801022a1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022a4:	83 ec 0c             	sub    $0xc,%esp
801022a7:	ff 75 f0             	pushl  -0x10(%ebp)
801022aa:	e8 b2 df ff ff       	call   80100261 <brelse>
801022af:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b5:	01 45 f4             	add    %eax,-0xc(%ebp)
801022b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022bb:	01 45 10             	add    %eax,0x10(%ebp)
801022be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c1:	01 45 0c             	add    %eax,0xc(%ebp)
801022c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c7:	3b 45 14             	cmp    0x14(%ebp),%eax
801022ca:	0f 82 5d ff ff ff    	jb     8010222d <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022d0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022d4:	74 22                	je     801022f8 <writei+0x185>
801022d6:	8b 45 08             	mov    0x8(%ebp),%eax
801022d9:	8b 40 58             	mov    0x58(%eax),%eax
801022dc:	39 45 10             	cmp    %eax,0x10(%ebp)
801022df:	76 17                	jbe    801022f8 <writei+0x185>
    ip->size = off;
801022e1:	8b 45 08             	mov    0x8(%ebp),%eax
801022e4:	8b 55 10             	mov    0x10(%ebp),%edx
801022e7:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022ea:	83 ec 0c             	sub    $0xc,%esp
801022ed:	ff 75 08             	pushl  0x8(%ebp)
801022f0:	e8 34 f6 ff ff       	call   80101929 <iupdate>
801022f5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022f8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022fb:	c9                   	leave  
801022fc:	c3                   	ret    

801022fd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022fd:	f3 0f 1e fb          	endbr32 
80102301:	55                   	push   %ebp
80102302:	89 e5                	mov    %esp,%ebp
80102304:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102307:	83 ec 04             	sub    $0x4,%esp
8010230a:	6a 0e                	push   $0xe
8010230c:	ff 75 0c             	pushl  0xc(%ebp)
8010230f:	ff 75 08             	pushl  0x8(%ebp)
80102312:	e8 ee 33 00 00       	call   80105705 <strncmp>
80102317:	83 c4 10             	add    $0x10,%esp
}
8010231a:	c9                   	leave  
8010231b:	c3                   	ret    

8010231c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010231c:	f3 0f 1e fb          	endbr32 
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102326:	8b 45 08             	mov    0x8(%ebp),%eax
80102329:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010232d:	66 83 f8 01          	cmp    $0x1,%ax
80102331:	74 0d                	je     80102340 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102333:	83 ec 0c             	sub    $0xc,%esp
80102336:	68 71 94 10 80       	push   $0x80109471
8010233b:	e8 c8 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102340:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102347:	eb 7b                	jmp    801023c4 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102349:	6a 10                	push   $0x10
8010234b:	ff 75 f4             	pushl  -0xc(%ebp)
8010234e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102351:	50                   	push   %eax
80102352:	ff 75 08             	pushl  0x8(%ebp)
80102355:	e8 c0 fc ff ff       	call   8010201a <readi>
8010235a:	83 c4 10             	add    $0x10,%esp
8010235d:	83 f8 10             	cmp    $0x10,%eax
80102360:	74 0d                	je     8010236f <dirlookup+0x53>
      panic("dirlookup read");
80102362:	83 ec 0c             	sub    $0xc,%esp
80102365:	68 83 94 10 80       	push   $0x80109483
8010236a:	e8 99 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010236f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102373:	66 85 c0             	test   %ax,%ax
80102376:	74 47                	je     801023bf <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102378:	83 ec 08             	sub    $0x8,%esp
8010237b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010237e:	83 c0 02             	add    $0x2,%eax
80102381:	50                   	push   %eax
80102382:	ff 75 0c             	pushl  0xc(%ebp)
80102385:	e8 73 ff ff ff       	call   801022fd <namecmp>
8010238a:	83 c4 10             	add    $0x10,%esp
8010238d:	85 c0                	test   %eax,%eax
8010238f:	75 2f                	jne    801023c0 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102391:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102395:	74 08                	je     8010239f <dirlookup+0x83>
        *poff = off;
80102397:	8b 45 10             	mov    0x10(%ebp),%eax
8010239a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010239d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010239f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023a3:	0f b7 c0             	movzwl %ax,%eax
801023a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023a9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ac:	8b 00                	mov    (%eax),%eax
801023ae:	83 ec 08             	sub    $0x8,%esp
801023b1:	ff 75 f0             	pushl  -0x10(%ebp)
801023b4:	50                   	push   %eax
801023b5:	e8 34 f6 ff ff       	call   801019ee <iget>
801023ba:	83 c4 10             	add    $0x10,%esp
801023bd:	eb 19                	jmp    801023d8 <dirlookup+0xbc>
      continue;
801023bf:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023c0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 40 58             	mov    0x58(%eax),%eax
801023ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023cd:	0f 82 76 ff ff ff    	jb     80102349 <dirlookup+0x2d>
    }
  }

  return 0;
801023d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023d8:	c9                   	leave  
801023d9:	c3                   	ret    

801023da <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023da:	f3 0f 1e fb          	endbr32 
801023de:	55                   	push   %ebp
801023df:	89 e5                	mov    %esp,%ebp
801023e1:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023e4:	83 ec 04             	sub    $0x4,%esp
801023e7:	6a 00                	push   $0x0
801023e9:	ff 75 0c             	pushl  0xc(%ebp)
801023ec:	ff 75 08             	pushl  0x8(%ebp)
801023ef:	e8 28 ff ff ff       	call   8010231c <dirlookup>
801023f4:	83 c4 10             	add    $0x10,%esp
801023f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023fe:	74 18                	je     80102418 <dirlink+0x3e>
    iput(ip);
80102400:	83 ec 0c             	sub    $0xc,%esp
80102403:	ff 75 f0             	pushl  -0x10(%ebp)
80102406:	e8 70 f8 ff ff       	call   80101c7b <iput>
8010240b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010240e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102413:	e9 9c 00 00 00       	jmp    801024b4 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102418:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010241f:	eb 39                	jmp    8010245a <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102424:	6a 10                	push   $0x10
80102426:	50                   	push   %eax
80102427:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010242a:	50                   	push   %eax
8010242b:	ff 75 08             	pushl  0x8(%ebp)
8010242e:	e8 e7 fb ff ff       	call   8010201a <readi>
80102433:	83 c4 10             	add    $0x10,%esp
80102436:	83 f8 10             	cmp    $0x10,%eax
80102439:	74 0d                	je     80102448 <dirlink+0x6e>
      panic("dirlink read");
8010243b:	83 ec 0c             	sub    $0xc,%esp
8010243e:	68 92 94 10 80       	push   $0x80109492
80102443:	e8 c0 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102448:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010244c:	66 85 c0             	test   %ax,%ax
8010244f:	74 18                	je     80102469 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102454:	83 c0 10             	add    $0x10,%eax
80102457:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010245a:	8b 45 08             	mov    0x8(%ebp),%eax
8010245d:	8b 50 58             	mov    0x58(%eax),%edx
80102460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102463:	39 c2                	cmp    %eax,%edx
80102465:	77 ba                	ja     80102421 <dirlink+0x47>
80102467:	eb 01                	jmp    8010246a <dirlink+0x90>
      break;
80102469:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010246a:	83 ec 04             	sub    $0x4,%esp
8010246d:	6a 0e                	push   $0xe
8010246f:	ff 75 0c             	pushl  0xc(%ebp)
80102472:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102475:	83 c0 02             	add    $0x2,%eax
80102478:	50                   	push   %eax
80102479:	e8 e1 32 00 00       	call   8010575f <strncpy>
8010247e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102481:	8b 45 10             	mov    0x10(%ebp),%eax
80102484:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010248b:	6a 10                	push   $0x10
8010248d:	50                   	push   %eax
8010248e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102491:	50                   	push   %eax
80102492:	ff 75 08             	pushl  0x8(%ebp)
80102495:	e8 d9 fc ff ff       	call   80102173 <writei>
8010249a:	83 c4 10             	add    $0x10,%esp
8010249d:	83 f8 10             	cmp    $0x10,%eax
801024a0:	74 0d                	je     801024af <dirlink+0xd5>
    panic("dirlink");
801024a2:	83 ec 0c             	sub    $0xc,%esp
801024a5:	68 9f 94 10 80       	push   $0x8010949f
801024aa:	e8 59 e1 ff ff       	call   80100608 <panic>

  return 0;
801024af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024b4:	c9                   	leave  
801024b5:	c3                   	ret    

801024b6 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024b6:	f3 0f 1e fb          	endbr32 
801024ba:	55                   	push   %ebp
801024bb:	89 e5                	mov    %esp,%ebp
801024bd:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024c0:	eb 04                	jmp    801024c6 <skipelem+0x10>
    path++;
801024c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	0f b6 00             	movzbl (%eax),%eax
801024cc:	3c 2f                	cmp    $0x2f,%al
801024ce:	74 f2                	je     801024c2 <skipelem+0xc>
  if(*path == 0)
801024d0:	8b 45 08             	mov    0x8(%ebp),%eax
801024d3:	0f b6 00             	movzbl (%eax),%eax
801024d6:	84 c0                	test   %al,%al
801024d8:	75 07                	jne    801024e1 <skipelem+0x2b>
    return 0;
801024da:	b8 00 00 00 00       	mov    $0x0,%eax
801024df:	eb 77                	jmp    80102558 <skipelem+0xa2>
  s = path;
801024e1:	8b 45 08             	mov    0x8(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024e7:	eb 04                	jmp    801024ed <skipelem+0x37>
    path++;
801024e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024ed:	8b 45 08             	mov    0x8(%ebp),%eax
801024f0:	0f b6 00             	movzbl (%eax),%eax
801024f3:	3c 2f                	cmp    $0x2f,%al
801024f5:	74 0a                	je     80102501 <skipelem+0x4b>
801024f7:	8b 45 08             	mov    0x8(%ebp),%eax
801024fa:	0f b6 00             	movzbl (%eax),%eax
801024fd:	84 c0                	test   %al,%al
801024ff:	75 e8                	jne    801024e9 <skipelem+0x33>
  len = path - s;
80102501:	8b 45 08             	mov    0x8(%ebp),%eax
80102504:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010250a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010250e:	7e 15                	jle    80102525 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102510:	83 ec 04             	sub    $0x4,%esp
80102513:	6a 0e                	push   $0xe
80102515:	ff 75 f4             	pushl  -0xc(%ebp)
80102518:	ff 75 0c             	pushl  0xc(%ebp)
8010251b:	e8 47 31 00 00       	call   80105667 <memmove>
80102520:	83 c4 10             	add    $0x10,%esp
80102523:	eb 26                	jmp    8010254b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102528:	83 ec 04             	sub    $0x4,%esp
8010252b:	50                   	push   %eax
8010252c:	ff 75 f4             	pushl  -0xc(%ebp)
8010252f:	ff 75 0c             	pushl  0xc(%ebp)
80102532:	e8 30 31 00 00       	call   80105667 <memmove>
80102537:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010253a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010253d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102540:	01 d0                	add    %edx,%eax
80102542:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102545:	eb 04                	jmp    8010254b <skipelem+0x95>
    path++;
80102547:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010254b:	8b 45 08             	mov    0x8(%ebp),%eax
8010254e:	0f b6 00             	movzbl (%eax),%eax
80102551:	3c 2f                	cmp    $0x2f,%al
80102553:	74 f2                	je     80102547 <skipelem+0x91>
  return path;
80102555:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102558:	c9                   	leave  
80102559:	c3                   	ret    

8010255a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010255a:	f3 0f 1e fb          	endbr32 
8010255e:	55                   	push   %ebp
8010255f:	89 e5                	mov    %esp,%ebp
80102561:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102564:	8b 45 08             	mov    0x8(%ebp),%eax
80102567:	0f b6 00             	movzbl (%eax),%eax
8010256a:	3c 2f                	cmp    $0x2f,%al
8010256c:	75 17                	jne    80102585 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010256e:	83 ec 08             	sub    $0x8,%esp
80102571:	6a 01                	push   $0x1
80102573:	6a 01                	push   $0x1
80102575:	e8 74 f4 ff ff       	call   801019ee <iget>
8010257a:	83 c4 10             	add    $0x10,%esp
8010257d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102580:	e9 ba 00 00 00       	jmp    8010263f <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
80102585:	e8 16 1f 00 00       	call   801044a0 <myproc>
8010258a:	8b 40 68             	mov    0x68(%eax),%eax
8010258d:	83 ec 0c             	sub    $0xc,%esp
80102590:	50                   	push   %eax
80102591:	e8 3e f5 ff ff       	call   80101ad4 <idup>
80102596:	83 c4 10             	add    $0x10,%esp
80102599:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010259c:	e9 9e 00 00 00       	jmp    8010263f <namex+0xe5>
    ilock(ip);
801025a1:	83 ec 0c             	sub    $0xc,%esp
801025a4:	ff 75 f4             	pushl  -0xc(%ebp)
801025a7:	e8 66 f5 ff ff       	call   80101b12 <ilock>
801025ac:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025b6:	66 83 f8 01          	cmp    $0x1,%ax
801025ba:	74 18                	je     801025d4 <namex+0x7a>
      iunlockput(ip);
801025bc:	83 ec 0c             	sub    $0xc,%esp
801025bf:	ff 75 f4             	pushl  -0xc(%ebp)
801025c2:	e8 88 f7 ff ff       	call   80101d4f <iunlockput>
801025c7:	83 c4 10             	add    $0x10,%esp
      return 0;
801025ca:	b8 00 00 00 00       	mov    $0x0,%eax
801025cf:	e9 a7 00 00 00       	jmp    8010267b <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025d8:	74 20                	je     801025fa <namex+0xa0>
801025da:	8b 45 08             	mov    0x8(%ebp),%eax
801025dd:	0f b6 00             	movzbl (%eax),%eax
801025e0:	84 c0                	test   %al,%al
801025e2:	75 16                	jne    801025fa <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025e4:	83 ec 0c             	sub    $0xc,%esp
801025e7:	ff 75 f4             	pushl  -0xc(%ebp)
801025ea:	e8 3a f6 ff ff       	call   80101c29 <iunlock>
801025ef:	83 c4 10             	add    $0x10,%esp
      return ip;
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f5:	e9 81 00 00 00       	jmp    8010267b <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025fa:	83 ec 04             	sub    $0x4,%esp
801025fd:	6a 00                	push   $0x0
801025ff:	ff 75 10             	pushl  0x10(%ebp)
80102602:	ff 75 f4             	pushl  -0xc(%ebp)
80102605:	e8 12 fd ff ff       	call   8010231c <dirlookup>
8010260a:	83 c4 10             	add    $0x10,%esp
8010260d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102610:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102614:	75 15                	jne    8010262b <namex+0xd1>
      iunlockput(ip);
80102616:	83 ec 0c             	sub    $0xc,%esp
80102619:	ff 75 f4             	pushl  -0xc(%ebp)
8010261c:	e8 2e f7 ff ff       	call   80101d4f <iunlockput>
80102621:	83 c4 10             	add    $0x10,%esp
      return 0;
80102624:	b8 00 00 00 00       	mov    $0x0,%eax
80102629:	eb 50                	jmp    8010267b <namex+0x121>
    }
    iunlockput(ip);
8010262b:	83 ec 0c             	sub    $0xc,%esp
8010262e:	ff 75 f4             	pushl  -0xc(%ebp)
80102631:	e8 19 f7 ff ff       	call   80101d4f <iunlockput>
80102636:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010263c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010263f:	83 ec 08             	sub    $0x8,%esp
80102642:	ff 75 10             	pushl  0x10(%ebp)
80102645:	ff 75 08             	pushl  0x8(%ebp)
80102648:	e8 69 fe ff ff       	call   801024b6 <skipelem>
8010264d:	83 c4 10             	add    $0x10,%esp
80102650:	89 45 08             	mov    %eax,0x8(%ebp)
80102653:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102657:	0f 85 44 ff ff ff    	jne    801025a1 <namex+0x47>
  }
  if(nameiparent){
8010265d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102661:	74 15                	je     80102678 <namex+0x11e>
    iput(ip);
80102663:	83 ec 0c             	sub    $0xc,%esp
80102666:	ff 75 f4             	pushl  -0xc(%ebp)
80102669:	e8 0d f6 ff ff       	call   80101c7b <iput>
8010266e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102671:	b8 00 00 00 00       	mov    $0x0,%eax
80102676:	eb 03                	jmp    8010267b <namex+0x121>
  }
  return ip;
80102678:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010267b:	c9                   	leave  
8010267c:	c3                   	ret    

8010267d <namei>:

struct inode*
namei(char *path)
{
8010267d:	f3 0f 1e fb          	endbr32 
80102681:	55                   	push   %ebp
80102682:	89 e5                	mov    %esp,%ebp
80102684:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102687:	83 ec 04             	sub    $0x4,%esp
8010268a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010268d:	50                   	push   %eax
8010268e:	6a 00                	push   $0x0
80102690:	ff 75 08             	pushl  0x8(%ebp)
80102693:	e8 c2 fe ff ff       	call   8010255a <namex>
80102698:	83 c4 10             	add    $0x10,%esp
}
8010269b:	c9                   	leave  
8010269c:	c3                   	ret    

8010269d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010269d:	f3 0f 1e fb          	endbr32 
801026a1:	55                   	push   %ebp
801026a2:	89 e5                	mov    %esp,%ebp
801026a4:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026a7:	83 ec 04             	sub    $0x4,%esp
801026aa:	ff 75 0c             	pushl  0xc(%ebp)
801026ad:	6a 01                	push   $0x1
801026af:	ff 75 08             	pushl  0x8(%ebp)
801026b2:	e8 a3 fe ff ff       	call   8010255a <namex>
801026b7:	83 c4 10             	add    $0x10,%esp
}
801026ba:	c9                   	leave  
801026bb:	c3                   	ret    

801026bc <inb>:
{
801026bc:	55                   	push   %ebp
801026bd:	89 e5                	mov    %esp,%ebp
801026bf:	83 ec 14             	sub    $0x14,%esp
801026c2:	8b 45 08             	mov    0x8(%ebp),%eax
801026c5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026c9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026cd:	89 c2                	mov    %eax,%edx
801026cf:	ec                   	in     (%dx),%al
801026d0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026d3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026d7:	c9                   	leave  
801026d8:	c3                   	ret    

801026d9 <insl>:
{
801026d9:	55                   	push   %ebp
801026da:	89 e5                	mov    %esp,%ebp
801026dc:	57                   	push   %edi
801026dd:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026de:	8b 55 08             	mov    0x8(%ebp),%edx
801026e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026e4:	8b 45 10             	mov    0x10(%ebp),%eax
801026e7:	89 cb                	mov    %ecx,%ebx
801026e9:	89 df                	mov    %ebx,%edi
801026eb:	89 c1                	mov    %eax,%ecx
801026ed:	fc                   	cld    
801026ee:	f3 6d                	rep insl (%dx),%es:(%edi)
801026f0:	89 c8                	mov    %ecx,%eax
801026f2:	89 fb                	mov    %edi,%ebx
801026f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026f7:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026fa:	90                   	nop
801026fb:	5b                   	pop    %ebx
801026fc:	5f                   	pop    %edi
801026fd:	5d                   	pop    %ebp
801026fe:	c3                   	ret    

801026ff <outb>:
{
801026ff:	55                   	push   %ebp
80102700:	89 e5                	mov    %esp,%ebp
80102702:	83 ec 08             	sub    $0x8,%esp
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 55 0c             	mov    0xc(%ebp),%edx
8010270b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010270f:	89 d0                	mov    %edx,%eax
80102711:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102714:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102718:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010271c:	ee                   	out    %al,(%dx)
}
8010271d:	90                   	nop
8010271e:	c9                   	leave  
8010271f:	c3                   	ret    

80102720 <outsl>:
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	56                   	push   %esi
80102724:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102725:	8b 55 08             	mov    0x8(%ebp),%edx
80102728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010272b:	8b 45 10             	mov    0x10(%ebp),%eax
8010272e:	89 cb                	mov    %ecx,%ebx
80102730:	89 de                	mov    %ebx,%esi
80102732:	89 c1                	mov    %eax,%ecx
80102734:	fc                   	cld    
80102735:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102737:	89 c8                	mov    %ecx,%eax
80102739:	89 f3                	mov    %esi,%ebx
8010273b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010273e:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102741:	90                   	nop
80102742:	5b                   	pop    %ebx
80102743:	5e                   	pop    %esi
80102744:	5d                   	pop    %ebp
80102745:	c3                   	ret    

80102746 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102746:	f3 0f 1e fb          	endbr32 
8010274a:	55                   	push   %ebp
8010274b:	89 e5                	mov    %esp,%ebp
8010274d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102750:	90                   	nop
80102751:	68 f7 01 00 00       	push   $0x1f7
80102756:	e8 61 ff ff ff       	call   801026bc <inb>
8010275b:	83 c4 04             	add    $0x4,%esp
8010275e:	0f b6 c0             	movzbl %al,%eax
80102761:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102764:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102767:	25 c0 00 00 00       	and    $0xc0,%eax
8010276c:	83 f8 40             	cmp    $0x40,%eax
8010276f:	75 e0                	jne    80102751 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102771:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102775:	74 11                	je     80102788 <idewait+0x42>
80102777:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010277a:	83 e0 21             	and    $0x21,%eax
8010277d:	85 c0                	test   %eax,%eax
8010277f:	74 07                	je     80102788 <idewait+0x42>
    return -1;
80102781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102786:	eb 05                	jmp    8010278d <idewait+0x47>
  return 0;
80102788:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <ideinit>:

void
ideinit(void)
{
8010278f:	f3 0f 1e fb          	endbr32 
80102793:	55                   	push   %ebp
80102794:	89 e5                	mov    %esp,%ebp
80102796:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102799:	83 ec 08             	sub    $0x8,%esp
8010279c:	68 a7 94 10 80       	push   $0x801094a7
801027a1:	68 00 c6 10 80       	push   $0x8010c600
801027a6:	e8 30 2b 00 00       	call   801052db <initlock>
801027ab:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027ae:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027b3:	83 e8 01             	sub    $0x1,%eax
801027b6:	83 ec 08             	sub    $0x8,%esp
801027b9:	50                   	push   %eax
801027ba:	6a 0e                	push   $0xe
801027bc:	e8 bb 04 00 00       	call   80102c7c <ioapicenable>
801027c1:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027c4:	83 ec 0c             	sub    $0xc,%esp
801027c7:	6a 00                	push   $0x0
801027c9:	e8 78 ff ff ff       	call   80102746 <idewait>
801027ce:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027d1:	83 ec 08             	sub    $0x8,%esp
801027d4:	68 f0 00 00 00       	push   $0xf0
801027d9:	68 f6 01 00 00       	push   $0x1f6
801027de:	e8 1c ff ff ff       	call   801026ff <outb>
801027e3:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027ed:	eb 24                	jmp    80102813 <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027ef:	83 ec 0c             	sub    $0xc,%esp
801027f2:	68 f7 01 00 00       	push   $0x1f7
801027f7:	e8 c0 fe ff ff       	call   801026bc <inb>
801027fc:	83 c4 10             	add    $0x10,%esp
801027ff:	84 c0                	test   %al,%al
80102801:	74 0c                	je     8010280f <ideinit+0x80>
      havedisk1 = 1;
80102803:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
8010280a:	00 00 00 
      break;
8010280d:	eb 0d                	jmp    8010281c <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010280f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102813:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010281a:	7e d3                	jle    801027ef <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010281c:	83 ec 08             	sub    $0x8,%esp
8010281f:	68 e0 00 00 00       	push   $0xe0
80102824:	68 f6 01 00 00       	push   $0x1f6
80102829:	e8 d1 fe ff ff       	call   801026ff <outb>
8010282e:	83 c4 10             	add    $0x10,%esp
}
80102831:	90                   	nop
80102832:	c9                   	leave  
80102833:	c3                   	ret    

80102834 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102834:	f3 0f 1e fb          	endbr32 
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010283e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102842:	75 0d                	jne    80102851 <idestart+0x1d>
    panic("idestart");
80102844:	83 ec 0c             	sub    $0xc,%esp
80102847:	68 ab 94 10 80       	push   $0x801094ab
8010284c:	e8 b7 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102851:	8b 45 08             	mov    0x8(%ebp),%eax
80102854:	8b 40 08             	mov    0x8(%eax),%eax
80102857:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010285c:	76 0d                	jbe    8010286b <idestart+0x37>
    panic("incorrect blockno");
8010285e:	83 ec 0c             	sub    $0xc,%esp
80102861:	68 b4 94 10 80       	push   $0x801094b4
80102866:	e8 9d dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010286b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102872:	8b 45 08             	mov    0x8(%ebp),%eax
80102875:	8b 50 08             	mov    0x8(%eax),%edx
80102878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287b:	0f af c2             	imul   %edx,%eax
8010287e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102881:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102885:	75 07                	jne    8010288e <idestart+0x5a>
80102887:	b8 20 00 00 00       	mov    $0x20,%eax
8010288c:	eb 05                	jmp    80102893 <idestart+0x5f>
8010288e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102896:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010289a:	75 07                	jne    801028a3 <idestart+0x6f>
8010289c:	b8 30 00 00 00       	mov    $0x30,%eax
801028a1:	eb 05                	jmp    801028a8 <idestart+0x74>
801028a3:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028a8:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028ab:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028af:	7e 0d                	jle    801028be <idestart+0x8a>
801028b1:	83 ec 0c             	sub    $0xc,%esp
801028b4:	68 ab 94 10 80       	push   $0x801094ab
801028b9:	e8 4a dd ff ff       	call   80100608 <panic>

  idewait(0);
801028be:	83 ec 0c             	sub    $0xc,%esp
801028c1:	6a 00                	push   $0x0
801028c3:	e8 7e fe ff ff       	call   80102746 <idewait>
801028c8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028cb:	83 ec 08             	sub    $0x8,%esp
801028ce:	6a 00                	push   $0x0
801028d0:	68 f6 03 00 00       	push   $0x3f6
801028d5:	e8 25 fe ff ff       	call   801026ff <outb>
801028da:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e0:	0f b6 c0             	movzbl %al,%eax
801028e3:	83 ec 08             	sub    $0x8,%esp
801028e6:	50                   	push   %eax
801028e7:	68 f2 01 00 00       	push   $0x1f2
801028ec:	e8 0e fe ff ff       	call   801026ff <outb>
801028f1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801028f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028f7:	0f b6 c0             	movzbl %al,%eax
801028fa:	83 ec 08             	sub    $0x8,%esp
801028fd:	50                   	push   %eax
801028fe:	68 f3 01 00 00       	push   $0x1f3
80102903:	e8 f7 fd ff ff       	call   801026ff <outb>
80102908:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010290b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010290e:	c1 f8 08             	sar    $0x8,%eax
80102911:	0f b6 c0             	movzbl %al,%eax
80102914:	83 ec 08             	sub    $0x8,%esp
80102917:	50                   	push   %eax
80102918:	68 f4 01 00 00       	push   $0x1f4
8010291d:	e8 dd fd ff ff       	call   801026ff <outb>
80102922:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102928:	c1 f8 10             	sar    $0x10,%eax
8010292b:	0f b6 c0             	movzbl %al,%eax
8010292e:	83 ec 08             	sub    $0x8,%esp
80102931:	50                   	push   %eax
80102932:	68 f5 01 00 00       	push   $0x1f5
80102937:	e8 c3 fd ff ff       	call   801026ff <outb>
8010293c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010293f:	8b 45 08             	mov    0x8(%ebp),%eax
80102942:	8b 40 04             	mov    0x4(%eax),%eax
80102945:	c1 e0 04             	shl    $0x4,%eax
80102948:	83 e0 10             	and    $0x10,%eax
8010294b:	89 c2                	mov    %eax,%edx
8010294d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102950:	c1 f8 18             	sar    $0x18,%eax
80102953:	83 e0 0f             	and    $0xf,%eax
80102956:	09 d0                	or     %edx,%eax
80102958:	83 c8 e0             	or     $0xffffffe0,%eax
8010295b:	0f b6 c0             	movzbl %al,%eax
8010295e:	83 ec 08             	sub    $0x8,%esp
80102961:	50                   	push   %eax
80102962:	68 f6 01 00 00       	push   $0x1f6
80102967:	e8 93 fd ff ff       	call   801026ff <outb>
8010296c:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010296f:	8b 45 08             	mov    0x8(%ebp),%eax
80102972:	8b 00                	mov    (%eax),%eax
80102974:	83 e0 04             	and    $0x4,%eax
80102977:	85 c0                	test   %eax,%eax
80102979:	74 35                	je     801029b0 <idestart+0x17c>
    outb(0x1f7, write_cmd);
8010297b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010297e:	0f b6 c0             	movzbl %al,%eax
80102981:	83 ec 08             	sub    $0x8,%esp
80102984:	50                   	push   %eax
80102985:	68 f7 01 00 00       	push   $0x1f7
8010298a:	e8 70 fd ff ff       	call   801026ff <outb>
8010298f:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102992:	8b 45 08             	mov    0x8(%ebp),%eax
80102995:	83 c0 5c             	add    $0x5c,%eax
80102998:	83 ec 04             	sub    $0x4,%esp
8010299b:	68 80 00 00 00       	push   $0x80
801029a0:	50                   	push   %eax
801029a1:	68 f0 01 00 00       	push   $0x1f0
801029a6:	e8 75 fd ff ff       	call   80102720 <outsl>
801029ab:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029ae:	eb 17                	jmp    801029c7 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029b3:	0f b6 c0             	movzbl %al,%eax
801029b6:	83 ec 08             	sub    $0x8,%esp
801029b9:	50                   	push   %eax
801029ba:	68 f7 01 00 00       	push   $0x1f7
801029bf:	e8 3b fd ff ff       	call   801026ff <outb>
801029c4:	83 c4 10             	add    $0x10,%esp
}
801029c7:	90                   	nop
801029c8:	c9                   	leave  
801029c9:	c3                   	ret    

801029ca <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029ca:	f3 0f 1e fb          	endbr32 
801029ce:	55                   	push   %ebp
801029cf:	89 e5                	mov    %esp,%ebp
801029d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029d4:	83 ec 0c             	sub    $0xc,%esp
801029d7:	68 00 c6 10 80       	push   $0x8010c600
801029dc:	e8 20 29 00 00       	call   80105301 <acquire>
801029e1:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029e4:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029f0:	75 15                	jne    80102a07 <ideintr+0x3d>
    release(&idelock);
801029f2:	83 ec 0c             	sub    $0xc,%esp
801029f5:	68 00 c6 10 80       	push   $0x8010c600
801029fa:	e8 74 29 00 00       	call   80105373 <release>
801029ff:	83 c4 10             	add    $0x10,%esp
    return;
80102a02:	e9 9a 00 00 00       	jmp    80102aa1 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0a:	8b 40 58             	mov    0x58(%eax),%eax
80102a0d:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a15:	8b 00                	mov    (%eax),%eax
80102a17:	83 e0 04             	and    $0x4,%eax
80102a1a:	85 c0                	test   %eax,%eax
80102a1c:	75 2d                	jne    80102a4b <ideintr+0x81>
80102a1e:	83 ec 0c             	sub    $0xc,%esp
80102a21:	6a 01                	push   $0x1
80102a23:	e8 1e fd ff ff       	call   80102746 <idewait>
80102a28:	83 c4 10             	add    $0x10,%esp
80102a2b:	85 c0                	test   %eax,%eax
80102a2d:	78 1c                	js     80102a4b <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a32:	83 c0 5c             	add    $0x5c,%eax
80102a35:	83 ec 04             	sub    $0x4,%esp
80102a38:	68 80 00 00 00       	push   $0x80
80102a3d:	50                   	push   %eax
80102a3e:	68 f0 01 00 00       	push   $0x1f0
80102a43:	e8 91 fc ff ff       	call   801026d9 <insl>
80102a48:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4e:	8b 00                	mov    (%eax),%eax
80102a50:	83 c8 02             	or     $0x2,%eax
80102a53:	89 c2                	mov    %eax,%edx
80102a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a58:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5d:	8b 00                	mov    (%eax),%eax
80102a5f:	83 e0 fb             	and    $0xfffffffb,%eax
80102a62:	89 c2                	mov    %eax,%edx
80102a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a67:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a69:	83 ec 0c             	sub    $0xc,%esp
80102a6c:	ff 75 f4             	pushl  -0xc(%ebp)
80102a6f:	e8 ff 24 00 00       	call   80104f73 <wakeup>
80102a74:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a77:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a7c:	85 c0                	test   %eax,%eax
80102a7e:	74 11                	je     80102a91 <ideintr+0xc7>
    idestart(idequeue);
80102a80:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a85:	83 ec 0c             	sub    $0xc,%esp
80102a88:	50                   	push   %eax
80102a89:	e8 a6 fd ff ff       	call   80102834 <idestart>
80102a8e:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a91:	83 ec 0c             	sub    $0xc,%esp
80102a94:	68 00 c6 10 80       	push   $0x8010c600
80102a99:	e8 d5 28 00 00       	call   80105373 <release>
80102a9e:	83 c4 10             	add    $0x10,%esp
}
80102aa1:	c9                   	leave  
80102aa2:	c3                   	ret    

80102aa3 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102aa3:	f3 0f 1e fb          	endbr32 
80102aa7:	55                   	push   %ebp
80102aa8:	89 e5                	mov    %esp,%ebp
80102aaa:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102aad:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab0:	83 c0 0c             	add    $0xc,%eax
80102ab3:	83 ec 0c             	sub    $0xc,%esp
80102ab6:	50                   	push   %eax
80102ab7:	e8 86 27 00 00       	call   80105242 <holdingsleep>
80102abc:	83 c4 10             	add    $0x10,%esp
80102abf:	85 c0                	test   %eax,%eax
80102ac1:	75 0d                	jne    80102ad0 <iderw+0x2d>
    panic("iderw: buf not locked");
80102ac3:	83 ec 0c             	sub    $0xc,%esp
80102ac6:	68 c6 94 10 80       	push   $0x801094c6
80102acb:	e8 38 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad3:	8b 00                	mov    (%eax),%eax
80102ad5:	83 e0 06             	and    $0x6,%eax
80102ad8:	83 f8 02             	cmp    $0x2,%eax
80102adb:	75 0d                	jne    80102aea <iderw+0x47>
    panic("iderw: nothing to do");
80102add:	83 ec 0c             	sub    $0xc,%esp
80102ae0:	68 dc 94 10 80       	push   $0x801094dc
80102ae5:	e8 1e db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	8b 40 04             	mov    0x4(%eax),%eax
80102af0:	85 c0                	test   %eax,%eax
80102af2:	74 16                	je     80102b0a <iderw+0x67>
80102af4:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102af9:	85 c0                	test   %eax,%eax
80102afb:	75 0d                	jne    80102b0a <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102afd:	83 ec 0c             	sub    $0xc,%esp
80102b00:	68 f1 94 10 80       	push   $0x801094f1
80102b05:	e8 fe da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b0a:	83 ec 0c             	sub    $0xc,%esp
80102b0d:	68 00 c6 10 80       	push   $0x8010c600
80102b12:	e8 ea 27 00 00       	call   80105301 <acquire>
80102b17:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b24:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b2b:	eb 0b                	jmp    80102b38 <iderw+0x95>
80102b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b30:	8b 00                	mov    (%eax),%eax
80102b32:	83 c0 58             	add    $0x58,%eax
80102b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	8b 00                	mov    (%eax),%eax
80102b3d:	85 c0                	test   %eax,%eax
80102b3f:	75 ec                	jne    80102b2d <iderw+0x8a>
    ;
  *pp = b;
80102b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b44:	8b 55 08             	mov    0x8(%ebp),%edx
80102b47:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b49:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b4e:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b51:	75 23                	jne    80102b76 <iderw+0xd3>
    idestart(b);
80102b53:	83 ec 0c             	sub    $0xc,%esp
80102b56:	ff 75 08             	pushl  0x8(%ebp)
80102b59:	e8 d6 fc ff ff       	call   80102834 <idestart>
80102b5e:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b61:	eb 13                	jmp    80102b76 <iderw+0xd3>
    sleep(b, &idelock);
80102b63:	83 ec 08             	sub    $0x8,%esp
80102b66:	68 00 c6 10 80       	push   $0x8010c600
80102b6b:	ff 75 08             	pushl  0x8(%ebp)
80102b6e:	e8 0e 23 00 00       	call   80104e81 <sleep>
80102b73:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b76:	8b 45 08             	mov    0x8(%ebp),%eax
80102b79:	8b 00                	mov    (%eax),%eax
80102b7b:	83 e0 06             	and    $0x6,%eax
80102b7e:	83 f8 02             	cmp    $0x2,%eax
80102b81:	75 e0                	jne    80102b63 <iderw+0xc0>
  }


  release(&idelock);
80102b83:	83 ec 0c             	sub    $0xc,%esp
80102b86:	68 00 c6 10 80       	push   $0x8010c600
80102b8b:	e8 e3 27 00 00       	call   80105373 <release>
80102b90:	83 c4 10             	add    $0x10,%esp
}
80102b93:	90                   	nop
80102b94:	c9                   	leave  
80102b95:	c3                   	ret    

80102b96 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b96:	f3 0f 1e fb          	endbr32 
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b9d:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102ba2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ba5:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ba7:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bac:	8b 40 10             	mov    0x10(%eax),%eax
}
80102baf:	5d                   	pop    %ebp
80102bb0:	c3                   	ret    

80102bb1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bb1:	f3 0f 1e fb          	endbr32 
80102bb5:	55                   	push   %ebp
80102bb6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bb8:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bbd:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc0:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bc2:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bca:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bcd:	90                   	nop
80102bce:	5d                   	pop    %ebp
80102bcf:	c3                   	ret    

80102bd0 <ioapicinit>:

void
ioapicinit(void)
{
80102bd0:	f3 0f 1e fb          	endbr32 
80102bd4:	55                   	push   %ebp
80102bd5:	89 e5                	mov    %esp,%ebp
80102bd7:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bda:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102be1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102be4:	6a 01                	push   $0x1
80102be6:	e8 ab ff ff ff       	call   80102b96 <ioapicread>
80102beb:	83 c4 04             	add    $0x4,%esp
80102bee:	c1 e8 10             	shr    $0x10,%eax
80102bf1:	25 ff 00 00 00       	and    $0xff,%eax
80102bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bf9:	6a 00                	push   $0x0
80102bfb:	e8 96 ff ff ff       	call   80102b96 <ioapicread>
80102c00:	83 c4 04             	add    $0x4,%esp
80102c03:	c1 e8 18             	shr    $0x18,%eax
80102c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c09:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c10:	0f b6 c0             	movzbl %al,%eax
80102c13:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c16:	74 10                	je     80102c28 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c18:	83 ec 0c             	sub    $0xc,%esp
80102c1b:	68 10 95 10 80       	push   $0x80109510
80102c20:	e8 f3 d7 ff ff       	call   80100418 <cprintf>
80102c25:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c2f:	eb 3f                	jmp    80102c70 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c34:	83 c0 20             	add    $0x20,%eax
80102c37:	0d 00 00 01 00       	or     $0x10000,%eax
80102c3c:	89 c2                	mov    %eax,%edx
80102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c41:	83 c0 08             	add    $0x8,%eax
80102c44:	01 c0                	add    %eax,%eax
80102c46:	83 ec 08             	sub    $0x8,%esp
80102c49:	52                   	push   %edx
80102c4a:	50                   	push   %eax
80102c4b:	e8 61 ff ff ff       	call   80102bb1 <ioapicwrite>
80102c50:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c56:	83 c0 08             	add    $0x8,%eax
80102c59:	01 c0                	add    %eax,%eax
80102c5b:	83 c0 01             	add    $0x1,%eax
80102c5e:	83 ec 08             	sub    $0x8,%esp
80102c61:	6a 00                	push   $0x0
80102c63:	50                   	push   %eax
80102c64:	e8 48 ff ff ff       	call   80102bb1 <ioapicwrite>
80102c69:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c73:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c76:	7e b9                	jle    80102c31 <ioapicinit+0x61>
  }
}
80102c78:	90                   	nop
80102c79:	90                   	nop
80102c7a:	c9                   	leave  
80102c7b:	c3                   	ret    

80102c7c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c7c:	f3 0f 1e fb          	endbr32 
80102c80:	55                   	push   %ebp
80102c81:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c83:	8b 45 08             	mov    0x8(%ebp),%eax
80102c86:	83 c0 20             	add    $0x20,%eax
80102c89:	89 c2                	mov    %eax,%edx
80102c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8e:	83 c0 08             	add    $0x8,%eax
80102c91:	01 c0                	add    %eax,%eax
80102c93:	52                   	push   %edx
80102c94:	50                   	push   %eax
80102c95:	e8 17 ff ff ff       	call   80102bb1 <ioapicwrite>
80102c9a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ca0:	c1 e0 18             	shl    $0x18,%eax
80102ca3:	89 c2                	mov    %eax,%edx
80102ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca8:	83 c0 08             	add    $0x8,%eax
80102cab:	01 c0                	add    %eax,%eax
80102cad:	83 c0 01             	add    $0x1,%eax
80102cb0:	52                   	push   %edx
80102cb1:	50                   	push   %eax
80102cb2:	e8 fa fe ff ff       	call   80102bb1 <ioapicwrite>
80102cb7:	83 c4 08             	add    $0x8,%esp
}
80102cba:	90                   	nop
80102cbb:	c9                   	leave  
80102cbc:	c3                   	ret    

80102cbd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cbd:	f3 0f 1e fb          	endbr32 
80102cc1:	55                   	push   %ebp
80102cc2:	89 e5                	mov    %esp,%ebp
80102cc4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cc7:	83 ec 08             	sub    $0x8,%esp
80102cca:	68 42 95 10 80       	push   $0x80109542
80102ccf:	68 e0 46 11 80       	push   $0x801146e0
80102cd4:	e8 02 26 00 00       	call   801052db <initlock>
80102cd9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cdc:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102ce3:	00 00 00 
  freerange(vstart, vend);
80102ce6:	83 ec 08             	sub    $0x8,%esp
80102ce9:	ff 75 0c             	pushl  0xc(%ebp)
80102cec:	ff 75 08             	pushl  0x8(%ebp)
80102cef:	e8 2e 00 00 00       	call   80102d22 <freerange>
80102cf4:	83 c4 10             	add    $0x10,%esp
}
80102cf7:	90                   	nop
80102cf8:	c9                   	leave  
80102cf9:	c3                   	ret    

80102cfa <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102cfa:	f3 0f 1e fb          	endbr32 
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
80102d01:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d04:	83 ec 08             	sub    $0x8,%esp
80102d07:	ff 75 0c             	pushl  0xc(%ebp)
80102d0a:	ff 75 08             	pushl  0x8(%ebp)
80102d0d:	e8 10 00 00 00       	call   80102d22 <freerange>
80102d12:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d15:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d1c:	00 00 00 
}
80102d1f:	90                   	nop
80102d20:	c9                   	leave  
80102d21:	c3                   	ret    

80102d22 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d22:	f3 0f 1e fb          	endbr32 
80102d26:	55                   	push   %ebp
80102d27:	89 e5                	mov    %esp,%ebp
80102d29:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d2f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d3c:	eb 15                	jmp    80102d53 <freerange+0x31>
    kfree(p);
80102d3e:	83 ec 0c             	sub    $0xc,%esp
80102d41:	ff 75 f4             	pushl  -0xc(%ebp)
80102d44:	e8 1b 00 00 00       	call   80102d64 <kfree>
80102d49:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d4c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d56:	05 00 10 00 00       	add    $0x1000,%eax
80102d5b:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d5e:	73 de                	jae    80102d3e <freerange+0x1c>
}
80102d60:	90                   	nop
80102d61:	90                   	nop
80102d62:	c9                   	leave  
80102d63:	c3                   	ret    

80102d64 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d64:	f3 0f 1e fb          	endbr32 
80102d68:	55                   	push   %ebp
80102d69:	89 e5                	mov    %esp,%ebp
80102d6b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d71:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d76:	85 c0                	test   %eax,%eax
80102d78:	75 18                	jne    80102d92 <kfree+0x2e>
80102d7a:	81 7d 08 48 8e 11 80 	cmpl   $0x80118e48,0x8(%ebp)
80102d81:	72 0f                	jb     80102d92 <kfree+0x2e>
80102d83:	8b 45 08             	mov    0x8(%ebp),%eax
80102d86:	05 00 00 00 80       	add    $0x80000000,%eax
80102d8b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d90:	76 0d                	jbe    80102d9f <kfree+0x3b>
    panic("kfree");
80102d92:	83 ec 0c             	sub    $0xc,%esp
80102d95:	68 47 95 10 80       	push   $0x80109547
80102d9a:	e8 69 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d9f:	83 ec 04             	sub    $0x4,%esp
80102da2:	68 00 10 00 00       	push   $0x1000
80102da7:	6a 01                	push   $0x1
80102da9:	ff 75 08             	pushl  0x8(%ebp)
80102dac:	e8 ef 27 00 00       	call   801055a0 <memset>
80102db1:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102db4:	a1 14 47 11 80       	mov    0x80114714,%eax
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	74 10                	je     80102dcd <kfree+0x69>
    acquire(&kmem.lock);
80102dbd:	83 ec 0c             	sub    $0xc,%esp
80102dc0:	68 e0 46 11 80       	push   $0x801146e0
80102dc5:	e8 37 25 00 00       	call   80105301 <acquire>
80102dca:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102dd3:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ddc:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102de1:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102de6:	a1 14 47 11 80       	mov    0x80114714,%eax
80102deb:	85 c0                	test   %eax,%eax
80102ded:	74 10                	je     80102dff <kfree+0x9b>
    release(&kmem.lock);
80102def:	83 ec 0c             	sub    $0xc,%esp
80102df2:	68 e0 46 11 80       	push   $0x801146e0
80102df7:	e8 77 25 00 00       	call   80105373 <release>
80102dfc:	83 c4 10             	add    $0x10,%esp
}
80102dff:	90                   	nop
80102e00:	c9                   	leave  
80102e01:	c3                   	ret    

80102e02 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e02:	f3 0f 1e fb          	endbr32 
80102e06:	55                   	push   %ebp
80102e07:	89 e5                	mov    %esp,%ebp
80102e09:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e0c:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e11:	85 c0                	test   %eax,%eax
80102e13:	74 10                	je     80102e25 <kalloc+0x23>
    acquire(&kmem.lock);
80102e15:	83 ec 0c             	sub    $0xc,%esp
80102e18:	68 e0 46 11 80       	push   $0x801146e0
80102e1d:	e8 df 24 00 00       	call   80105301 <acquire>
80102e22:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e25:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e31:	74 0a                	je     80102e3d <kalloc+0x3b>
    kmem.freelist = r->next;
80102e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e36:	8b 00                	mov    (%eax),%eax
80102e38:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e3d:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e42:	85 c0                	test   %eax,%eax
80102e44:	74 10                	je     80102e56 <kalloc+0x54>
    release(&kmem.lock);
80102e46:	83 ec 0c             	sub    $0xc,%esp
80102e49:	68 e0 46 11 80       	push   $0x801146e0
80102e4e:	e8 20 25 00 00       	call   80105373 <release>
80102e53:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e59:	c9                   	leave  
80102e5a:	c3                   	ret    

80102e5b <inb>:
{
80102e5b:	55                   	push   %ebp
80102e5c:	89 e5                	mov    %esp,%ebp
80102e5e:	83 ec 14             	sub    $0x14,%esp
80102e61:	8b 45 08             	mov    0x8(%ebp),%eax
80102e64:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e68:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6c:	89 c2                	mov    %eax,%edx
80102e6e:	ec                   	in     (%dx),%al
80102e6f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e72:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e78:	f3 0f 1e fb          	endbr32 
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e82:	6a 64                	push   $0x64
80102e84:	e8 d2 ff ff ff       	call   80102e5b <inb>
80102e89:	83 c4 04             	add    $0x4,%esp
80102e8c:	0f b6 c0             	movzbl %al,%eax
80102e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e95:	83 e0 01             	and    $0x1,%eax
80102e98:	85 c0                	test   %eax,%eax
80102e9a:	75 0a                	jne    80102ea6 <kbdgetc+0x2e>
    return -1;
80102e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ea1:	e9 23 01 00 00       	jmp    80102fc9 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102ea6:	6a 60                	push   $0x60
80102ea8:	e8 ae ff ff ff       	call   80102e5b <inb>
80102ead:	83 c4 04             	add    $0x4,%esp
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102eb6:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ebd:	75 17                	jne    80102ed6 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ebf:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ec4:	83 c8 40             	or     $0x40,%eax
80102ec7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102ecc:	b8 00 00 00 00       	mov    $0x0,%eax
80102ed1:	e9 f3 00 00 00       	jmp    80102fc9 <kbdgetc+0x151>
  } else if(data & 0x80){
80102ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed9:	25 80 00 00 00       	and    $0x80,%eax
80102ede:	85 c0                	test   %eax,%eax
80102ee0:	74 45                	je     80102f27 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ee2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ee7:	83 e0 40             	and    $0x40,%eax
80102eea:	85 c0                	test   %eax,%eax
80102eec:	75 08                	jne    80102ef6 <kbdgetc+0x7e>
80102eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef1:	83 e0 7f             	and    $0x7f,%eax
80102ef4:	eb 03                	jmp    80102ef9 <kbdgetc+0x81>
80102ef6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eff:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f04:	0f b6 00             	movzbl (%eax),%eax
80102f07:	83 c8 40             	or     $0x40,%eax
80102f0a:	0f b6 c0             	movzbl %al,%eax
80102f0d:	f7 d0                	not    %eax
80102f0f:	89 c2                	mov    %eax,%edx
80102f11:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f16:	21 d0                	and    %edx,%eax
80102f18:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f22:	e9 a2 00 00 00       	jmp    80102fc9 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f27:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f2c:	83 e0 40             	and    $0x40,%eax
80102f2f:	85 c0                	test   %eax,%eax
80102f31:	74 14                	je     80102f47 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f33:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f3a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f3f:	83 e0 bf             	and    $0xffffffbf,%eax
80102f42:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f4f:	0f b6 00             	movzbl (%eax),%eax
80102f52:	0f b6 d0             	movzbl %al,%edx
80102f55:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f5a:	09 d0                	or     %edx,%eax
80102f5c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f64:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f69:	0f b6 00             	movzbl (%eax),%eax
80102f6c:	0f b6 d0             	movzbl %al,%edx
80102f6f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f74:	31 d0                	xor    %edx,%eax
80102f76:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f7b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f80:	83 e0 03             	and    $0x3,%eax
80102f83:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8d:	01 d0                	add    %edx,%eax
80102f8f:	0f b6 00             	movzbl (%eax),%eax
80102f92:	0f b6 c0             	movzbl %al,%eax
80102f95:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f98:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f9d:	83 e0 08             	and    $0x8,%eax
80102fa0:	85 c0                	test   %eax,%eax
80102fa2:	74 22                	je     80102fc6 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fa4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fa8:	76 0c                	jbe    80102fb6 <kbdgetc+0x13e>
80102faa:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fae:	77 06                	ja     80102fb6 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fb0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fb4:	eb 10                	jmp    80102fc6 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fb6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fba:	76 0a                	jbe    80102fc6 <kbdgetc+0x14e>
80102fbc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fc0:	77 04                	ja     80102fc6 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fc2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fc9:	c9                   	leave  
80102fca:	c3                   	ret    

80102fcb <kbdintr>:

void
kbdintr(void)
{
80102fcb:	f3 0f 1e fb          	endbr32 
80102fcf:	55                   	push   %ebp
80102fd0:	89 e5                	mov    %esp,%ebp
80102fd2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102fd5:	83 ec 0c             	sub    $0xc,%esp
80102fd8:	68 78 2e 10 80       	push   $0x80102e78
80102fdd:	e8 c6 d8 ff ff       	call   801008a8 <consoleintr>
80102fe2:	83 c4 10             	add    $0x10,%esp
}
80102fe5:	90                   	nop
80102fe6:	c9                   	leave  
80102fe7:	c3                   	ret    

80102fe8 <inb>:
{
80102fe8:	55                   	push   %ebp
80102fe9:	89 e5                	mov    %esp,%ebp
80102feb:	83 ec 14             	sub    $0x14,%esp
80102fee:	8b 45 08             	mov    0x8(%ebp),%eax
80102ff1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ff5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ff9:	89 c2                	mov    %eax,%edx
80102ffb:	ec                   	in     (%dx),%al
80102ffc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102fff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103003:	c9                   	leave  
80103004:	c3                   	ret    

80103005 <outb>:
{
80103005:	55                   	push   %ebp
80103006:	89 e5                	mov    %esp,%ebp
80103008:	83 ec 08             	sub    $0x8,%esp
8010300b:	8b 45 08             	mov    0x8(%ebp),%eax
8010300e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103011:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103015:	89 d0                	mov    %edx,%eax
80103017:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010301a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010301e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103022:	ee                   	out    %al,(%dx)
}
80103023:	90                   	nop
80103024:	c9                   	leave  
80103025:	c3                   	ret    

80103026 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103026:	f3 0f 1e fb          	endbr32 
8010302a:	55                   	push   %ebp
8010302b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010302d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103032:	8b 55 08             	mov    0x8(%ebp),%edx
80103035:	c1 e2 02             	shl    $0x2,%edx
80103038:	01 c2                	add    %eax,%edx
8010303a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010303d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010303f:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103044:	83 c0 20             	add    $0x20,%eax
80103047:	8b 00                	mov    (%eax),%eax
}
80103049:	90                   	nop
8010304a:	5d                   	pop    %ebp
8010304b:	c3                   	ret    

8010304c <lapicinit>:

void
lapicinit(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80103053:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	0f 84 0c 01 00 00    	je     8010316c <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103060:	68 3f 01 00 00       	push   $0x13f
80103065:	6a 3c                	push   $0x3c
80103067:	e8 ba ff ff ff       	call   80103026 <lapicw>
8010306c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010306f:	6a 0b                	push   $0xb
80103071:	68 f8 00 00 00       	push   $0xf8
80103076:	e8 ab ff ff ff       	call   80103026 <lapicw>
8010307b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010307e:	68 20 00 02 00       	push   $0x20020
80103083:	68 c8 00 00 00       	push   $0xc8
80103088:	e8 99 ff ff ff       	call   80103026 <lapicw>
8010308d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103090:	68 80 96 98 00       	push   $0x989680
80103095:	68 e0 00 00 00       	push   $0xe0
8010309a:	e8 87 ff ff ff       	call   80103026 <lapicw>
8010309f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030a2:	68 00 00 01 00       	push   $0x10000
801030a7:	68 d4 00 00 00       	push   $0xd4
801030ac:	e8 75 ff ff ff       	call   80103026 <lapicw>
801030b1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030b4:	68 00 00 01 00       	push   $0x10000
801030b9:	68 d8 00 00 00       	push   $0xd8
801030be:	e8 63 ff ff ff       	call   80103026 <lapicw>
801030c3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030c6:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030cb:	83 c0 30             	add    $0x30,%eax
801030ce:	8b 00                	mov    (%eax),%eax
801030d0:	c1 e8 10             	shr    $0x10,%eax
801030d3:	25 fc 00 00 00       	and    $0xfc,%eax
801030d8:	85 c0                	test   %eax,%eax
801030da:	74 12                	je     801030ee <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030dc:	68 00 00 01 00       	push   $0x10000
801030e1:	68 d0 00 00 00       	push   $0xd0
801030e6:	e8 3b ff ff ff       	call   80103026 <lapicw>
801030eb:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030ee:	6a 33                	push   $0x33
801030f0:	68 dc 00 00 00       	push   $0xdc
801030f5:	e8 2c ff ff ff       	call   80103026 <lapicw>
801030fa:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030fd:	6a 00                	push   $0x0
801030ff:	68 a0 00 00 00       	push   $0xa0
80103104:	e8 1d ff ff ff       	call   80103026 <lapicw>
80103109:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010310c:	6a 00                	push   $0x0
8010310e:	68 a0 00 00 00       	push   $0xa0
80103113:	e8 0e ff ff ff       	call   80103026 <lapicw>
80103118:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010311b:	6a 00                	push   $0x0
8010311d:	6a 2c                	push   $0x2c
8010311f:	e8 02 ff ff ff       	call   80103026 <lapicw>
80103124:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103127:	6a 00                	push   $0x0
80103129:	68 c4 00 00 00       	push   $0xc4
8010312e:	e8 f3 fe ff ff       	call   80103026 <lapicw>
80103133:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103136:	68 00 85 08 00       	push   $0x88500
8010313b:	68 c0 00 00 00       	push   $0xc0
80103140:	e8 e1 fe ff ff       	call   80103026 <lapicw>
80103145:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103148:	90                   	nop
80103149:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010314e:	05 00 03 00 00       	add    $0x300,%eax
80103153:	8b 00                	mov    (%eax),%eax
80103155:	25 00 10 00 00       	and    $0x1000,%eax
8010315a:	85 c0                	test   %eax,%eax
8010315c:	75 eb                	jne    80103149 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010315e:	6a 00                	push   $0x0
80103160:	6a 20                	push   $0x20
80103162:	e8 bf fe ff ff       	call   80103026 <lapicw>
80103167:	83 c4 08             	add    $0x8,%esp
8010316a:	eb 01                	jmp    8010316d <lapicinit+0x121>
    return;
8010316c:	90                   	nop
}
8010316d:	c9                   	leave  
8010316e:	c3                   	ret    

8010316f <lapicid>:

int
lapicid(void)
{
8010316f:	f3 0f 1e fb          	endbr32 
80103173:	55                   	push   %ebp
80103174:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103176:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010317b:	85 c0                	test   %eax,%eax
8010317d:	75 07                	jne    80103186 <lapicid+0x17>
    return 0;
8010317f:	b8 00 00 00 00       	mov    $0x0,%eax
80103184:	eb 0d                	jmp    80103193 <lapicid+0x24>
  return lapic[ID] >> 24;
80103186:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010318b:	83 c0 20             	add    $0x20,%eax
8010318e:	8b 00                	mov    (%eax),%eax
80103190:	c1 e8 18             	shr    $0x18,%eax
}
80103193:	5d                   	pop    %ebp
80103194:	c3                   	ret    

80103195 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103195:	f3 0f 1e fb          	endbr32 
80103199:	55                   	push   %ebp
8010319a:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010319c:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031a1:	85 c0                	test   %eax,%eax
801031a3:	74 0c                	je     801031b1 <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031a5:	6a 00                	push   $0x0
801031a7:	6a 2c                	push   $0x2c
801031a9:	e8 78 fe ff ff       	call   80103026 <lapicw>
801031ae:	83 c4 08             	add    $0x8,%esp
}
801031b1:	90                   	nop
801031b2:	c9                   	leave  
801031b3:	c3                   	ret    

801031b4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031b4:	f3 0f 1e fb          	endbr32 
801031b8:	55                   	push   %ebp
801031b9:	89 e5                	mov    %esp,%ebp
}
801031bb:	90                   	nop
801031bc:	5d                   	pop    %ebp
801031bd:	c3                   	ret    

801031be <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031be:	f3 0f 1e fb          	endbr32 
801031c2:	55                   	push   %ebp
801031c3:	89 e5                	mov    %esp,%ebp
801031c5:	83 ec 14             	sub    $0x14,%esp
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031ce:	6a 0f                	push   $0xf
801031d0:	6a 70                	push   $0x70
801031d2:	e8 2e fe ff ff       	call   80103005 <outb>
801031d7:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031da:	6a 0a                	push   $0xa
801031dc:	6a 71                	push   $0x71
801031de:	e8 22 fe ff ff       	call   80103005 <outb>
801031e3:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031e6:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031f0:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f8:	c1 e8 04             	shr    $0x4,%eax
801031fb:	89 c2                	mov    %eax,%edx
801031fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103200:	83 c0 02             	add    $0x2,%eax
80103203:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103206:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010320a:	c1 e0 18             	shl    $0x18,%eax
8010320d:	50                   	push   %eax
8010320e:	68 c4 00 00 00       	push   $0xc4
80103213:	e8 0e fe ff ff       	call   80103026 <lapicw>
80103218:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010321b:	68 00 c5 00 00       	push   $0xc500
80103220:	68 c0 00 00 00       	push   $0xc0
80103225:	e8 fc fd ff ff       	call   80103026 <lapicw>
8010322a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010322d:	68 c8 00 00 00       	push   $0xc8
80103232:	e8 7d ff ff ff       	call   801031b4 <microdelay>
80103237:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010323a:	68 00 85 00 00       	push   $0x8500
8010323f:	68 c0 00 00 00       	push   $0xc0
80103244:	e8 dd fd ff ff       	call   80103026 <lapicw>
80103249:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010324c:	6a 64                	push   $0x64
8010324e:	e8 61 ff ff ff       	call   801031b4 <microdelay>
80103253:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103256:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010325d:	eb 3d                	jmp    8010329c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
8010325f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103263:	c1 e0 18             	shl    $0x18,%eax
80103266:	50                   	push   %eax
80103267:	68 c4 00 00 00       	push   $0xc4
8010326c:	e8 b5 fd ff ff       	call   80103026 <lapicw>
80103271:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103274:	8b 45 0c             	mov    0xc(%ebp),%eax
80103277:	c1 e8 0c             	shr    $0xc,%eax
8010327a:	80 cc 06             	or     $0x6,%ah
8010327d:	50                   	push   %eax
8010327e:	68 c0 00 00 00       	push   $0xc0
80103283:	e8 9e fd ff ff       	call   80103026 <lapicw>
80103288:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010328b:	68 c8 00 00 00       	push   $0xc8
80103290:	e8 1f ff ff ff       	call   801031b4 <microdelay>
80103295:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103298:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010329c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032a0:	7e bd                	jle    8010325f <lapicstartap+0xa1>
  }
}
801032a2:	90                   	nop
801032a3:	90                   	nop
801032a4:	c9                   	leave  
801032a5:	c3                   	ret    

801032a6 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032a6:	f3 0f 1e fb          	endbr32 
801032aa:	55                   	push   %ebp
801032ab:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032ad:	8b 45 08             	mov    0x8(%ebp),%eax
801032b0:	0f b6 c0             	movzbl %al,%eax
801032b3:	50                   	push   %eax
801032b4:	6a 70                	push   $0x70
801032b6:	e8 4a fd ff ff       	call   80103005 <outb>
801032bb:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032be:	68 c8 00 00 00       	push   $0xc8
801032c3:	e8 ec fe ff ff       	call   801031b4 <microdelay>
801032c8:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032cb:	6a 71                	push   $0x71
801032cd:	e8 16 fd ff ff       	call   80102fe8 <inb>
801032d2:	83 c4 04             	add    $0x4,%esp
801032d5:	0f b6 c0             	movzbl %al,%eax
}
801032d8:	c9                   	leave  
801032d9:	c3                   	ret    

801032da <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032da:	f3 0f 1e fb          	endbr32 
801032de:	55                   	push   %ebp
801032df:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801032e1:	6a 00                	push   $0x0
801032e3:	e8 be ff ff ff       	call   801032a6 <cmos_read>
801032e8:	83 c4 04             	add    $0x4,%esp
801032eb:	8b 55 08             	mov    0x8(%ebp),%edx
801032ee:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032f0:	6a 02                	push   $0x2
801032f2:	e8 af ff ff ff       	call   801032a6 <cmos_read>
801032f7:	83 c4 04             	add    $0x4,%esp
801032fa:	8b 55 08             	mov    0x8(%ebp),%edx
801032fd:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103300:	6a 04                	push   $0x4
80103302:	e8 9f ff ff ff       	call   801032a6 <cmos_read>
80103307:	83 c4 04             	add    $0x4,%esp
8010330a:	8b 55 08             	mov    0x8(%ebp),%edx
8010330d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103310:	6a 07                	push   $0x7
80103312:	e8 8f ff ff ff       	call   801032a6 <cmos_read>
80103317:	83 c4 04             	add    $0x4,%esp
8010331a:	8b 55 08             	mov    0x8(%ebp),%edx
8010331d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103320:	6a 08                	push   $0x8
80103322:	e8 7f ff ff ff       	call   801032a6 <cmos_read>
80103327:	83 c4 04             	add    $0x4,%esp
8010332a:	8b 55 08             	mov    0x8(%ebp),%edx
8010332d:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103330:	6a 09                	push   $0x9
80103332:	e8 6f ff ff ff       	call   801032a6 <cmos_read>
80103337:	83 c4 04             	add    $0x4,%esp
8010333a:	8b 55 08             	mov    0x8(%ebp),%edx
8010333d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103340:	90                   	nop
80103341:	c9                   	leave  
80103342:	c3                   	ret    

80103343 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80103343:	f3 0f 1e fb          	endbr32 
80103347:	55                   	push   %ebp
80103348:	89 e5                	mov    %esp,%ebp
8010334a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010334d:	6a 0b                	push   $0xb
8010334f:	e8 52 ff ff ff       	call   801032a6 <cmos_read>
80103354:	83 c4 04             	add    $0x4,%esp
80103357:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010335a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010335d:	83 e0 04             	and    $0x4,%eax
80103360:	85 c0                	test   %eax,%eax
80103362:	0f 94 c0             	sete   %al
80103365:	0f b6 c0             	movzbl %al,%eax
80103368:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010336b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010336e:	50                   	push   %eax
8010336f:	e8 66 ff ff ff       	call   801032da <fill_rtcdate>
80103374:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103377:	6a 0a                	push   $0xa
80103379:	e8 28 ff ff ff       	call   801032a6 <cmos_read>
8010337e:	83 c4 04             	add    $0x4,%esp
80103381:	25 80 00 00 00       	and    $0x80,%eax
80103386:	85 c0                	test   %eax,%eax
80103388:	75 27                	jne    801033b1 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
8010338a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010338d:	50                   	push   %eax
8010338e:	e8 47 ff ff ff       	call   801032da <fill_rtcdate>
80103393:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103396:	83 ec 04             	sub    $0x4,%esp
80103399:	6a 18                	push   $0x18
8010339b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010339e:	50                   	push   %eax
8010339f:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033a2:	50                   	push   %eax
801033a3:	e8 63 22 00 00       	call   8010560b <memcmp>
801033a8:	83 c4 10             	add    $0x10,%esp
801033ab:	85 c0                	test   %eax,%eax
801033ad:	74 05                	je     801033b4 <cmostime+0x71>
801033af:	eb ba                	jmp    8010336b <cmostime+0x28>
        continue;
801033b1:	90                   	nop
    fill_rtcdate(&t1);
801033b2:	eb b7                	jmp    8010336b <cmostime+0x28>
      break;
801033b4:	90                   	nop
  }

  // convert
  if(bcd) {
801033b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033b9:	0f 84 b4 00 00 00    	je     80103473 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033c2:	c1 e8 04             	shr    $0x4,%eax
801033c5:	89 c2                	mov    %eax,%edx
801033c7:	89 d0                	mov    %edx,%eax
801033c9:	c1 e0 02             	shl    $0x2,%eax
801033cc:	01 d0                	add    %edx,%eax
801033ce:	01 c0                	add    %eax,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033d5:	83 e0 0f             	and    $0xf,%eax
801033d8:	01 d0                	add    %edx,%eax
801033da:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033e0:	c1 e8 04             	shr    $0x4,%eax
801033e3:	89 c2                	mov    %eax,%edx
801033e5:	89 d0                	mov    %edx,%eax
801033e7:	c1 e0 02             	shl    $0x2,%eax
801033ea:	01 d0                	add    %edx,%eax
801033ec:	01 c0                	add    %eax,%eax
801033ee:	89 c2                	mov    %eax,%edx
801033f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033f3:	83 e0 0f             	and    $0xf,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801033fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801033fe:	c1 e8 04             	shr    $0x4,%eax
80103401:	89 c2                	mov    %eax,%edx
80103403:	89 d0                	mov    %edx,%eax
80103405:	c1 e0 02             	shl    $0x2,%eax
80103408:	01 d0                	add    %edx,%eax
8010340a:	01 c0                	add    %eax,%eax
8010340c:	89 c2                	mov    %eax,%edx
8010340e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103411:	83 e0 0f             	and    $0xf,%eax
80103414:	01 d0                	add    %edx,%eax
80103416:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103419:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010341c:	c1 e8 04             	shr    $0x4,%eax
8010341f:	89 c2                	mov    %eax,%edx
80103421:	89 d0                	mov    %edx,%eax
80103423:	c1 e0 02             	shl    $0x2,%eax
80103426:	01 d0                	add    %edx,%eax
80103428:	01 c0                	add    %eax,%eax
8010342a:	89 c2                	mov    %eax,%edx
8010342c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010342f:	83 e0 0f             	and    $0xf,%eax
80103432:	01 d0                	add    %edx,%eax
80103434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103437:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010343a:	c1 e8 04             	shr    $0x4,%eax
8010343d:	89 c2                	mov    %eax,%edx
8010343f:	89 d0                	mov    %edx,%eax
80103441:	c1 e0 02             	shl    $0x2,%eax
80103444:	01 d0                	add    %edx,%eax
80103446:	01 c0                	add    %eax,%eax
80103448:	89 c2                	mov    %eax,%edx
8010344a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010344d:	83 e0 0f             	and    $0xf,%eax
80103450:	01 d0                	add    %edx,%eax
80103452:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103455:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103458:	c1 e8 04             	shr    $0x4,%eax
8010345b:	89 c2                	mov    %eax,%edx
8010345d:	89 d0                	mov    %edx,%eax
8010345f:	c1 e0 02             	shl    $0x2,%eax
80103462:	01 d0                	add    %edx,%eax
80103464:	01 c0                	add    %eax,%eax
80103466:	89 c2                	mov    %eax,%edx
80103468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346b:	83 e0 0f             	and    $0xf,%eax
8010346e:	01 d0                	add    %edx,%eax
80103470:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103473:	8b 45 08             	mov    0x8(%ebp),%eax
80103476:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103479:	89 10                	mov    %edx,(%eax)
8010347b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010347e:	89 50 04             	mov    %edx,0x4(%eax)
80103481:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103484:	89 50 08             	mov    %edx,0x8(%eax)
80103487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010348a:	89 50 0c             	mov    %edx,0xc(%eax)
8010348d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103490:	89 50 10             	mov    %edx,0x10(%eax)
80103493:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103496:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103499:	8b 45 08             	mov    0x8(%ebp),%eax
8010349c:	8b 40 14             	mov    0x14(%eax),%eax
8010349f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034a5:	8b 45 08             	mov    0x8(%ebp),%eax
801034a8:	89 50 14             	mov    %edx,0x14(%eax)
}
801034ab:	90                   	nop
801034ac:	c9                   	leave  
801034ad:	c3                   	ret    

801034ae <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034ae:	f3 0f 1e fb          	endbr32 
801034b2:	55                   	push   %ebp
801034b3:	89 e5                	mov    %esp,%ebp
801034b5:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034b8:	83 ec 08             	sub    $0x8,%esp
801034bb:	68 4d 95 10 80       	push   $0x8010954d
801034c0:	68 20 47 11 80       	push   $0x80114720
801034c5:	e8 11 1e 00 00       	call   801052db <initlock>
801034ca:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034cd:	83 ec 08             	sub    $0x8,%esp
801034d0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034d3:	50                   	push   %eax
801034d4:	ff 75 08             	pushl  0x8(%ebp)
801034d7:	e8 f9 df ff ff       	call   801014d5 <readsb>
801034dc:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e2:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
801034e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034ea:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
801034ef:	8b 45 08             	mov    0x8(%ebp),%eax
801034f2:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
801034f7:	e8 bf 01 00 00       	call   801036bb <recover_from_log>
}
801034fc:	90                   	nop
801034fd:	c9                   	leave  
801034fe:	c3                   	ret    

801034ff <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034ff:	f3 0f 1e fb          	endbr32 
80103503:	55                   	push   %ebp
80103504:	89 e5                	mov    %esp,%ebp
80103506:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103509:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103510:	e9 95 00 00 00       	jmp    801035aa <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103515:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010351b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010351e:	01 d0                	add    %edx,%eax
80103520:	83 c0 01             	add    $0x1,%eax
80103523:	89 c2                	mov    %eax,%edx
80103525:	a1 64 47 11 80       	mov    0x80114764,%eax
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	52                   	push   %edx
8010352e:	50                   	push   %eax
8010352f:	e8 a3 cc ff ff       	call   801001d7 <bread>
80103534:	83 c4 10             	add    $0x10,%esp
80103537:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010353a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010353d:	83 c0 10             	add    $0x10,%eax
80103540:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103547:	89 c2                	mov    %eax,%edx
80103549:	a1 64 47 11 80       	mov    0x80114764,%eax
8010354e:	83 ec 08             	sub    $0x8,%esp
80103551:	52                   	push   %edx
80103552:	50                   	push   %eax
80103553:	e8 7f cc ff ff       	call   801001d7 <bread>
80103558:	83 c4 10             	add    $0x10,%esp
8010355b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010355e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103561:	8d 50 5c             	lea    0x5c(%eax),%edx
80103564:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103567:	83 c0 5c             	add    $0x5c,%eax
8010356a:	83 ec 04             	sub    $0x4,%esp
8010356d:	68 00 02 00 00       	push   $0x200
80103572:	52                   	push   %edx
80103573:	50                   	push   %eax
80103574:	e8 ee 20 00 00       	call   80105667 <memmove>
80103579:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010357c:	83 ec 0c             	sub    $0xc,%esp
8010357f:	ff 75 ec             	pushl  -0x14(%ebp)
80103582:	e8 8d cc ff ff       	call   80100214 <bwrite>
80103587:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010358a:	83 ec 0c             	sub    $0xc,%esp
8010358d:	ff 75 f0             	pushl  -0x10(%ebp)
80103590:	e8 cc cc ff ff       	call   80100261 <brelse>
80103595:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	ff 75 ec             	pushl  -0x14(%ebp)
8010359e:	e8 be cc ff ff       	call   80100261 <brelse>
801035a3:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035aa:	a1 68 47 11 80       	mov    0x80114768,%eax
801035af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035b2:	0f 8c 5d ff ff ff    	jl     80103515 <install_trans+0x16>
  }
}
801035b8:	90                   	nop
801035b9:	90                   	nop
801035ba:	c9                   	leave  
801035bb:	c3                   	ret    

801035bc <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035bc:	f3 0f 1e fb          	endbr32 
801035c0:	55                   	push   %ebp
801035c1:	89 e5                	mov    %esp,%ebp
801035c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035c6:	a1 54 47 11 80       	mov    0x80114754,%eax
801035cb:	89 c2                	mov    %eax,%edx
801035cd:	a1 64 47 11 80       	mov    0x80114764,%eax
801035d2:	83 ec 08             	sub    $0x8,%esp
801035d5:	52                   	push   %edx
801035d6:	50                   	push   %eax
801035d7:	e8 fb cb ff ff       	call   801001d7 <bread>
801035dc:	83 c4 10             	add    $0x10,%esp
801035df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e5:	83 c0 5c             	add    $0x5c,%eax
801035e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035ee:	8b 00                	mov    (%eax),%eax
801035f0:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
801035f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035fc:	eb 1b                	jmp    80103619 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801035fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103601:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103604:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103608:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010360b:	83 c2 10             	add    $0x10,%edx
8010360e:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103619:	a1 68 47 11 80       	mov    0x80114768,%eax
8010361e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103621:	7c db                	jl     801035fe <read_head+0x42>
  }
  brelse(buf);
80103623:	83 ec 0c             	sub    $0xc,%esp
80103626:	ff 75 f0             	pushl  -0x10(%ebp)
80103629:	e8 33 cc ff ff       	call   80100261 <brelse>
8010362e:	83 c4 10             	add    $0x10,%esp
}
80103631:	90                   	nop
80103632:	c9                   	leave  
80103633:	c3                   	ret    

80103634 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103634:	f3 0f 1e fb          	endbr32 
80103638:	55                   	push   %ebp
80103639:	89 e5                	mov    %esp,%ebp
8010363b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010363e:	a1 54 47 11 80       	mov    0x80114754,%eax
80103643:	89 c2                	mov    %eax,%edx
80103645:	a1 64 47 11 80       	mov    0x80114764,%eax
8010364a:	83 ec 08             	sub    $0x8,%esp
8010364d:	52                   	push   %edx
8010364e:	50                   	push   %eax
8010364f:	e8 83 cb ff ff       	call   801001d7 <bread>
80103654:	83 c4 10             	add    $0x10,%esp
80103657:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010365a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010365d:	83 c0 5c             	add    $0x5c,%eax
80103660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103663:	8b 15 68 47 11 80    	mov    0x80114768,%edx
80103669:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010366c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010366e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103675:	eb 1b                	jmp    80103692 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010367a:	83 c0 10             	add    $0x10,%eax
8010367d:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
80103684:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103687:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010368a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010368e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103692:	a1 68 47 11 80       	mov    0x80114768,%eax
80103697:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010369a:	7c db                	jl     80103677 <write_head+0x43>
  }
  bwrite(buf);
8010369c:	83 ec 0c             	sub    $0xc,%esp
8010369f:	ff 75 f0             	pushl  -0x10(%ebp)
801036a2:	e8 6d cb ff ff       	call   80100214 <bwrite>
801036a7:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036aa:	83 ec 0c             	sub    $0xc,%esp
801036ad:	ff 75 f0             	pushl  -0x10(%ebp)
801036b0:	e8 ac cb ff ff       	call   80100261 <brelse>
801036b5:	83 c4 10             	add    $0x10,%esp
}
801036b8:	90                   	nop
801036b9:	c9                   	leave  
801036ba:	c3                   	ret    

801036bb <recover_from_log>:

static void
recover_from_log(void)
{
801036bb:	f3 0f 1e fb          	endbr32 
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036c5:	e8 f2 fe ff ff       	call   801035bc <read_head>
  install_trans(); // if committed, copy from log to disk
801036ca:	e8 30 fe ff ff       	call   801034ff <install_trans>
  log.lh.n = 0;
801036cf:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036d6:	00 00 00 
  write_head(); // clear the log
801036d9:	e8 56 ff ff ff       	call   80103634 <write_head>
}
801036de:	90                   	nop
801036df:	c9                   	leave  
801036e0:	c3                   	ret    

801036e1 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036e1:	f3 0f 1e fb          	endbr32 
801036e5:	55                   	push   %ebp
801036e6:	89 e5                	mov    %esp,%ebp
801036e8:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801036eb:	83 ec 0c             	sub    $0xc,%esp
801036ee:	68 20 47 11 80       	push   $0x80114720
801036f3:	e8 09 1c 00 00       	call   80105301 <acquire>
801036f8:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801036fb:	a1 60 47 11 80       	mov    0x80114760,%eax
80103700:	85 c0                	test   %eax,%eax
80103702:	74 17                	je     8010371b <begin_op+0x3a>
      sleep(&log, &log.lock);
80103704:	83 ec 08             	sub    $0x8,%esp
80103707:	68 20 47 11 80       	push   $0x80114720
8010370c:	68 20 47 11 80       	push   $0x80114720
80103711:	e8 6b 17 00 00       	call   80104e81 <sleep>
80103716:	83 c4 10             	add    $0x10,%esp
80103719:	eb e0                	jmp    801036fb <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010371b:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103721:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103726:	8d 50 01             	lea    0x1(%eax),%edx
80103729:	89 d0                	mov    %edx,%eax
8010372b:	c1 e0 02             	shl    $0x2,%eax
8010372e:	01 d0                	add    %edx,%eax
80103730:	01 c0                	add    %eax,%eax
80103732:	01 c8                	add    %ecx,%eax
80103734:	83 f8 1e             	cmp    $0x1e,%eax
80103737:	7e 17                	jle    80103750 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103739:	83 ec 08             	sub    $0x8,%esp
8010373c:	68 20 47 11 80       	push   $0x80114720
80103741:	68 20 47 11 80       	push   $0x80114720
80103746:	e8 36 17 00 00       	call   80104e81 <sleep>
8010374b:	83 c4 10             	add    $0x10,%esp
8010374e:	eb ab                	jmp    801036fb <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103750:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103755:	83 c0 01             	add    $0x1,%eax
80103758:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
8010375d:	83 ec 0c             	sub    $0xc,%esp
80103760:	68 20 47 11 80       	push   $0x80114720
80103765:	e8 09 1c 00 00       	call   80105373 <release>
8010376a:	83 c4 10             	add    $0x10,%esp
      break;
8010376d:	90                   	nop
    }
  }
}
8010376e:	90                   	nop
8010376f:	c9                   	leave  
80103770:	c3                   	ret    

80103771 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103771:	f3 0f 1e fb          	endbr32 
80103775:	55                   	push   %ebp
80103776:	89 e5                	mov    %esp,%ebp
80103778:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010377b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103782:	83 ec 0c             	sub    $0xc,%esp
80103785:	68 20 47 11 80       	push   $0x80114720
8010378a:	e8 72 1b 00 00       	call   80105301 <acquire>
8010378f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103792:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103797:	83 e8 01             	sub    $0x1,%eax
8010379a:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
8010379f:	a1 60 47 11 80       	mov    0x80114760,%eax
801037a4:	85 c0                	test   %eax,%eax
801037a6:	74 0d                	je     801037b5 <end_op+0x44>
    panic("log.committing");
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	68 51 95 10 80       	push   $0x80109551
801037b0:	e8 53 ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037b5:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037ba:	85 c0                	test   %eax,%eax
801037bc:	75 13                	jne    801037d1 <end_op+0x60>
    do_commit = 1;
801037be:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037c5:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037cc:	00 00 00 
801037cf:	eb 10                	jmp    801037e1 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037d1:	83 ec 0c             	sub    $0xc,%esp
801037d4:	68 20 47 11 80       	push   $0x80114720
801037d9:	e8 95 17 00 00       	call   80104f73 <wakeup>
801037de:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801037e1:	83 ec 0c             	sub    $0xc,%esp
801037e4:	68 20 47 11 80       	push   $0x80114720
801037e9:	e8 85 1b 00 00       	call   80105373 <release>
801037ee:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801037f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037f5:	74 3f                	je     80103836 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801037f7:	e8 fa 00 00 00       	call   801038f6 <commit>
    acquire(&log.lock);
801037fc:	83 ec 0c             	sub    $0xc,%esp
801037ff:	68 20 47 11 80       	push   $0x80114720
80103804:	e8 f8 1a 00 00       	call   80105301 <acquire>
80103809:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010380c:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103813:	00 00 00 
    wakeup(&log);
80103816:	83 ec 0c             	sub    $0xc,%esp
80103819:	68 20 47 11 80       	push   $0x80114720
8010381e:	e8 50 17 00 00       	call   80104f73 <wakeup>
80103823:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103826:	83 ec 0c             	sub    $0xc,%esp
80103829:	68 20 47 11 80       	push   $0x80114720
8010382e:	e8 40 1b 00 00       	call   80105373 <release>
80103833:	83 c4 10             	add    $0x10,%esp
  }
}
80103836:	90                   	nop
80103837:	c9                   	leave  
80103838:	c3                   	ret    

80103839 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103839:	f3 0f 1e fb          	endbr32 
8010383d:	55                   	push   %ebp
8010383e:	89 e5                	mov    %esp,%ebp
80103840:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103843:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010384a:	e9 95 00 00 00       	jmp    801038e4 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010384f:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103858:	01 d0                	add    %edx,%eax
8010385a:	83 c0 01             	add    $0x1,%eax
8010385d:	89 c2                	mov    %eax,%edx
8010385f:	a1 64 47 11 80       	mov    0x80114764,%eax
80103864:	83 ec 08             	sub    $0x8,%esp
80103867:	52                   	push   %edx
80103868:	50                   	push   %eax
80103869:	e8 69 c9 ff ff       	call   801001d7 <bread>
8010386e:	83 c4 10             	add    $0x10,%esp
80103871:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103877:	83 c0 10             	add    $0x10,%eax
8010387a:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103881:	89 c2                	mov    %eax,%edx
80103883:	a1 64 47 11 80       	mov    0x80114764,%eax
80103888:	83 ec 08             	sub    $0x8,%esp
8010388b:	52                   	push   %edx
8010388c:	50                   	push   %eax
8010388d:	e8 45 c9 ff ff       	call   801001d7 <bread>
80103892:	83 c4 10             	add    $0x10,%esp
80103895:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010389b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010389e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a1:	83 c0 5c             	add    $0x5c,%eax
801038a4:	83 ec 04             	sub    $0x4,%esp
801038a7:	68 00 02 00 00       	push   $0x200
801038ac:	52                   	push   %edx
801038ad:	50                   	push   %eax
801038ae:	e8 b4 1d 00 00       	call   80105667 <memmove>
801038b3:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038b6:	83 ec 0c             	sub    $0xc,%esp
801038b9:	ff 75 f0             	pushl  -0x10(%ebp)
801038bc:	e8 53 c9 ff ff       	call   80100214 <bwrite>
801038c1:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038c4:	83 ec 0c             	sub    $0xc,%esp
801038c7:	ff 75 ec             	pushl  -0x14(%ebp)
801038ca:	e8 92 c9 ff ff       	call   80100261 <brelse>
801038cf:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038d2:	83 ec 0c             	sub    $0xc,%esp
801038d5:	ff 75 f0             	pushl  -0x10(%ebp)
801038d8:	e8 84 c9 ff ff       	call   80100261 <brelse>
801038dd:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801038e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038e4:	a1 68 47 11 80       	mov    0x80114768,%eax
801038e9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038ec:	0f 8c 5d ff ff ff    	jl     8010384f <write_log+0x16>
  }
}
801038f2:	90                   	nop
801038f3:	90                   	nop
801038f4:	c9                   	leave  
801038f5:	c3                   	ret    

801038f6 <commit>:

static void
commit()
{
801038f6:	f3 0f 1e fb          	endbr32 
801038fa:	55                   	push   %ebp
801038fb:	89 e5                	mov    %esp,%ebp
801038fd:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103900:	a1 68 47 11 80       	mov    0x80114768,%eax
80103905:	85 c0                	test   %eax,%eax
80103907:	7e 1e                	jle    80103927 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103909:	e8 2b ff ff ff       	call   80103839 <write_log>
    write_head();    // Write header to disk -- the real commit
8010390e:	e8 21 fd ff ff       	call   80103634 <write_head>
    install_trans(); // Now install writes to home locations
80103913:	e8 e7 fb ff ff       	call   801034ff <install_trans>
    log.lh.n = 0;
80103918:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010391f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103922:	e8 0d fd ff ff       	call   80103634 <write_head>
  }
}
80103927:	90                   	nop
80103928:	c9                   	leave  
80103929:	c3                   	ret    

8010392a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010392a:	f3 0f 1e fb          	endbr32 
8010392e:	55                   	push   %ebp
8010392f:	89 e5                	mov    %esp,%ebp
80103931:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103934:	a1 68 47 11 80       	mov    0x80114768,%eax
80103939:	83 f8 1d             	cmp    $0x1d,%eax
8010393c:	7f 12                	jg     80103950 <log_write+0x26>
8010393e:	a1 68 47 11 80       	mov    0x80114768,%eax
80103943:	8b 15 58 47 11 80    	mov    0x80114758,%edx
80103949:	83 ea 01             	sub    $0x1,%edx
8010394c:	39 d0                	cmp    %edx,%eax
8010394e:	7c 0d                	jl     8010395d <log_write+0x33>
    panic("too big a transaction");
80103950:	83 ec 0c             	sub    $0xc,%esp
80103953:	68 60 95 10 80       	push   $0x80109560
80103958:	e8 ab cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
8010395d:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103962:	85 c0                	test   %eax,%eax
80103964:	7f 0d                	jg     80103973 <log_write+0x49>
    panic("log_write outside of trans");
80103966:	83 ec 0c             	sub    $0xc,%esp
80103969:	68 76 95 10 80       	push   $0x80109576
8010396e:	e8 95 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
80103973:	83 ec 0c             	sub    $0xc,%esp
80103976:	68 20 47 11 80       	push   $0x80114720
8010397b:	e8 81 19 00 00       	call   80105301 <acquire>
80103980:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103983:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010398a:	eb 1d                	jmp    801039a9 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010398c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398f:	83 c0 10             	add    $0x10,%eax
80103992:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103999:	89 c2                	mov    %eax,%edx
8010399b:	8b 45 08             	mov    0x8(%ebp),%eax
8010399e:	8b 40 08             	mov    0x8(%eax),%eax
801039a1:	39 c2                	cmp    %eax,%edx
801039a3:	74 10                	je     801039b5 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a9:	a1 68 47 11 80       	mov    0x80114768,%eax
801039ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039b1:	7c d9                	jl     8010398c <log_write+0x62>
801039b3:	eb 01                	jmp    801039b6 <log_write+0x8c>
      break;
801039b5:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039b6:	8b 45 08             	mov    0x8(%ebp),%eax
801039b9:	8b 40 08             	mov    0x8(%eax),%eax
801039bc:	89 c2                	mov    %eax,%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	83 c0 10             	add    $0x10,%eax
801039c4:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039cb:	a1 68 47 11 80       	mov    0x80114768,%eax
801039d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039d3:	75 0d                	jne    801039e2 <log_write+0xb8>
    log.lh.n++;
801039d5:	a1 68 47 11 80       	mov    0x80114768,%eax
801039da:	83 c0 01             	add    $0x1,%eax
801039dd:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
801039e2:	8b 45 08             	mov    0x8(%ebp),%eax
801039e5:	8b 00                	mov    (%eax),%eax
801039e7:	83 c8 04             	or     $0x4,%eax
801039ea:	89 c2                	mov    %eax,%edx
801039ec:	8b 45 08             	mov    0x8(%ebp),%eax
801039ef:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801039f1:	83 ec 0c             	sub    $0xc,%esp
801039f4:	68 20 47 11 80       	push   $0x80114720
801039f9:	e8 75 19 00 00       	call   80105373 <release>
801039fe:	83 c4 10             	add    $0x10,%esp
}
80103a01:	90                   	nop
80103a02:	c9                   	leave  
80103a03:	c3                   	ret    

80103a04 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a04:	55                   	push   %ebp
80103a05:	89 e5                	mov    %esp,%ebp
80103a07:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a0a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a10:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a13:	f0 87 02             	lock xchg %eax,(%edx)
80103a16:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a19:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a1c:	c9                   	leave  
80103a1d:	c3                   	ret    

80103a1e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a1e:	f3 0f 1e fb          	endbr32 
80103a22:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a26:	83 e4 f0             	and    $0xfffffff0,%esp
80103a29:	ff 71 fc             	pushl  -0x4(%ecx)
80103a2c:	55                   	push   %ebp
80103a2d:	89 e5                	mov    %esp,%ebp
80103a2f:	51                   	push   %ecx
80103a30:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a33:	83 ec 08             	sub    $0x8,%esp
80103a36:	68 00 00 40 80       	push   $0x80400000
80103a3b:	68 48 8e 11 80       	push   $0x80118e48
80103a40:	e8 78 f2 ff ff       	call   80102cbd <kinit1>
80103a45:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a48:	e8 28 47 00 00       	call   80108175 <kvmalloc>
  mpinit();        // detect other processors
80103a4d:	e8 d9 03 00 00       	call   80103e2b <mpinit>
  lapicinit();     // interrupt controller
80103a52:	e8 f5 f5 ff ff       	call   8010304c <lapicinit>
  seginit();       // segment descriptors
80103a57:	e8 cc 41 00 00       	call   80107c28 <seginit>
  picinit();       // disable pic
80103a5c:	e8 35 05 00 00       	call   80103f96 <picinit>
  ioapicinit();    // another interrupt controller
80103a61:	e8 6a f1 ff ff       	call   80102bd0 <ioapicinit>
  consoleinit();   // console hardware
80103a66:	e8 76 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a6b:	e8 41 35 00 00       	call   80106fb1 <uartinit>
  pinit();         // process table
80103a70:	e8 6e 09 00 00       	call   801043e3 <pinit>
  tvinit();        // trap vectors
80103a75:	e8 e9 30 00 00       	call   80106b63 <tvinit>
  binit();         // buffer cache
80103a7a:	e8 b5 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a7f:	e8 26 d6 ff ff       	call   801010aa <fileinit>
  ideinit();       // disk 
80103a84:	e8 06 ed ff ff       	call   8010278f <ideinit>
  startothers();   // start other processors
80103a89:	e8 88 00 00 00       	call   80103b16 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a8e:	83 ec 08             	sub    $0x8,%esp
80103a91:	68 00 00 00 8e       	push   $0x8e000000
80103a96:	68 00 00 40 80       	push   $0x80400000
80103a9b:	e8 5a f2 ff ff       	call   80102cfa <kinit2>
80103aa0:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103aa3:	e8 34 0b 00 00       	call   801045dc <userinit>
  mpmain();        // finish this processor's setup
80103aa8:	e8 1e 00 00 00       	call   80103acb <mpmain>

80103aad <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103aad:	f3 0f 1e fb          	endbr32 
80103ab1:	55                   	push   %ebp
80103ab2:	89 e5                	mov    %esp,%ebp
80103ab4:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ab7:	e8 d5 46 00 00       	call   80108191 <switchkvm>
  seginit();
80103abc:	e8 67 41 00 00       	call   80107c28 <seginit>
  lapicinit();
80103ac1:	e8 86 f5 ff ff       	call   8010304c <lapicinit>
  mpmain();
80103ac6:	e8 00 00 00 00       	call   80103acb <mpmain>

80103acb <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103acb:	f3 0f 1e fb          	endbr32 
80103acf:	55                   	push   %ebp
80103ad0:	89 e5                	mov    %esp,%ebp
80103ad2:	53                   	push   %ebx
80103ad3:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103ad6:	e8 2a 09 00 00       	call   80104405 <cpuid>
80103adb:	89 c3                	mov    %eax,%ebx
80103add:	e8 23 09 00 00       	call   80104405 <cpuid>
80103ae2:	83 ec 04             	sub    $0x4,%esp
80103ae5:	53                   	push   %ebx
80103ae6:	50                   	push   %eax
80103ae7:	68 91 95 10 80       	push   $0x80109591
80103aec:	e8 27 c9 ff ff       	call   80100418 <cprintf>
80103af1:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103af4:	e8 e4 31 00 00       	call   80106cdd <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103af9:	e8 26 09 00 00       	call   80104424 <mycpu>
80103afe:	05 a0 00 00 00       	add    $0xa0,%eax
80103b03:	83 ec 08             	sub    $0x8,%esp
80103b06:	6a 01                	push   $0x1
80103b08:	50                   	push   %eax
80103b09:	e8 f6 fe ff ff       	call   80103a04 <xchg>
80103b0e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b11:	e8 67 11 00 00       	call   80104c7d <scheduler>

80103b16 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b16:	f3 0f 1e fb          	endbr32 
80103b1a:	55                   	push   %ebp
80103b1b:	89 e5                	mov    %esp,%ebp
80103b1d:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b20:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b27:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b2c:	83 ec 04             	sub    $0x4,%esp
80103b2f:	50                   	push   %eax
80103b30:	68 0c c5 10 80       	push   $0x8010c50c
80103b35:	ff 75 f0             	pushl  -0x10(%ebp)
80103b38:	e8 2a 1b 00 00       	call   80105667 <memmove>
80103b3d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b40:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b47:	eb 79                	jmp    80103bc2 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b49:	e8 d6 08 00 00       	call   80104424 <mycpu>
80103b4e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b51:	74 67                	je     80103bba <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b53:	e8 aa f2 ff ff       	call   80102e02 <kalloc>
80103b58:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5e:	83 e8 04             	sub    $0x4,%eax
80103b61:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b64:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b6a:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6f:	83 e8 08             	sub    $0x8,%eax
80103b72:	c7 00 ad 3a 10 80    	movl   $0x80103aad,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b78:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b7d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b86:	83 e8 0c             	sub    $0xc,%eax
80103b89:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b97:	0f b6 00             	movzbl (%eax),%eax
80103b9a:	0f b6 c0             	movzbl %al,%eax
80103b9d:	83 ec 08             	sub    $0x8,%esp
80103ba0:	52                   	push   %edx
80103ba1:	50                   	push   %eax
80103ba2:	e8 17 f6 ff ff       	call   801031be <lapicstartap>
80103ba7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103baa:	90                   	nop
80103bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bae:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bb4:	85 c0                	test   %eax,%eax
80103bb6:	74 f3                	je     80103bab <startothers+0x95>
80103bb8:	eb 01                	jmp    80103bbb <startothers+0xa5>
      continue;
80103bba:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bbb:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bc2:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bc7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bcd:	05 20 48 11 80       	add    $0x80114820,%eax
80103bd2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bd5:	0f 82 6e ff ff ff    	jb     80103b49 <startothers+0x33>
      ;
  }
}
80103bdb:	90                   	nop
80103bdc:	90                   	nop
80103bdd:	c9                   	leave  
80103bde:	c3                   	ret    

80103bdf <inb>:
{
80103bdf:	55                   	push   %ebp
80103be0:	89 e5                	mov    %esp,%ebp
80103be2:	83 ec 14             	sub    $0x14,%esp
80103be5:	8b 45 08             	mov    0x8(%ebp),%eax
80103be8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103bec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103bf0:	89 c2                	mov    %eax,%edx
80103bf2:	ec                   	in     (%dx),%al
80103bf3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bf6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103bfa:	c9                   	leave  
80103bfb:	c3                   	ret    

80103bfc <outb>:
{
80103bfc:	55                   	push   %ebp
80103bfd:	89 e5                	mov    %esp,%ebp
80103bff:	83 ec 08             	sub    $0x8,%esp
80103c02:	8b 45 08             	mov    0x8(%ebp),%eax
80103c05:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c08:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c0c:	89 d0                	mov    %edx,%eax
80103c0e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c11:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c15:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c19:	ee                   	out    %al,(%dx)
}
80103c1a:	90                   	nop
80103c1b:	c9                   	leave  
80103c1c:	c3                   	ret    

80103c1d <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c1d:	f3 0f 1e fb          	endbr32 
80103c21:	55                   	push   %ebp
80103c22:	89 e5                	mov    %esp,%ebp
80103c24:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c27:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c35:	eb 15                	jmp    80103c4c <sum+0x2f>
    sum += addr[i];
80103c37:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3d:	01 d0                	add    %edx,%eax
80103c3f:	0f b6 00             	movzbl (%eax),%eax
80103c42:	0f b6 c0             	movzbl %al,%eax
80103c45:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c48:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c4f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c52:	7c e3                	jl     80103c37 <sum+0x1a>
  return sum;
80103c54:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c57:	c9                   	leave  
80103c58:	c3                   	ret    

80103c59 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c59:	f3 0f 1e fb          	endbr32 
80103c5d:	55                   	push   %ebp
80103c5e:	89 e5                	mov    %esp,%ebp
80103c60:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c63:	8b 45 08             	mov    0x8(%ebp),%eax
80103c66:	05 00 00 00 80       	add    $0x80000000,%eax
80103c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c74:	01 d0                	add    %edx,%eax
80103c76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c7f:	eb 36                	jmp    80103cb7 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c81:	83 ec 04             	sub    $0x4,%esp
80103c84:	6a 04                	push   $0x4
80103c86:	68 a8 95 10 80       	push   $0x801095a8
80103c8b:	ff 75 f4             	pushl  -0xc(%ebp)
80103c8e:	e8 78 19 00 00       	call   8010560b <memcmp>
80103c93:	83 c4 10             	add    $0x10,%esp
80103c96:	85 c0                	test   %eax,%eax
80103c98:	75 19                	jne    80103cb3 <mpsearch1+0x5a>
80103c9a:	83 ec 08             	sub    $0x8,%esp
80103c9d:	6a 10                	push   $0x10
80103c9f:	ff 75 f4             	pushl  -0xc(%ebp)
80103ca2:	e8 76 ff ff ff       	call   80103c1d <sum>
80103ca7:	83 c4 10             	add    $0x10,%esp
80103caa:	84 c0                	test   %al,%al
80103cac:	75 05                	jne    80103cb3 <mpsearch1+0x5a>
      return (struct mp*)p;
80103cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb1:	eb 11                	jmp    80103cc4 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103cb3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cbd:	72 c2                	jb     80103c81 <mpsearch1+0x28>
  return 0;
80103cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cc4:	c9                   	leave  
80103cc5:	c3                   	ret    

80103cc6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cc6:	f3 0f 1e fb          	endbr32 
80103cca:	55                   	push   %ebp
80103ccb:	89 e5                	mov    %esp,%ebp
80103ccd:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cd0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cda:	83 c0 0f             	add    $0xf,%eax
80103cdd:	0f b6 00             	movzbl (%eax),%eax
80103ce0:	0f b6 c0             	movzbl %al,%eax
80103ce3:	c1 e0 08             	shl    $0x8,%eax
80103ce6:	89 c2                	mov    %eax,%edx
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	83 c0 0e             	add    $0xe,%eax
80103cee:	0f b6 00             	movzbl (%eax),%eax
80103cf1:	0f b6 c0             	movzbl %al,%eax
80103cf4:	09 d0                	or     %edx,%eax
80103cf6:	c1 e0 04             	shl    $0x4,%eax
80103cf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d00:	74 21                	je     80103d23 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d02:	83 ec 08             	sub    $0x8,%esp
80103d05:	68 00 04 00 00       	push   $0x400
80103d0a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d0d:	e8 47 ff ff ff       	call   80103c59 <mpsearch1>
80103d12:	83 c4 10             	add    $0x10,%esp
80103d15:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d1c:	74 51                	je     80103d6f <mpsearch+0xa9>
      return mp;
80103d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d21:	eb 61                	jmp    80103d84 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d26:	83 c0 14             	add    $0x14,%eax
80103d29:	0f b6 00             	movzbl (%eax),%eax
80103d2c:	0f b6 c0             	movzbl %al,%eax
80103d2f:	c1 e0 08             	shl    $0x8,%eax
80103d32:	89 c2                	mov    %eax,%edx
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	83 c0 13             	add    $0x13,%eax
80103d3a:	0f b6 00             	movzbl (%eax),%eax
80103d3d:	0f b6 c0             	movzbl %al,%eax
80103d40:	09 d0                	or     %edx,%eax
80103d42:	c1 e0 0a             	shl    $0xa,%eax
80103d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4b:	2d 00 04 00 00       	sub    $0x400,%eax
80103d50:	83 ec 08             	sub    $0x8,%esp
80103d53:	68 00 04 00 00       	push   $0x400
80103d58:	50                   	push   %eax
80103d59:	e8 fb fe ff ff       	call   80103c59 <mpsearch1>
80103d5e:	83 c4 10             	add    $0x10,%esp
80103d61:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d68:	74 05                	je     80103d6f <mpsearch+0xa9>
      return mp;
80103d6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d6d:	eb 15                	jmp    80103d84 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d6f:	83 ec 08             	sub    $0x8,%esp
80103d72:	68 00 00 01 00       	push   $0x10000
80103d77:	68 00 00 0f 00       	push   $0xf0000
80103d7c:	e8 d8 fe ff ff       	call   80103c59 <mpsearch1>
80103d81:	83 c4 10             	add    $0x10,%esp
}
80103d84:	c9                   	leave  
80103d85:	c3                   	ret    

80103d86 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d86:	f3 0f 1e fb          	endbr32 
80103d8a:	55                   	push   %ebp
80103d8b:	89 e5                	mov    %esp,%ebp
80103d8d:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d90:	e8 31 ff ff ff       	call   80103cc6 <mpsearch>
80103d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d9c:	74 0a                	je     80103da8 <mpconfig+0x22>
80103d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da1:	8b 40 04             	mov    0x4(%eax),%eax
80103da4:	85 c0                	test   %eax,%eax
80103da6:	75 07                	jne    80103daf <mpconfig+0x29>
    return 0;
80103da8:	b8 00 00 00 00       	mov    $0x0,%eax
80103dad:	eb 7a                	jmp    80103e29 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db2:	8b 40 04             	mov    0x4(%eax),%eax
80103db5:	05 00 00 00 80       	add    $0x80000000,%eax
80103dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103dbd:	83 ec 04             	sub    $0x4,%esp
80103dc0:	6a 04                	push   $0x4
80103dc2:	68 ad 95 10 80       	push   $0x801095ad
80103dc7:	ff 75 f0             	pushl  -0x10(%ebp)
80103dca:	e8 3c 18 00 00       	call   8010560b <memcmp>
80103dcf:	83 c4 10             	add    $0x10,%esp
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	74 07                	je     80103ddd <mpconfig+0x57>
    return 0;
80103dd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103ddb:	eb 4c                	jmp    80103e29 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103de4:	3c 01                	cmp    $0x1,%al
80103de6:	74 12                	je     80103dfa <mpconfig+0x74>
80103de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103deb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103def:	3c 04                	cmp    $0x4,%al
80103df1:	74 07                	je     80103dfa <mpconfig+0x74>
    return 0;
80103df3:	b8 00 00 00 00       	mov    $0x0,%eax
80103df8:	eb 2f                	jmp    80103e29 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e01:	0f b7 c0             	movzwl %ax,%eax
80103e04:	83 ec 08             	sub    $0x8,%esp
80103e07:	50                   	push   %eax
80103e08:	ff 75 f0             	pushl  -0x10(%ebp)
80103e0b:	e8 0d fe ff ff       	call   80103c1d <sum>
80103e10:	83 c4 10             	add    $0x10,%esp
80103e13:	84 c0                	test   %al,%al
80103e15:	74 07                	je     80103e1e <mpconfig+0x98>
    return 0;
80103e17:	b8 00 00 00 00       	mov    $0x0,%eax
80103e1c:	eb 0b                	jmp    80103e29 <mpconfig+0xa3>
  *pmp = mp;
80103e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e24:	89 10                	mov    %edx,(%eax)
  return conf;
80103e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e29:	c9                   	leave  
80103e2a:	c3                   	ret    

80103e2b <mpinit>:

void
mpinit(void)
{
80103e2b:	f3 0f 1e fb          	endbr32 
80103e2f:	55                   	push   %ebp
80103e30:	89 e5                	mov    %esp,%ebp
80103e32:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e35:	83 ec 0c             	sub    $0xc,%esp
80103e38:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e3b:	50                   	push   %eax
80103e3c:	e8 45 ff ff ff       	call   80103d86 <mpconfig>
80103e41:	83 c4 10             	add    $0x10,%esp
80103e44:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e4b:	75 0d                	jne    80103e5a <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	68 b2 95 10 80       	push   $0x801095b2
80103e55:	e8 ae c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e5a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e64:	8b 40 24             	mov    0x24(%eax),%eax
80103e67:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e6f:	83 c0 2c             	add    $0x2c,%eax
80103e72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e78:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e7c:	0f b7 d0             	movzwl %ax,%edx
80103e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e82:	01 d0                	add    %edx,%eax
80103e84:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e87:	e9 8c 00 00 00       	jmp    80103f18 <mpinit+0xed>
    switch(*p){
80103e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8f:	0f b6 00             	movzbl (%eax),%eax
80103e92:	0f b6 c0             	movzbl %al,%eax
80103e95:	83 f8 04             	cmp    $0x4,%eax
80103e98:	7f 76                	jg     80103f10 <mpinit+0xe5>
80103e9a:	83 f8 03             	cmp    $0x3,%eax
80103e9d:	7d 6b                	jge    80103f0a <mpinit+0xdf>
80103e9f:	83 f8 02             	cmp    $0x2,%eax
80103ea2:	74 4e                	je     80103ef2 <mpinit+0xc7>
80103ea4:	83 f8 02             	cmp    $0x2,%eax
80103ea7:	7f 67                	jg     80103f10 <mpinit+0xe5>
80103ea9:	85 c0                	test   %eax,%eax
80103eab:	74 07                	je     80103eb4 <mpinit+0x89>
80103ead:	83 f8 01             	cmp    $0x1,%eax
80103eb0:	74 58                	je     80103f0a <mpinit+0xdf>
80103eb2:	eb 5c                	jmp    80103f10 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eba:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ebf:	83 f8 07             	cmp    $0x7,%eax
80103ec2:	7f 28                	jg     80103eec <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ec4:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103eca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ecd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ed1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ed7:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103edd:	88 02                	mov    %al,(%edx)
        ncpu++;
80103edf:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103ee4:	83 c0 01             	add    $0x1,%eax
80103ee7:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103eec:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ef0:	eb 26                	jmp    80103f18 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ef8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103efb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103eff:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f04:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f08:	eb 0e                	jmp    80103f18 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f0a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f0e:	eb 08                	jmp    80103f18 <mpinit+0xed>
    default:
      ismp = 0;
80103f10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f17:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f1e:	0f 82 68 ff ff ff    	jb     80103e8c <mpinit+0x61>
    }
  }
  if(!ismp)
80103f24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f28:	75 0d                	jne    80103f37 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f2a:	83 ec 0c             	sub    $0xc,%esp
80103f2d:	68 cc 95 10 80       	push   $0x801095cc
80103f32:	e8 d1 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f37:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f3a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f3e:	84 c0                	test   %al,%al
80103f40:	74 30                	je     80103f72 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f42:	83 ec 08             	sub    $0x8,%esp
80103f45:	6a 70                	push   $0x70
80103f47:	6a 22                	push   $0x22
80103f49:	e8 ae fc ff ff       	call   80103bfc <outb>
80103f4e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f51:	83 ec 0c             	sub    $0xc,%esp
80103f54:	6a 23                	push   $0x23
80103f56:	e8 84 fc ff ff       	call   80103bdf <inb>
80103f5b:	83 c4 10             	add    $0x10,%esp
80103f5e:	83 c8 01             	or     $0x1,%eax
80103f61:	0f b6 c0             	movzbl %al,%eax
80103f64:	83 ec 08             	sub    $0x8,%esp
80103f67:	50                   	push   %eax
80103f68:	6a 23                	push   $0x23
80103f6a:	e8 8d fc ff ff       	call   80103bfc <outb>
80103f6f:	83 c4 10             	add    $0x10,%esp
  }
}
80103f72:	90                   	nop
80103f73:	c9                   	leave  
80103f74:	c3                   	ret    

80103f75 <outb>:
{
80103f75:	55                   	push   %ebp
80103f76:	89 e5                	mov    %esp,%ebp
80103f78:	83 ec 08             	sub    $0x8,%esp
80103f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f81:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f85:	89 d0                	mov    %edx,%eax
80103f87:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f8a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f8e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f92:	ee                   	out    %al,(%dx)
}
80103f93:	90                   	nop
80103f94:	c9                   	leave  
80103f95:	c3                   	ret    

80103f96 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f96:	f3 0f 1e fb          	endbr32 
80103f9a:	55                   	push   %ebp
80103f9b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f9d:	68 ff 00 00 00       	push   $0xff
80103fa2:	6a 21                	push   $0x21
80103fa4:	e8 cc ff ff ff       	call   80103f75 <outb>
80103fa9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fac:	68 ff 00 00 00       	push   $0xff
80103fb1:	68 a1 00 00 00       	push   $0xa1
80103fb6:	e8 ba ff ff ff       	call   80103f75 <outb>
80103fbb:	83 c4 08             	add    $0x8,%esp
}
80103fbe:	90                   	nop
80103fbf:	c9                   	leave  
80103fc0:	c3                   	ret    

80103fc1 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc1:	f3 0f 1e fb          	endbr32 
80103fc5:	55                   	push   %ebp
80103fc6:	89 e5                	mov    %esp,%ebp
80103fc8:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fcb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fde:	8b 10                	mov    (%eax),%edx
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe5:	e8 e2 d0 ff ff       	call   801010cc <filealloc>
80103fea:	8b 55 08             	mov    0x8(%ebp),%edx
80103fed:	89 02                	mov    %eax,(%edx)
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	8b 00                	mov    (%eax),%eax
80103ff4:	85 c0                	test   %eax,%eax
80103ff6:	0f 84 c8 00 00 00    	je     801040c4 <pipealloc+0x103>
80103ffc:	e8 cb d0 ff ff       	call   801010cc <filealloc>
80104001:	8b 55 0c             	mov    0xc(%ebp),%edx
80104004:	89 02                	mov    %eax,(%edx)
80104006:	8b 45 0c             	mov    0xc(%ebp),%eax
80104009:	8b 00                	mov    (%eax),%eax
8010400b:	85 c0                	test   %eax,%eax
8010400d:	0f 84 b1 00 00 00    	je     801040c4 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104013:	e8 ea ed ff ff       	call   80102e02 <kalloc>
80104018:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010401f:	0f 84 a2 00 00 00    	je     801040c7 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104028:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010402f:	00 00 00 
  p->writeopen = 1;
80104032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104035:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010403c:	00 00 00 
  p->nwrite = 0;
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104049:	00 00 00 
  p->nread = 0;
8010404c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104056:	00 00 00 
  initlock(&p->lock, "pipe");
80104059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405c:	83 ec 08             	sub    $0x8,%esp
8010405f:	68 eb 95 10 80       	push   $0x801095eb
80104064:	50                   	push   %eax
80104065:	e8 71 12 00 00       	call   801052db <initlock>
8010406a:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	8b 00                	mov    (%eax),%eax
8010407d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104081:	8b 45 08             	mov    0x8(%ebp),%eax
80104084:	8b 00                	mov    (%eax),%eax
80104086:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010408a:	8b 45 08             	mov    0x8(%ebp),%eax
8010408d:	8b 00                	mov    (%eax),%eax
8010408f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104092:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104095:	8b 45 0c             	mov    0xc(%ebp),%eax
80104098:	8b 00                	mov    (%eax),%eax
8010409a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a3:	8b 00                	mov    (%eax),%eax
801040a5:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ac:	8b 00                	mov    (%eax),%eax
801040ae:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ba:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040bd:	b8 00 00 00 00       	mov    $0x0,%eax
801040c2:	eb 51                	jmp    80104115 <pipealloc+0x154>
    goto bad;
801040c4:	90                   	nop
801040c5:	eb 01                	jmp    801040c8 <pipealloc+0x107>
    goto bad;
801040c7:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cc:	74 0e                	je     801040dc <pipealloc+0x11b>
    kfree((char*)p);
801040ce:	83 ec 0c             	sub    $0xc,%esp
801040d1:	ff 75 f4             	pushl  -0xc(%ebp)
801040d4:	e8 8b ec ff ff       	call   80102d64 <kfree>
801040d9:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 00                	mov    (%eax),%eax
801040e1:	85 c0                	test   %eax,%eax
801040e3:	74 11                	je     801040f6 <pipealloc+0x135>
    fileclose(*f0);
801040e5:	8b 45 08             	mov    0x8(%ebp),%eax
801040e8:	8b 00                	mov    (%eax),%eax
801040ea:	83 ec 0c             	sub    $0xc,%esp
801040ed:	50                   	push   %eax
801040ee:	e8 9f d0 ff ff       	call   80101192 <fileclose>
801040f3:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f9:	8b 00                	mov    (%eax),%eax
801040fb:	85 c0                	test   %eax,%eax
801040fd:	74 11                	je     80104110 <pipealloc+0x14f>
    fileclose(*f1);
801040ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80104102:	8b 00                	mov    (%eax),%eax
80104104:	83 ec 0c             	sub    $0xc,%esp
80104107:	50                   	push   %eax
80104108:	e8 85 d0 ff ff       	call   80101192 <fileclose>
8010410d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104115:	c9                   	leave  
80104116:	c3                   	ret    

80104117 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104117:	f3 0f 1e fb          	endbr32 
8010411b:	55                   	push   %ebp
8010411c:	89 e5                	mov    %esp,%ebp
8010411e:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	83 ec 0c             	sub    $0xc,%esp
80104127:	50                   	push   %eax
80104128:	e8 d4 11 00 00       	call   80105301 <acquire>
8010412d:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104130:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104134:	74 23                	je     80104159 <pipeclose+0x42>
    p->writeopen = 0;
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104140:	00 00 00 
    wakeup(&p->nread);
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	05 34 02 00 00       	add    $0x234,%eax
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	50                   	push   %eax
8010414f:	e8 1f 0e 00 00       	call   80104f73 <wakeup>
80104154:	83 c4 10             	add    $0x10,%esp
80104157:	eb 21                	jmp    8010417a <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104163:	00 00 00 
    wakeup(&p->nwrite);
80104166:	8b 45 08             	mov    0x8(%ebp),%eax
80104169:	05 38 02 00 00       	add    $0x238,%eax
8010416e:	83 ec 0c             	sub    $0xc,%esp
80104171:	50                   	push   %eax
80104172:	e8 fc 0d 00 00       	call   80104f73 <wakeup>
80104177:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010417a:	8b 45 08             	mov    0x8(%ebp),%eax
8010417d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104183:	85 c0                	test   %eax,%eax
80104185:	75 2c                	jne    801041b3 <pipeclose+0x9c>
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104190:	85 c0                	test   %eax,%eax
80104192:	75 1f                	jne    801041b3 <pipeclose+0x9c>
    release(&p->lock);
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	50                   	push   %eax
8010419b:	e8 d3 11 00 00       	call   80105373 <release>
801041a0:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	ff 75 08             	pushl  0x8(%ebp)
801041a9:	e8 b6 eb ff ff       	call   80102d64 <kfree>
801041ae:	83 c4 10             	add    $0x10,%esp
801041b1:	eb 10                	jmp    801041c3 <pipeclose+0xac>
  } else
    release(&p->lock);
801041b3:	8b 45 08             	mov    0x8(%ebp),%eax
801041b6:	83 ec 0c             	sub    $0xc,%esp
801041b9:	50                   	push   %eax
801041ba:	e8 b4 11 00 00       	call   80105373 <release>
801041bf:	83 c4 10             	add    $0x10,%esp
}
801041c2:	90                   	nop
801041c3:	90                   	nop
801041c4:	c9                   	leave  
801041c5:	c3                   	ret    

801041c6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041c6:	f3 0f 1e fb          	endbr32 
801041ca:	55                   	push   %ebp
801041cb:	89 e5                	mov    %esp,%ebp
801041cd:	53                   	push   %ebx
801041ce:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	83 ec 0c             	sub    $0xc,%esp
801041d7:	50                   	push   %eax
801041d8:	e8 24 11 00 00       	call   80105301 <acquire>
801041dd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041e7:	e9 ad 00 00 00       	jmp    80104299 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801041ec:	8b 45 08             	mov    0x8(%ebp),%eax
801041ef:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041f5:	85 c0                	test   %eax,%eax
801041f7:	74 0c                	je     80104205 <pipewrite+0x3f>
801041f9:	e8 a2 02 00 00       	call   801044a0 <myproc>
801041fe:	8b 40 24             	mov    0x24(%eax),%eax
80104201:	85 c0                	test   %eax,%eax
80104203:	74 19                	je     8010421e <pipewrite+0x58>
        release(&p->lock);
80104205:	8b 45 08             	mov    0x8(%ebp),%eax
80104208:	83 ec 0c             	sub    $0xc,%esp
8010420b:	50                   	push   %eax
8010420c:	e8 62 11 00 00       	call   80105373 <release>
80104211:	83 c4 10             	add    $0x10,%esp
        return -1;
80104214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104219:	e9 a9 00 00 00       	jmp    801042c7 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010421e:	8b 45 08             	mov    0x8(%ebp),%eax
80104221:	05 34 02 00 00       	add    $0x234,%eax
80104226:	83 ec 0c             	sub    $0xc,%esp
80104229:	50                   	push   %eax
8010422a:	e8 44 0d 00 00       	call   80104f73 <wakeup>
8010422f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104232:	8b 45 08             	mov    0x8(%ebp),%eax
80104235:	8b 55 08             	mov    0x8(%ebp),%edx
80104238:	81 c2 38 02 00 00    	add    $0x238,%edx
8010423e:	83 ec 08             	sub    $0x8,%esp
80104241:	50                   	push   %eax
80104242:	52                   	push   %edx
80104243:	e8 39 0c 00 00       	call   80104e81 <sleep>
80104248:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010424b:	8b 45 08             	mov    0x8(%ebp),%eax
8010424e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104254:	8b 45 08             	mov    0x8(%ebp),%eax
80104257:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010425d:	05 00 02 00 00       	add    $0x200,%eax
80104262:	39 c2                	cmp    %eax,%edx
80104264:	74 86                	je     801041ec <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104266:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104269:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010426f:	8b 45 08             	mov    0x8(%ebp),%eax
80104272:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104278:	8d 48 01             	lea    0x1(%eax),%ecx
8010427b:	8b 55 08             	mov    0x8(%ebp),%edx
8010427e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104284:	25 ff 01 00 00       	and    $0x1ff,%eax
80104289:	89 c1                	mov    %eax,%ecx
8010428b:	0f b6 13             	movzbl (%ebx),%edx
8010428e:	8b 45 08             	mov    0x8(%ebp),%eax
80104291:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104295:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010429f:	7c aa                	jl     8010424b <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	05 34 02 00 00       	add    $0x234,%eax
801042a9:	83 ec 0c             	sub    $0xc,%esp
801042ac:	50                   	push   %eax
801042ad:	e8 c1 0c 00 00       	call   80104f73 <wakeup>
801042b2:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042b5:	8b 45 08             	mov    0x8(%ebp),%eax
801042b8:	83 ec 0c             	sub    $0xc,%esp
801042bb:	50                   	push   %eax
801042bc:	e8 b2 10 00 00       	call   80105373 <release>
801042c1:	83 c4 10             	add    $0x10,%esp
  return n;
801042c4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042ca:	c9                   	leave  
801042cb:	c3                   	ret    

801042cc <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042cc:	f3 0f 1e fb          	endbr32 
801042d0:	55                   	push   %ebp
801042d1:	89 e5                	mov    %esp,%ebp
801042d3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042d6:	8b 45 08             	mov    0x8(%ebp),%eax
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	50                   	push   %eax
801042dd:	e8 1f 10 00 00       	call   80105301 <acquire>
801042e2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042e5:	eb 3e                	jmp    80104325 <piperead+0x59>
    if(myproc()->killed){
801042e7:	e8 b4 01 00 00       	call   801044a0 <myproc>
801042ec:	8b 40 24             	mov    0x24(%eax),%eax
801042ef:	85 c0                	test   %eax,%eax
801042f1:	74 19                	je     8010430c <piperead+0x40>
      release(&p->lock);
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	50                   	push   %eax
801042fa:	e8 74 10 00 00       	call   80105373 <release>
801042ff:	83 c4 10             	add    $0x10,%esp
      return -1;
80104302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104307:	e9 be 00 00 00       	jmp    801043ca <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010430c:	8b 45 08             	mov    0x8(%ebp),%eax
8010430f:	8b 55 08             	mov    0x8(%ebp),%edx
80104312:	81 c2 34 02 00 00    	add    $0x234,%edx
80104318:	83 ec 08             	sub    $0x8,%esp
8010431b:	50                   	push   %eax
8010431c:	52                   	push   %edx
8010431d:	e8 5f 0b 00 00       	call   80104e81 <sleep>
80104322:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104325:	8b 45 08             	mov    0x8(%ebp),%eax
80104328:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010432e:	8b 45 08             	mov    0x8(%ebp),%eax
80104331:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104337:	39 c2                	cmp    %eax,%edx
80104339:	75 0d                	jne    80104348 <piperead+0x7c>
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104344:	85 c0                	test   %eax,%eax
80104346:	75 9f                	jne    801042e7 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010434f:	eb 48                	jmp    80104399 <piperead+0xcd>
    if(p->nread == p->nwrite)
80104351:	8b 45 08             	mov    0x8(%ebp),%eax
80104354:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010435a:	8b 45 08             	mov    0x8(%ebp),%eax
8010435d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104363:	39 c2                	cmp    %eax,%edx
80104365:	74 3c                	je     801043a3 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104370:	8d 48 01             	lea    0x1(%eax),%ecx
80104373:	8b 55 08             	mov    0x8(%ebp),%edx
80104376:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010437c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104381:	89 c1                	mov    %eax,%ecx
80104383:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104386:	8b 45 0c             	mov    0xc(%ebp),%eax
80104389:	01 c2                	add    %eax,%edx
8010438b:	8b 45 08             	mov    0x8(%ebp),%eax
8010438e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104393:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104395:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010439f:	7c b0                	jl     80104351 <piperead+0x85>
801043a1:	eb 01                	jmp    801043a4 <piperead+0xd8>
      break;
801043a3:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043a4:	8b 45 08             	mov    0x8(%ebp),%eax
801043a7:	05 38 02 00 00       	add    $0x238,%eax
801043ac:	83 ec 0c             	sub    $0xc,%esp
801043af:	50                   	push   %eax
801043b0:	e8 be 0b 00 00       	call   80104f73 <wakeup>
801043b5:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043b8:	8b 45 08             	mov    0x8(%ebp),%eax
801043bb:	83 ec 0c             	sub    $0xc,%esp
801043be:	50                   	push   %eax
801043bf:	e8 af 0f 00 00       	call   80105373 <release>
801043c4:	83 c4 10             	add    $0x10,%esp
  return i;
801043c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043ca:	c9                   	leave  
801043cb:	c3                   	ret    

801043cc <readeflags>:
{
801043cc:	55                   	push   %ebp
801043cd:	89 e5                	mov    %esp,%ebp
801043cf:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043d2:	9c                   	pushf  
801043d3:	58                   	pop    %eax
801043d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043da:	c9                   	leave  
801043db:	c3                   	ret    

801043dc <sti>:
{
801043dc:	55                   	push   %ebp
801043dd:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043df:	fb                   	sti    
}
801043e0:	90                   	nop
801043e1:	5d                   	pop    %ebp
801043e2:	c3                   	ret    

801043e3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043e3:	f3 0f 1e fb          	endbr32 
801043e7:	55                   	push   %ebp
801043e8:	89 e5                	mov    %esp,%ebp
801043ea:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043ed:	83 ec 08             	sub    $0x8,%esp
801043f0:	68 f0 95 10 80       	push   $0x801095f0
801043f5:	68 c0 4d 11 80       	push   $0x80114dc0
801043fa:	e8 dc 0e 00 00       	call   801052db <initlock>
801043ff:	83 c4 10             	add    $0x10,%esp
}
80104402:	90                   	nop
80104403:	c9                   	leave  
80104404:	c3                   	ret    

80104405 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104405:	f3 0f 1e fb          	endbr32 
80104409:	55                   	push   %ebp
8010440a:	89 e5                	mov    %esp,%ebp
8010440c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010440f:	e8 10 00 00 00       	call   80104424 <mycpu>
80104414:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104419:	c1 f8 04             	sar    $0x4,%eax
8010441c:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104422:	c9                   	leave  
80104423:	c3                   	ret    

80104424 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104424:	f3 0f 1e fb          	endbr32 
80104428:	55                   	push   %ebp
80104429:	89 e5                	mov    %esp,%ebp
8010442b:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010442e:	e8 99 ff ff ff       	call   801043cc <readeflags>
80104433:	25 00 02 00 00       	and    $0x200,%eax
80104438:	85 c0                	test   %eax,%eax
8010443a:	74 0d                	je     80104449 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010443c:	83 ec 0c             	sub    $0xc,%esp
8010443f:	68 f8 95 10 80       	push   $0x801095f8
80104444:	e8 bf c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
80104449:	e8 21 ed ff ff       	call   8010316f <lapicid>
8010444e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104458:	eb 2d                	jmp    80104487 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
8010445a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104463:	05 20 48 11 80       	add    $0x80114820,%eax
80104468:	0f b6 00             	movzbl (%eax),%eax
8010446b:	0f b6 c0             	movzbl %al,%eax
8010446e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104471:	75 10                	jne    80104483 <mycpu+0x5f>
      return &cpus[i];
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104476:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010447c:	05 20 48 11 80       	add    $0x80114820,%eax
80104481:	eb 1b                	jmp    8010449e <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104483:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104487:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
8010448c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010448f:	7c c9                	jl     8010445a <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104491:	83 ec 0c             	sub    $0xc,%esp
80104494:	68 1e 96 10 80       	push   $0x8010961e
80104499:	e8 6a c1 ff ff       	call   80100608 <panic>
}
8010449e:	c9                   	leave  
8010449f:	c3                   	ret    

801044a0 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044a0:	f3 0f 1e fb          	endbr32 
801044a4:	55                   	push   %ebp
801044a5:	89 e5                	mov    %esp,%ebp
801044a7:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044aa:	e8 de 0f 00 00       	call   8010548d <pushcli>
  c = mycpu();
801044af:	e8 70 ff ff ff       	call   80104424 <mycpu>
801044b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044c3:	e8 16 10 00 00       	call   801054de <popcli>
  return p;
801044c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044cb:	c9                   	leave  
801044cc:	c3                   	ret    

801044cd <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044cd:	f3 0f 1e fb          	endbr32 
801044d1:	55                   	push   %ebp
801044d2:	89 e5                	mov    %esp,%ebp
801044d4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044d7:	83 ec 0c             	sub    $0xc,%esp
801044da:	68 c0 4d 11 80       	push   $0x80114dc0
801044df:	e8 1d 0e 00 00       	call   80105301 <acquire>
801044e4:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044e7:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
801044ee:	eb 11                	jmp    80104501 <allocproc+0x34>
    if(p->state == UNUSED){
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	8b 40 0c             	mov    0xc(%eax),%eax
801044f6:	85 c0                	test   %eax,%eax
801044f8:	74 2a                	je     80104524 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044fa:	81 45 f4 e0 00 00 00 	addl   $0xe0,-0xc(%ebp)
80104501:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104508:	72 e6                	jb     801044f0 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
8010450a:	83 ec 0c             	sub    $0xc,%esp
8010450d:	68 c0 4d 11 80       	push   $0x80114dc0
80104512:	e8 5c 0e 00 00       	call   80105373 <release>
80104517:	83 c4 10             	add    $0x10,%esp
  return 0;
8010451a:	b8 00 00 00 00       	mov    $0x0,%eax
8010451f:	e9 b6 00 00 00       	jmp    801045da <allocproc+0x10d>
      goto found;
80104524:	90                   	nop
80104525:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104533:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104538:	8d 50 01             	lea    0x1(%eax),%edx
8010453b:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104541:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104544:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104547:	83 ec 0c             	sub    $0xc,%esp
8010454a:	68 c0 4d 11 80       	push   $0x80114dc0
8010454f:	e8 1f 0e 00 00       	call   80105373 <release>
80104554:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104557:	e8 a6 e8 ff ff       	call   80102e02 <kalloc>
8010455c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455f:	89 42 08             	mov    %eax,0x8(%edx)
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	8b 40 08             	mov    0x8(%eax),%eax
80104568:	85 c0                	test   %eax,%eax
8010456a:	75 11                	jne    8010457d <allocproc+0xb0>
    p->state = UNUSED;
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104576:	b8 00 00 00 00       	mov    $0x0,%eax
8010457b:	eb 5d                	jmp    801045da <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	8b 40 08             	mov    0x8(%eax),%eax
80104583:	05 00 10 00 00       	add    $0x1000,%eax
80104588:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010458b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104595:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104598:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010459c:	ba 1d 6b 10 80       	mov    $0x80106b1d,%edx
801045a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045a4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045a6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b0:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b6:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b9:	83 ec 04             	sub    $0x4,%esp
801045bc:	6a 14                	push   $0x14
801045be:	6a 00                	push   $0x0
801045c0:	50                   	push   %eax
801045c1:	e8 da 0f 00 00       	call   801055a0 <memset>
801045c6:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801045cf:	ba 37 4e 10 80       	mov    $0x80104e37,%edx
801045d4:	89 50 10             	mov    %edx,0x10(%eax)
  return p;
801045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045da:	c9                   	leave  
801045db:	c3                   	ret    

801045dc <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045dc:	f3 0f 1e fb          	endbr32 
801045e0:	55                   	push   %ebp
801045e1:	89 e5                	mov    %esp,%ebp
801045e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045e6:	e8 e2 fe ff ff       	call   801044cd <allocproc>
801045eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801045ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f1:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
801045f6:	e8 dd 3a 00 00       	call   801080d8 <setupkvm>
801045fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045fe:	89 42 04             	mov    %eax,0x4(%edx)
80104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104604:	8b 40 04             	mov    0x4(%eax),%eax
80104607:	85 c0                	test   %eax,%eax
80104609:	75 0d                	jne    80104618 <userinit+0x3c>
    panic("userinit: out of memory?");
8010460b:	83 ec 0c             	sub    $0xc,%esp
8010460e:	68 2e 96 10 80       	push   $0x8010962e
80104613:	e8 f0 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104618:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010461d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104620:	8b 40 04             	mov    0x4(%eax),%eax
80104623:	83 ec 04             	sub    $0x4,%esp
80104626:	52                   	push   %edx
80104627:	68 e0 c4 10 80       	push   $0x8010c4e0
8010462c:	50                   	push   %eax
8010462d:	e8 1f 3d 00 00       	call   80108351 <inituvm>
80104632:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104638:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010463e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104641:	8b 40 18             	mov    0x18(%eax),%eax
80104644:	83 ec 04             	sub    $0x4,%esp
80104647:	6a 4c                	push   $0x4c
80104649:	6a 00                	push   $0x0
8010464b:	50                   	push   %eax
8010464c:	e8 4f 0f 00 00       	call   801055a0 <memset>
80104651:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104657:	8b 40 18             	mov    0x18(%eax),%eax
8010465a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104663:	8b 40 18             	mov    0x18(%eax),%eax
80104666:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010466c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466f:	8b 50 18             	mov    0x18(%eax),%edx
80104672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104675:	8b 40 18             	mov    0x18(%eax),%eax
80104678:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010467c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 50 18             	mov    0x18(%eax),%edx
80104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104689:	8b 40 18             	mov    0x18(%eax),%eax
8010468c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104690:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104697:	8b 40 18             	mov    0x18(%eax),%eax
8010469a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	8b 40 18             	mov    0x18(%eax),%eax
801046a7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b1:	8b 40 18             	mov    0x18(%eax),%eax
801046b4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046be:	83 c0 6c             	add    $0x6c,%eax
801046c1:	83 ec 04             	sub    $0x4,%esp
801046c4:	6a 10                	push   $0x10
801046c6:	68 47 96 10 80       	push   $0x80109647
801046cb:	50                   	push   %eax
801046cc:	e8 ea 10 00 00       	call   801057bb <safestrcpy>
801046d1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	68 50 96 10 80       	push   $0x80109650
801046dc:	e8 9c df ff ff       	call   8010267d <namei>
801046e1:	83 c4 10             	add    $0x10,%esp
801046e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046e7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801046ea:	83 ec 0c             	sub    $0xc,%esp
801046ed:	68 c0 4d 11 80       	push   $0x80114dc0
801046f2:	e8 0a 0c 00 00       	call   80105301 <acquire>
801046f7:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	68 c0 4d 11 80       	push   $0x80114dc0
8010470c:	e8 62 0c 00 00       	call   80105373 <release>
80104711:	83 c4 10             	add    $0x10,%esp
}
80104714:	90                   	nop
80104715:	c9                   	leave  
80104716:	c3                   	ret    

80104717 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104717:	f3 0f 1e fb          	endbr32 
8010471b:	55                   	push   %ebp
8010471c:	89 e5                	mov    %esp,%ebp
8010471e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104721:	e8 7a fd ff ff       	call   801044a0 <myproc>
80104726:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104729:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472c:	8b 00                	mov    (%eax),%eax
8010472e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104731:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104735:	7e 31                	jle    80104768 <growproc+0x51>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104737:	8b 55 08             	mov    0x8(%ebp),%edx
8010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473d:	01 c2                	add    %eax,%edx
8010473f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104742:	8b 40 04             	mov    0x4(%eax),%eax
80104745:	83 ec 04             	sub    $0x4,%esp
80104748:	52                   	push   %edx
80104749:	ff 75 f4             	pushl  -0xc(%ebp)
8010474c:	50                   	push   %eax
8010474d:	e8 44 3d 00 00       	call   80108496 <allocuvm>
80104752:	83 c4 10             	add    $0x10,%esp
80104755:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104758:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010475c:	75 3e                	jne    8010479c <growproc+0x85>
      return -1;
8010475e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104763:	e9 94 00 00 00       	jmp    801047fc <growproc+0xe5>
  } else if(n < 0){
80104768:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010476c:	79 2e                	jns    8010479c <growproc+0x85>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010476e:	8b 55 08             	mov    0x8(%ebp),%edx
80104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104774:	01 c2                	add    %eax,%edx
80104776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104779:	8b 40 04             	mov    0x4(%eax),%eax
8010477c:	83 ec 04             	sub    $0x4,%esp
8010477f:	52                   	push   %edx
80104780:	ff 75 f4             	pushl  -0xc(%ebp)
80104783:	50                   	push   %eax
80104784:	e8 16 3e 00 00       	call   8010859f <deallocuvm>
80104789:	83 c4 10             	add    $0x10,%esp
8010478c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010478f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104793:	75 07                	jne    8010479c <growproc+0x85>
      return -1;
80104795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010479a:	eb 60                	jmp    801047fc <growproc+0xe5>
  }
  curproc->sz = sz;
8010479c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010479f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a2:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	ff 75 f0             	pushl  -0x10(%ebp)
801047aa:	e8 ff 39 00 00       	call   801081ae <switchuvm>
801047af:	83 c4 10             	add    $0x10,%esp
  //p6 melody changes
  uint page_num=n/PGSIZE;
801047b2:	8b 45 08             	mov    0x8(%ebp),%eax
801047b5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801047bb:	85 c0                	test   %eax,%eax
801047bd:	0f 48 c2             	cmovs  %edx,%eax
801047c0:	c1 f8 0c             	sar    $0xc,%eax
801047c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  //cprintf("growproc-page_num:%d\n",page_num);
  if(mencrypt((char*)PGROUNDUP(sz-n),page_num)!=0) return -1;
801047c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c9:	8b 55 08             	mov    0x8(%ebp),%edx
801047cc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047cf:	29 d1                	sub    %edx,%ecx
801047d1:	89 ca                	mov    %ecx,%edx
801047d3:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
801047d9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801047df:	83 ec 08             	sub    $0x8,%esp
801047e2:	50                   	push   %eax
801047e3:	52                   	push   %edx
801047e4:	e8 89 46 00 00       	call   80108e72 <mencrypt>
801047e9:	83 c4 10             	add    $0x10,%esp
801047ec:	85 c0                	test   %eax,%eax
801047ee:	74 07                	je     801047f7 <growproc+0xe0>
801047f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f5:	eb 05                	jmp    801047fc <growproc+0xe5>
  //ends
  return 0;
801047f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047fc:	c9                   	leave  
801047fd:	c3                   	ret    

801047fe <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801047fe:	f3 0f 1e fb          	endbr32 
80104802:	55                   	push   %ebp
80104803:	89 e5                	mov    %esp,%ebp
80104805:	57                   	push   %edi
80104806:	56                   	push   %esi
80104807:	53                   	push   %ebx
80104808:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010480b:	e8 90 fc ff ff       	call   801044a0 <myproc>
80104810:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104813:	e8 b5 fc ff ff       	call   801044cd <allocproc>
80104818:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010481b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010481f:	75 0a                	jne    8010482b <fork+0x2d>
    return -1;
80104821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104826:	e9 fc 01 00 00       	jmp    80104a27 <fork+0x229>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010482b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010482e:	8b 10                	mov    (%eax),%edx
80104830:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104833:	8b 40 04             	mov    0x4(%eax),%eax
80104836:	83 ec 08             	sub    $0x8,%esp
80104839:	52                   	push   %edx
8010483a:	50                   	push   %eax
8010483b:	e8 19 3f 00 00       	call   80108759 <copyuvm>
80104840:	83 c4 10             	add    $0x10,%esp
80104843:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104846:	89 42 04             	mov    %eax,0x4(%edx)
80104849:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010484c:	8b 40 04             	mov    0x4(%eax),%eax
8010484f:	85 c0                	test   %eax,%eax
80104851:	75 30                	jne    80104883 <fork+0x85>
    kfree(np->kstack);
80104853:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104856:	8b 40 08             	mov    0x8(%eax),%eax
80104859:	83 ec 0c             	sub    $0xc,%esp
8010485c:	50                   	push   %eax
8010485d:	e8 02 e5 ff ff       	call   80102d64 <kfree>
80104862:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104865:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104868:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010486f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104872:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010487e:	e9 a4 01 00 00       	jmp    80104a27 <fork+0x229>
  }
  np->sz = curproc->sz;
80104883:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104886:	8b 10                	mov    (%eax),%edx
80104888:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010488b:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010488d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104890:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104893:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104896:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104899:	8b 48 18             	mov    0x18(%eax),%ecx
8010489c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010489f:	8b 40 18             	mov    0x18(%eax),%eax
801048a2:	89 c2                	mov    %eax,%edx
801048a4:	89 cb                	mov    %ecx,%ebx
801048a6:	b8 13 00 00 00       	mov    $0x13,%eax
801048ab:	89 d7                	mov    %edx,%edi
801048ad:	89 de                	mov    %ebx,%esi
801048af:	89 c1                	mov    %eax,%ecx
801048b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048b6:	8b 40 18             	mov    0x18(%eax),%eax
801048b9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048c7:	eb 3b                	jmp    80104904 <fork+0x106>
    if(curproc->ofile[i])
801048c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048cf:	83 c2 08             	add    $0x8,%edx
801048d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048d6:	85 c0                	test   %eax,%eax
801048d8:	74 26                	je     80104900 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048e0:	83 c2 08             	add    $0x8,%edx
801048e3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048e7:	83 ec 0c             	sub    $0xc,%esp
801048ea:	50                   	push   %eax
801048eb:	e8 4d c8 ff ff       	call   8010113d <filedup>
801048f0:	83 c4 10             	add    $0x10,%esp
801048f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
801048f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801048f9:	83 c1 08             	add    $0x8,%ecx
801048fc:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104900:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104904:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104908:	7e bf                	jle    801048c9 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
8010490a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490d:	8b 40 68             	mov    0x68(%eax),%eax
80104910:	83 ec 0c             	sub    $0xc,%esp
80104913:	50                   	push   %eax
80104914:	e8 bb d1 ff ff       	call   80101ad4 <idup>
80104919:	83 c4 10             	add    $0x10,%esp
8010491c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010491f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104922:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104925:	8d 50 6c             	lea    0x6c(%eax),%edx
80104928:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010492b:	83 c0 6c             	add    $0x6c,%eax
8010492e:	83 ec 04             	sub    $0x4,%esp
80104931:	6a 10                	push   $0x10
80104933:	52                   	push   %edx
80104934:	50                   	push   %eax
80104935:	e8 81 0e 00 00       	call   801057bb <safestrcpy>
8010493a:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010493d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104940:	8b 40 10             	mov    0x10(%eax),%eax
80104943:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 c0 4d 11 80       	push   $0x80114dc0
8010494e:	e8 ae 09 00 00       	call   80105301 <acquire>
80104953:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104956:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104959:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	68 c0 4d 11 80       	push   $0x80114dc0
80104968:	e8 06 0a 00 00       	call   80105373 <release>
8010496d:	83 c4 10             	add    $0x10,%esp

  //p6 melody changes
  for(int i=0;i<CLOCKSIZE;i++){
80104970:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80104977:	e9 8c 00 00 00       	jmp    80104a08 <fork+0x20a>
    np->cq[i].va=curproc->cq[i].va;
8010497c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
8010497f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104982:	89 d0                	mov    %edx,%eax
80104984:	01 c0                	add    %eax,%eax
80104986:	01 d0                	add    %edx,%eax
80104988:	c1 e0 02             	shl    $0x2,%eax
8010498b:	01 c8                	add    %ecx,%eax
8010498d:	83 e8 80             	sub    $0xffffff80,%eax
80104990:	8b 08                	mov    (%eax),%ecx
80104992:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80104995:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104998:	89 d0                	mov    %edx,%eax
8010499a:	01 c0                	add    %eax,%eax
8010499c:	01 d0                	add    %edx,%eax
8010499e:	c1 e0 02             	shl    $0x2,%eax
801049a1:	01 d8                	add    %ebx,%eax
801049a3:	83 e8 80             	sub    $0xffffff80,%eax
801049a6:	89 08                	mov    %ecx,(%eax)
    np->cq[i].pte=curproc->cq[i].pte;
801049a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801049ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
801049ae:	89 d0                	mov    %edx,%eax
801049b0:	01 c0                	add    %eax,%eax
801049b2:	01 d0                	add    %edx,%eax
801049b4:	c1 e0 02             	shl    $0x2,%eax
801049b7:	01 c8                	add    %ecx,%eax
801049b9:	05 84 00 00 00       	add    $0x84,%eax
801049be:	8b 08                	mov    (%eax),%ecx
801049c0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
801049c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801049c6:	89 d0                	mov    %edx,%eax
801049c8:	01 c0                	add    %eax,%eax
801049ca:	01 d0                	add    %edx,%eax
801049cc:	c1 e0 02             	shl    $0x2,%eax
801049cf:	01 d8                	add    %ebx,%eax
801049d1:	05 84 00 00 00       	add    $0x84,%eax
801049d6:	89 08                	mov    %ecx,(%eax)
    np->cq[i].empty=curproc->cq[i].empty;
801049d8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801049db:	8b 55 e0             	mov    -0x20(%ebp),%edx
801049de:	89 d0                	mov    %edx,%eax
801049e0:	01 c0                	add    %eax,%eax
801049e2:	01 d0                	add    %edx,%eax
801049e4:	c1 e0 02             	shl    $0x2,%eax
801049e7:	01 c8                	add    %ecx,%eax
801049e9:	83 c0 7c             	add    $0x7c,%eax
801049ec:	8b 08                	mov    (%eax),%ecx
801049ee:	8b 5d d8             	mov    -0x28(%ebp),%ebx
801049f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801049f4:	89 d0                	mov    %edx,%eax
801049f6:	01 c0                	add    %eax,%eax
801049f8:	01 d0                	add    %edx,%eax
801049fa:	c1 e0 02             	shl    $0x2,%eax
801049fd:	01 d8                	add    %ebx,%eax
801049ff:	83 c0 7c             	add    $0x7c,%eax
80104a02:	89 08                	mov    %ecx,(%eax)
  for(int i=0;i<CLOCKSIZE;i++){
80104a04:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80104a08:	83 7d e0 07          	cmpl   $0x7,-0x20(%ebp)
80104a0c:	0f 8e 6a ff ff ff    	jle    8010497c <fork+0x17e>
  }
  np->clock_hand=curproc->clock_hand;
80104a12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a15:	8b 90 dc 00 00 00    	mov    0xdc(%eax),%edx
80104a1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a1e:	89 90 dc 00 00 00    	mov    %edx,0xdc(%eax)
  //end

  return pid;
80104a24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80104a27:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a2a:	5b                   	pop    %ebx
80104a2b:	5e                   	pop    %esi
80104a2c:	5f                   	pop    %edi
80104a2d:	5d                   	pop    %ebp
80104a2e:	c3                   	ret    

80104a2f <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a2f:	f3 0f 1e fb          	endbr32 
80104a33:	55                   	push   %ebp
80104a34:	89 e5                	mov    %esp,%ebp
80104a36:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a39:	e8 62 fa ff ff       	call   801044a0 <myproc>
80104a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a41:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a46:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a49:	75 0d                	jne    80104a58 <exit+0x29>
    panic("init exiting");
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	68 52 96 10 80       	push   $0x80109652
80104a53:	e8 b0 bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a58:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a5f:	eb 3f                	jmp    80104aa0 <exit+0x71>
    if(curproc->ofile[fd]){
80104a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a64:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a67:	83 c2 08             	add    $0x8,%edx
80104a6a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a6e:	85 c0                	test   %eax,%eax
80104a70:	74 2a                	je     80104a9c <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a78:	83 c2 08             	add    $0x8,%edx
80104a7b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a7f:	83 ec 0c             	sub    $0xc,%esp
80104a82:	50                   	push   %eax
80104a83:	e8 0a c7 ff ff       	call   80101192 <fileclose>
80104a88:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a91:	83 c2 08             	add    $0x8,%edx
80104a94:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a9b:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a9c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104aa0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104aa4:	7e bb                	jle    80104a61 <exit+0x32>
    }
  }

  begin_op();
80104aa6:	e8 36 ec ff ff       	call   801036e1 <begin_op>
  iput(curproc->cwd);
80104aab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aae:	8b 40 68             	mov    0x68(%eax),%eax
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	50                   	push   %eax
80104ab5:	e8 c1 d1 ff ff       	call   80101c7b <iput>
80104aba:	83 c4 10             	add    $0x10,%esp
  end_op();
80104abd:	e8 af ec ff ff       	call   80103771 <end_op>
  curproc->cwd = 0;
80104ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac5:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104acc:	83 ec 0c             	sub    $0xc,%esp
80104acf:	68 c0 4d 11 80       	push   $0x80114dc0
80104ad4:	e8 28 08 00 00       	call   80105301 <acquire>
80104ad9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104adf:	8b 40 14             	mov    0x14(%eax),%eax
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	50                   	push   %eax
80104ae6:	e8 41 04 00 00       	call   80104f2c <wakeup1>
80104aeb:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aee:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104af5:	eb 3a                	jmp    80104b31 <exit+0x102>
    if(p->parent == curproc){
80104af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afa:	8b 40 14             	mov    0x14(%eax),%eax
80104afd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b00:	75 28                	jne    80104b2a <exit+0xfb>
      p->parent = initproc;
80104b02:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b11:	8b 40 0c             	mov    0xc(%eax),%eax
80104b14:	83 f8 05             	cmp    $0x5,%eax
80104b17:	75 11                	jne    80104b2a <exit+0xfb>
        wakeup1(initproc);
80104b19:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 05 04 00 00       	call   80104f2c <wakeup1>
80104b27:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b2a:	81 45 f4 e0 00 00 00 	addl   $0xe0,-0xc(%ebp)
80104b31:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104b38:	72 bd                	jb     80104af7 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b3d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b44:	e8 f3 01 00 00       	call   80104d3c <sched>
  panic("zombie exit");
80104b49:	83 ec 0c             	sub    $0xc,%esp
80104b4c:	68 5f 96 10 80       	push   $0x8010965f
80104b51:	e8 b2 ba ff ff       	call   80100608 <panic>

80104b56 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b56:	f3 0f 1e fb          	endbr32 
80104b5a:	55                   	push   %ebp
80104b5b:	89 e5                	mov    %esp,%ebp
80104b5d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b60:	e8 3b f9 ff ff       	call   801044a0 <myproc>
80104b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b68:	83 ec 0c             	sub    $0xc,%esp
80104b6b:	68 c0 4d 11 80       	push   $0x80114dc0
80104b70:	e8 8c 07 00 00       	call   80105301 <acquire>
80104b75:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b7f:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b86:	e9 a4 00 00 00       	jmp    80104c2f <wait+0xd9>
      if(p->parent != curproc)
80104b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8e:	8b 40 14             	mov    0x14(%eax),%eax
80104b91:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b94:	0f 85 8d 00 00 00    	jne    80104c27 <wait+0xd1>
        continue;
      havekids = 1;
80104b9a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba7:	83 f8 05             	cmp    $0x5,%eax
80104baa:	75 7c                	jne    80104c28 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baf:	8b 40 10             	mov    0x10(%eax),%eax
80104bb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb8:	8b 40 08             	mov    0x8(%eax),%eax
80104bbb:	83 ec 0c             	sub    $0xc,%esp
80104bbe:	50                   	push   %eax
80104bbf:	e8 a0 e1 ff ff       	call   80102d64 <kfree>
80104bc4:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	8b 40 04             	mov    0x4(%eax),%eax
80104bd7:	83 ec 0c             	sub    $0xc,%esp
80104bda:	50                   	push   %eax
80104bdb:	e8 97 3a 00 00       	call   80108677 <freevm>
80104be0:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c01:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c12:	83 ec 0c             	sub    $0xc,%esp
80104c15:	68 c0 4d 11 80       	push   $0x80114dc0
80104c1a:	e8 54 07 00 00       	call   80105373 <release>
80104c1f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c25:	eb 54                	jmp    80104c7b <wait+0x125>
        continue;
80104c27:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c28:	81 45 f4 e0 00 00 00 	addl   $0xe0,-0xc(%ebp)
80104c2f:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104c36:	0f 82 4f ff ff ff    	jb     80104b8b <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c40:	74 0a                	je     80104c4c <wait+0xf6>
80104c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c45:	8b 40 24             	mov    0x24(%eax),%eax
80104c48:	85 c0                	test   %eax,%eax
80104c4a:	74 17                	je     80104c63 <wait+0x10d>
      release(&ptable.lock);
80104c4c:	83 ec 0c             	sub    $0xc,%esp
80104c4f:	68 c0 4d 11 80       	push   $0x80114dc0
80104c54:	e8 1a 07 00 00       	call   80105373 <release>
80104c59:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c61:	eb 18                	jmp    80104c7b <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c63:	83 ec 08             	sub    $0x8,%esp
80104c66:	68 c0 4d 11 80       	push   $0x80114dc0
80104c6b:	ff 75 ec             	pushl  -0x14(%ebp)
80104c6e:	e8 0e 02 00 00       	call   80104e81 <sleep>
80104c73:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c76:	e9 fd fe ff ff       	jmp    80104b78 <wait+0x22>
  }
}
80104c7b:	c9                   	leave  
80104c7c:	c3                   	ret    

80104c7d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c7d:	f3 0f 1e fb          	endbr32 
80104c81:	55                   	push   %ebp
80104c82:	89 e5                	mov    %esp,%ebp
80104c84:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c87:	e8 98 f7 ff ff       	call   80104424 <mycpu>
80104c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c92:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c99:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c9c:	e8 3b f7 ff ff       	call   801043dc <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ca1:	83 ec 0c             	sub    $0xc,%esp
80104ca4:	68 c0 4d 11 80       	push   $0x80114dc0
80104ca9:	e8 53 06 00 00       	call   80105301 <acquire>
80104cae:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb1:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104cb8:	eb 64                	jmp    80104d1e <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbd:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc0:	83 f8 03             	cmp    $0x3,%eax
80104cc3:	75 51                	jne    80104d16 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ccb:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cd1:	83 ec 0c             	sub    $0xc,%esp
80104cd4:	ff 75 f4             	pushl  -0xc(%ebp)
80104cd7:	e8 d2 34 00 00       	call   801081ae <switchuvm>
80104cdc:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cef:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cf2:	83 c2 04             	add    $0x4,%edx
80104cf5:	83 ec 08             	sub    $0x8,%esp
80104cf8:	50                   	push   %eax
80104cf9:	52                   	push   %edx
80104cfa:	e8 35 0b 00 00       	call   80105834 <swtch>
80104cff:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d02:	e8 8a 34 00 00       	call   80108191 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d0a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d11:	00 00 00 
80104d14:	eb 01                	jmp    80104d17 <scheduler+0x9a>
        continue;
80104d16:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d17:	81 45 f4 e0 00 00 00 	addl   $0xe0,-0xc(%ebp)
80104d1e:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104d25:	72 93                	jb     80104cba <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d27:	83 ec 0c             	sub    $0xc,%esp
80104d2a:	68 c0 4d 11 80       	push   $0x80114dc0
80104d2f:	e8 3f 06 00 00       	call   80105373 <release>
80104d34:	83 c4 10             	add    $0x10,%esp
    sti();
80104d37:	e9 60 ff ff ff       	jmp    80104c9c <scheduler+0x1f>

80104d3c <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d3c:	f3 0f 1e fb          	endbr32 
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
80104d43:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d46:	e8 55 f7 ff ff       	call   801044a0 <myproc>
80104d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	68 c0 4d 11 80       	push   $0x80114dc0
80104d56:	e8 ed 06 00 00       	call   80105448 <holding>
80104d5b:	83 c4 10             	add    $0x10,%esp
80104d5e:	85 c0                	test   %eax,%eax
80104d60:	75 0d                	jne    80104d6f <sched+0x33>
    panic("sched ptable.lock");
80104d62:	83 ec 0c             	sub    $0xc,%esp
80104d65:	68 6b 96 10 80       	push   $0x8010966b
80104d6a:	e8 99 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d6f:	e8 b0 f6 ff ff       	call   80104424 <mycpu>
80104d74:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d7a:	83 f8 01             	cmp    $0x1,%eax
80104d7d:	74 0d                	je     80104d8c <sched+0x50>
    panic("sched locks");
80104d7f:	83 ec 0c             	sub    $0xc,%esp
80104d82:	68 7d 96 10 80       	push   $0x8010967d
80104d87:	e8 7c b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d92:	83 f8 04             	cmp    $0x4,%eax
80104d95:	75 0d                	jne    80104da4 <sched+0x68>
    panic("sched running");
80104d97:	83 ec 0c             	sub    $0xc,%esp
80104d9a:	68 89 96 10 80       	push   $0x80109689
80104d9f:	e8 64 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104da4:	e8 23 f6 ff ff       	call   801043cc <readeflags>
80104da9:	25 00 02 00 00       	and    $0x200,%eax
80104dae:	85 c0                	test   %eax,%eax
80104db0:	74 0d                	je     80104dbf <sched+0x83>
    panic("sched interruptible");
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	68 97 96 10 80       	push   $0x80109697
80104dba:	e8 49 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104dbf:	e8 60 f6 ff ff       	call   80104424 <mycpu>
80104dc4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104dcd:	e8 52 f6 ff ff       	call   80104424 <mycpu>
80104dd2:	8b 40 04             	mov    0x4(%eax),%eax
80104dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dd8:	83 c2 1c             	add    $0x1c,%edx
80104ddb:	83 ec 08             	sub    $0x8,%esp
80104dde:	50                   	push   %eax
80104ddf:	52                   	push   %edx
80104de0:	e8 4f 0a 00 00       	call   80105834 <swtch>
80104de5:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104de8:	e8 37 f6 ff ff       	call   80104424 <mycpu>
80104ded:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104df0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104df6:	90                   	nop
80104df7:	c9                   	leave  
80104df8:	c3                   	ret    

80104df9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104df9:	f3 0f 1e fb          	endbr32 
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
80104e00:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e03:	83 ec 0c             	sub    $0xc,%esp
80104e06:	68 c0 4d 11 80       	push   $0x80114dc0
80104e0b:	e8 f1 04 00 00       	call   80105301 <acquire>
80104e10:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104e13:	e8 88 f6 ff ff       	call   801044a0 <myproc>
80104e18:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e1f:	e8 18 ff ff ff       	call   80104d3c <sched>
  release(&ptable.lock);
80104e24:	83 ec 0c             	sub    $0xc,%esp
80104e27:	68 c0 4d 11 80       	push   $0x80114dc0
80104e2c:	e8 42 05 00 00       	call   80105373 <release>
80104e31:	83 c4 10             	add    $0x10,%esp
}
80104e34:	90                   	nop
80104e35:	c9                   	leave  
80104e36:	c3                   	ret    

80104e37 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e37:	f3 0f 1e fb          	endbr32 
80104e3b:	55                   	push   %ebp
80104e3c:	89 e5                	mov    %esp,%ebp
80104e3e:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e41:	83 ec 0c             	sub    $0xc,%esp
80104e44:	68 c0 4d 11 80       	push   $0x80114dc0
80104e49:	e8 25 05 00 00       	call   80105373 <release>
80104e4e:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e51:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e56:	85 c0                	test   %eax,%eax
80104e58:	74 24                	je     80104e7e <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e5a:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e61:	00 00 00 
    iinit(ROOTDEV);
80104e64:	83 ec 0c             	sub    $0xc,%esp
80104e67:	6a 01                	push   $0x1
80104e69:	e8 1e c9 ff ff       	call   8010178c <iinit>
80104e6e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e71:	83 ec 0c             	sub    $0xc,%esp
80104e74:	6a 01                	push   $0x1
80104e76:	e8 33 e6 ff ff       	call   801034ae <initlog>
80104e7b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e7e:	90                   	nop
80104e7f:	c9                   	leave  
80104e80:	c3                   	ret    

80104e81 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e81:	f3 0f 1e fb          	endbr32 
80104e85:	55                   	push   %ebp
80104e86:	89 e5                	mov    %esp,%ebp
80104e88:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e8b:	e8 10 f6 ff ff       	call   801044a0 <myproc>
80104e90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e97:	75 0d                	jne    80104ea6 <sleep+0x25>
    panic("sleep");
80104e99:	83 ec 0c             	sub    $0xc,%esp
80104e9c:	68 ab 96 10 80       	push   $0x801096ab
80104ea1:	e8 62 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104ea6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104eaa:	75 0d                	jne    80104eb9 <sleep+0x38>
    panic("sleep without lk");
80104eac:	83 ec 0c             	sub    $0xc,%esp
80104eaf:	68 b1 96 10 80       	push   $0x801096b1
80104eb4:	e8 4f b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eb9:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ec0:	74 1e                	je     80104ee0 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ec2:	83 ec 0c             	sub    $0xc,%esp
80104ec5:	68 c0 4d 11 80       	push   $0x80114dc0
80104eca:	e8 32 04 00 00       	call   80105301 <acquire>
80104ecf:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ed2:	83 ec 0c             	sub    $0xc,%esp
80104ed5:	ff 75 0c             	pushl  0xc(%ebp)
80104ed8:	e8 96 04 00 00       	call   80105373 <release>
80104edd:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee3:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee6:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eec:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ef3:	e8 44 fe ff ff       	call   80104d3c <sched>

  // Tidy up.
  p->chan = 0;
80104ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efb:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f02:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104f09:	74 1e                	je     80104f29 <sleep+0xa8>
    release(&ptable.lock);
80104f0b:	83 ec 0c             	sub    $0xc,%esp
80104f0e:	68 c0 4d 11 80       	push   $0x80114dc0
80104f13:	e8 5b 04 00 00       	call   80105373 <release>
80104f18:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f1b:	83 ec 0c             	sub    $0xc,%esp
80104f1e:	ff 75 0c             	pushl  0xc(%ebp)
80104f21:	e8 db 03 00 00       	call   80105301 <acquire>
80104f26:	83 c4 10             	add    $0x10,%esp
  }
}
80104f29:	90                   	nop
80104f2a:	c9                   	leave  
80104f2b:	c3                   	ret    

80104f2c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f2c:	f3 0f 1e fb          	endbr32 
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
80104f33:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f36:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f3d:	eb 27                	jmp    80104f66 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f42:	8b 40 0c             	mov    0xc(%eax),%eax
80104f45:	83 f8 02             	cmp    $0x2,%eax
80104f48:	75 15                	jne    80104f5f <wakeup1+0x33>
80104f4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f4d:	8b 40 20             	mov    0x20(%eax),%eax
80104f50:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f53:	75 0a                	jne    80104f5f <wakeup1+0x33>
      p->state = RUNNABLE;
80104f55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f58:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f5f:	81 45 fc e0 00 00 00 	addl   $0xe0,-0x4(%ebp)
80104f66:	81 7d fc f4 85 11 80 	cmpl   $0x801185f4,-0x4(%ebp)
80104f6d:	72 d0                	jb     80104f3f <wakeup1+0x13>
}
80104f6f:	90                   	nop
80104f70:	90                   	nop
80104f71:	c9                   	leave  
80104f72:	c3                   	ret    

80104f73 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f73:	f3 0f 1e fb          	endbr32 
80104f77:	55                   	push   %ebp
80104f78:	89 e5                	mov    %esp,%ebp
80104f7a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f7d:	83 ec 0c             	sub    $0xc,%esp
80104f80:	68 c0 4d 11 80       	push   $0x80114dc0
80104f85:	e8 77 03 00 00       	call   80105301 <acquire>
80104f8a:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f8d:	83 ec 0c             	sub    $0xc,%esp
80104f90:	ff 75 08             	pushl  0x8(%ebp)
80104f93:	e8 94 ff ff ff       	call   80104f2c <wakeup1>
80104f98:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f9b:	83 ec 0c             	sub    $0xc,%esp
80104f9e:	68 c0 4d 11 80       	push   $0x80114dc0
80104fa3:	e8 cb 03 00 00       	call   80105373 <release>
80104fa8:	83 c4 10             	add    $0x10,%esp
}
80104fab:	90                   	nop
80104fac:	c9                   	leave  
80104fad:	c3                   	ret    

80104fae <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fae:	f3 0f 1e fb          	endbr32 
80104fb2:	55                   	push   %ebp
80104fb3:	89 e5                	mov    %esp,%ebp
80104fb5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104fb8:	83 ec 0c             	sub    $0xc,%esp
80104fbb:	68 c0 4d 11 80       	push   $0x80114dc0
80104fc0:	e8 3c 03 00 00       	call   80105301 <acquire>
80104fc5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fc8:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104fcf:	eb 56                	jmp    80105027 <kill+0x79>
    if(p->pid == pid){
80104fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd4:	8b 40 10             	mov    0x10(%eax),%eax
80104fd7:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fda:	75 44                	jne    80105020 <kill+0x72>
      p->killed = 1;
80104fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      //p6 melody changes to initi cq
      cq_init(p);
80104fe6:	83 ec 0c             	sub    $0xc,%esp
80104fe9:	ff 75 f4             	pushl  -0xc(%ebp)
80104fec:	e8 81 39 00 00       	call   80108972 <cq_init>
80104ff1:	83 c4 10             	add    $0x10,%esp
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff7:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffa:	83 f8 02             	cmp    $0x2,%eax
80104ffd:	75 0a                	jne    80105009 <kill+0x5b>
        p->state = RUNNABLE;
80104fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105002:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105009:	83 ec 0c             	sub    $0xc,%esp
8010500c:	68 c0 4d 11 80       	push   $0x80114dc0
80105011:	e8 5d 03 00 00       	call   80105373 <release>
80105016:	83 c4 10             	add    $0x10,%esp
      return 0;
80105019:	b8 00 00 00 00       	mov    $0x0,%eax
8010501e:	eb 25                	jmp    80105045 <kill+0x97>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105020:	81 45 f4 e0 00 00 00 	addl   $0xe0,-0xc(%ebp)
80105027:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
8010502e:	72 a1                	jb     80104fd1 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105030:	83 ec 0c             	sub    $0xc,%esp
80105033:	68 c0 4d 11 80       	push   $0x80114dc0
80105038:	e8 36 03 00 00       	call   80105373 <release>
8010503d:	83 c4 10             	add    $0x10,%esp
  return -1;
80105040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    

80105047 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105047:	f3 0f 1e fb          	endbr32 
8010504b:	55                   	push   %ebp
8010504c:	89 e5                	mov    %esp,%ebp
8010504e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105051:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80105058:	e9 da 00 00 00       	jmp    80105137 <procdump+0xf0>
    if(p->state == UNUSED)
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	8b 40 0c             	mov    0xc(%eax),%eax
80105063:	85 c0                	test   %eax,%eax
80105065:	0f 84 c4 00 00 00    	je     8010512f <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010506b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506e:	8b 40 0c             	mov    0xc(%eax),%eax
80105071:	83 f8 05             	cmp    $0x5,%eax
80105074:	77 23                	ja     80105099 <procdump+0x52>
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	8b 40 0c             	mov    0xc(%eax),%eax
8010507c:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105083:	85 c0                	test   %eax,%eax
80105085:	74 12                	je     80105099 <procdump+0x52>
      state = states[p->state];
80105087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508a:	8b 40 0c             	mov    0xc(%eax),%eax
8010508d:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105094:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105097:	eb 07                	jmp    801050a0 <procdump+0x59>
    else
      state = "???";
80105099:	c7 45 ec c2 96 10 80 	movl   $0x801096c2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801050a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a3:	8d 50 6c             	lea    0x6c(%eax),%edx
801050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a9:	8b 40 10             	mov    0x10(%eax),%eax
801050ac:	52                   	push   %edx
801050ad:	ff 75 ec             	pushl  -0x14(%ebp)
801050b0:	50                   	push   %eax
801050b1:	68 c6 96 10 80       	push   $0x801096c6
801050b6:	e8 5d b3 ff ff       	call   80100418 <cprintf>
801050bb:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801050be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c1:	8b 40 0c             	mov    0xc(%eax),%eax
801050c4:	83 f8 02             	cmp    $0x2,%eax
801050c7:	75 54                	jne    8010511d <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801050cf:	8b 40 0c             	mov    0xc(%eax),%eax
801050d2:	83 c0 08             	add    $0x8,%eax
801050d5:	89 c2                	mov    %eax,%edx
801050d7:	83 ec 08             	sub    $0x8,%esp
801050da:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050dd:	50                   	push   %eax
801050de:	52                   	push   %edx
801050df:	e8 e5 02 00 00       	call   801053c9 <getcallerpcs>
801050e4:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050ee:	eb 1c                	jmp    8010510c <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050f7:	83 ec 08             	sub    $0x8,%esp
801050fa:	50                   	push   %eax
801050fb:	68 cf 96 10 80       	push   $0x801096cf
80105100:	e8 13 b3 ff ff       	call   80100418 <cprintf>
80105105:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105108:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010510c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105110:	7f 0b                	jg     8010511d <procdump+0xd6>
80105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105115:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105119:	85 c0                	test   %eax,%eax
8010511b:	75 d3                	jne    801050f0 <procdump+0xa9>
    }
    cprintf("\n");
8010511d:	83 ec 0c             	sub    $0xc,%esp
80105120:	68 d3 96 10 80       	push   $0x801096d3
80105125:	e8 ee b2 ff ff       	call   80100418 <cprintf>
8010512a:	83 c4 10             	add    $0x10,%esp
8010512d:	eb 01                	jmp    80105130 <procdump+0xe9>
      continue;
8010512f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105130:	81 45 f0 e0 00 00 00 	addl   $0xe0,-0x10(%ebp)
80105137:	81 7d f0 f4 85 11 80 	cmpl   $0x801185f4,-0x10(%ebp)
8010513e:	0f 82 19 ff ff ff    	jb     8010505d <procdump+0x16>
  }
}
80105144:	90                   	nop
80105145:	90                   	nop
80105146:	c9                   	leave  
80105147:	c3                   	ret    

80105148 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105148:	f3 0f 1e fb          	endbr32 
8010514c:	55                   	push   %ebp
8010514d:	89 e5                	mov    %esp,%ebp
8010514f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	83 c0 04             	add    $0x4,%eax
80105158:	83 ec 08             	sub    $0x8,%esp
8010515b:	68 ff 96 10 80       	push   $0x801096ff
80105160:	50                   	push   %eax
80105161:	e8 75 01 00 00       	call   801052db <initlock>
80105166:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010516f:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010517b:	8b 45 08             	mov    0x8(%ebp),%eax
8010517e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105185:	90                   	nop
80105186:	c9                   	leave  
80105187:	c3                   	ret    

80105188 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105188:	f3 0f 1e fb          	endbr32 
8010518c:	55                   	push   %ebp
8010518d:	89 e5                	mov    %esp,%ebp
8010518f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
80105195:	83 c0 04             	add    $0x4,%eax
80105198:	83 ec 0c             	sub    $0xc,%esp
8010519b:	50                   	push   %eax
8010519c:	e8 60 01 00 00       	call   80105301 <acquire>
801051a1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051a4:	eb 15                	jmp    801051bb <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801051a6:	8b 45 08             	mov    0x8(%ebp),%eax
801051a9:	83 c0 04             	add    $0x4,%eax
801051ac:	83 ec 08             	sub    $0x8,%esp
801051af:	50                   	push   %eax
801051b0:	ff 75 08             	pushl  0x8(%ebp)
801051b3:	e8 c9 fc ff ff       	call   80104e81 <sleep>
801051b8:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051bb:	8b 45 08             	mov    0x8(%ebp),%eax
801051be:	8b 00                	mov    (%eax),%eax
801051c0:	85 c0                	test   %eax,%eax
801051c2:	75 e2                	jne    801051a6 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801051c4:	8b 45 08             	mov    0x8(%ebp),%eax
801051c7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051cd:	e8 ce f2 ff ff       	call   801044a0 <myproc>
801051d2:	8b 50 10             	mov    0x10(%eax),%edx
801051d5:	8b 45 08             	mov    0x8(%ebp),%eax
801051d8:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	83 c0 04             	add    $0x4,%eax
801051e1:	83 ec 0c             	sub    $0xc,%esp
801051e4:	50                   	push   %eax
801051e5:	e8 89 01 00 00       	call   80105373 <release>
801051ea:	83 c4 10             	add    $0x10,%esp
}
801051ed:	90                   	nop
801051ee:	c9                   	leave  
801051ef:	c3                   	ret    

801051f0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051f0:	f3 0f 1e fb          	endbr32 
801051f4:	55                   	push   %ebp
801051f5:	89 e5                	mov    %esp,%ebp
801051f7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051fa:	8b 45 08             	mov    0x8(%ebp),%eax
801051fd:	83 c0 04             	add    $0x4,%eax
80105200:	83 ec 0c             	sub    $0xc,%esp
80105203:	50                   	push   %eax
80105204:	e8 f8 00 00 00       	call   80105301 <acquire>
80105209:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010521f:	83 ec 0c             	sub    $0xc,%esp
80105222:	ff 75 08             	pushl  0x8(%ebp)
80105225:	e8 49 fd ff ff       	call   80104f73 <wakeup>
8010522a:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	83 c0 04             	add    $0x4,%eax
80105233:	83 ec 0c             	sub    $0xc,%esp
80105236:	50                   	push   %eax
80105237:	e8 37 01 00 00       	call   80105373 <release>
8010523c:	83 c4 10             	add    $0x10,%esp
}
8010523f:	90                   	nop
80105240:	c9                   	leave  
80105241:	c3                   	ret    

80105242 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105242:	f3 0f 1e fb          	endbr32 
80105246:	55                   	push   %ebp
80105247:	89 e5                	mov    %esp,%ebp
80105249:	53                   	push   %ebx
8010524a:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
8010524d:	8b 45 08             	mov    0x8(%ebp),%eax
80105250:	83 c0 04             	add    $0x4,%eax
80105253:	83 ec 0c             	sub    $0xc,%esp
80105256:	50                   	push   %eax
80105257:	e8 a5 00 00 00       	call   80105301 <acquire>
8010525c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
8010525f:	8b 45 08             	mov    0x8(%ebp),%eax
80105262:	8b 00                	mov    (%eax),%eax
80105264:	85 c0                	test   %eax,%eax
80105266:	74 19                	je     80105281 <holdingsleep+0x3f>
80105268:	8b 45 08             	mov    0x8(%ebp),%eax
8010526b:	8b 58 3c             	mov    0x3c(%eax),%ebx
8010526e:	e8 2d f2 ff ff       	call   801044a0 <myproc>
80105273:	8b 40 10             	mov    0x10(%eax),%eax
80105276:	39 c3                	cmp    %eax,%ebx
80105278:	75 07                	jne    80105281 <holdingsleep+0x3f>
8010527a:	b8 01 00 00 00       	mov    $0x1,%eax
8010527f:	eb 05                	jmp    80105286 <holdingsleep+0x44>
80105281:	b8 00 00 00 00       	mov    $0x0,%eax
80105286:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105289:	8b 45 08             	mov    0x8(%ebp),%eax
8010528c:	83 c0 04             	add    $0x4,%eax
8010528f:	83 ec 0c             	sub    $0xc,%esp
80105292:	50                   	push   %eax
80105293:	e8 db 00 00 00       	call   80105373 <release>
80105298:	83 c4 10             	add    $0x10,%esp
  return r;
8010529b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010529e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052a1:	c9                   	leave  
801052a2:	c3                   	ret    

801052a3 <readeflags>:
{
801052a3:	55                   	push   %ebp
801052a4:	89 e5                	mov    %esp,%ebp
801052a6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052a9:	9c                   	pushf  
801052aa:	58                   	pop    %eax
801052ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052b1:	c9                   	leave  
801052b2:	c3                   	ret    

801052b3 <cli>:
{
801052b3:	55                   	push   %ebp
801052b4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052b6:	fa                   	cli    
}
801052b7:	90                   	nop
801052b8:	5d                   	pop    %ebp
801052b9:	c3                   	ret    

801052ba <sti>:
{
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052bd:	fb                   	sti    
}
801052be:	90                   	nop
801052bf:	5d                   	pop    %ebp
801052c0:	c3                   	ret    

801052c1 <xchg>:
{
801052c1:	55                   	push   %ebp
801052c2:	89 e5                	mov    %esp,%ebp
801052c4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052c7:	8b 55 08             	mov    0x8(%ebp),%edx
801052ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052d0:	f0 87 02             	lock xchg %eax,(%edx)
801052d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052d9:	c9                   	leave  
801052da:	c3                   	ret    

801052db <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052db:	f3 0f 1e fb          	endbr32 
801052df:	55                   	push   %ebp
801052e0:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801052e8:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052eb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052f4:	8b 45 08             	mov    0x8(%ebp),%eax
801052f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052fe:	90                   	nop
801052ff:	5d                   	pop    %ebp
80105300:	c3                   	ret    

80105301 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105301:	f3 0f 1e fb          	endbr32 
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	53                   	push   %ebx
80105309:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010530c:	e8 7c 01 00 00       	call   8010548d <pushcli>
  if(holding(lk))
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
80105314:	83 ec 0c             	sub    $0xc,%esp
80105317:	50                   	push   %eax
80105318:	e8 2b 01 00 00       	call   80105448 <holding>
8010531d:	83 c4 10             	add    $0x10,%esp
80105320:	85 c0                	test   %eax,%eax
80105322:	74 0d                	je     80105331 <acquire+0x30>
    panic("acquire");
80105324:	83 ec 0c             	sub    $0xc,%esp
80105327:	68 0a 97 10 80       	push   $0x8010970a
8010532c:	e8 d7 b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105331:	90                   	nop
80105332:	8b 45 08             	mov    0x8(%ebp),%eax
80105335:	83 ec 08             	sub    $0x8,%esp
80105338:	6a 01                	push   $0x1
8010533a:	50                   	push   %eax
8010533b:	e8 81 ff ff ff       	call   801052c1 <xchg>
80105340:	83 c4 10             	add    $0x10,%esp
80105343:	85 c0                	test   %eax,%eax
80105345:	75 eb                	jne    80105332 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105347:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010534c:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010534f:	e8 d0 f0 ff ff       	call   80104424 <mycpu>
80105354:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105357:	8b 45 08             	mov    0x8(%ebp),%eax
8010535a:	83 c0 0c             	add    $0xc,%eax
8010535d:	83 ec 08             	sub    $0x8,%esp
80105360:	50                   	push   %eax
80105361:	8d 45 08             	lea    0x8(%ebp),%eax
80105364:	50                   	push   %eax
80105365:	e8 5f 00 00 00       	call   801053c9 <getcallerpcs>
8010536a:	83 c4 10             	add    $0x10,%esp
}
8010536d:	90                   	nop
8010536e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105371:	c9                   	leave  
80105372:	c3                   	ret    

80105373 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105373:	f3 0f 1e fb          	endbr32 
80105377:	55                   	push   %ebp
80105378:	89 e5                	mov    %esp,%ebp
8010537a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010537d:	83 ec 0c             	sub    $0xc,%esp
80105380:	ff 75 08             	pushl  0x8(%ebp)
80105383:	e8 c0 00 00 00       	call   80105448 <holding>
80105388:	83 c4 10             	add    $0x10,%esp
8010538b:	85 c0                	test   %eax,%eax
8010538d:	75 0d                	jne    8010539c <release+0x29>
    panic("release");
8010538f:	83 ec 0c             	sub    $0xc,%esp
80105392:	68 12 97 10 80       	push   $0x80109712
80105397:	e8 6c b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053a6:	8b 45 08             	mov    0x8(%ebp),%eax
801053a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053b0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801053b5:	8b 45 08             	mov    0x8(%ebp),%eax
801053b8:	8b 55 08             	mov    0x8(%ebp),%edx
801053bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053c1:	e8 18 01 00 00       	call   801054de <popcli>
}
801053c6:	90                   	nop
801053c7:	c9                   	leave  
801053c8:	c3                   	ret    

801053c9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053c9:	f3 0f 1e fb          	endbr32 
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
801053d0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053d3:	8b 45 08             	mov    0x8(%ebp),%eax
801053d6:	83 e8 08             	sub    $0x8,%eax
801053d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053dc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053e3:	eb 38                	jmp    8010541d <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053e5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053e9:	74 53                	je     8010543e <getcallerpcs+0x75>
801053eb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053f2:	76 4a                	jbe    8010543e <getcallerpcs+0x75>
801053f4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053f8:	74 44                	je     8010543e <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105404:	8b 45 0c             	mov    0xc(%ebp),%eax
80105407:	01 c2                	add    %eax,%edx
80105409:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010540c:	8b 40 04             	mov    0x4(%eax),%eax
8010540f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105414:	8b 00                	mov    (%eax),%eax
80105416:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105419:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010541d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105421:	7e c2                	jle    801053e5 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105423:	eb 19                	jmp    8010543e <getcallerpcs+0x75>
    pcs[i] = 0;
80105425:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105428:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010542f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105432:	01 d0                	add    %edx,%eax
80105434:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010543a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010543e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105442:	7e e1                	jle    80105425 <getcallerpcs+0x5c>
}
80105444:	90                   	nop
80105445:	90                   	nop
80105446:	c9                   	leave  
80105447:	c3                   	ret    

80105448 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105448:	f3 0f 1e fb          	endbr32 
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	53                   	push   %ebx
80105450:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105453:	e8 35 00 00 00       	call   8010548d <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105458:	8b 45 08             	mov    0x8(%ebp),%eax
8010545b:	8b 00                	mov    (%eax),%eax
8010545d:	85 c0                	test   %eax,%eax
8010545f:	74 16                	je     80105477 <holding+0x2f>
80105461:	8b 45 08             	mov    0x8(%ebp),%eax
80105464:	8b 58 08             	mov    0x8(%eax),%ebx
80105467:	e8 b8 ef ff ff       	call   80104424 <mycpu>
8010546c:	39 c3                	cmp    %eax,%ebx
8010546e:	75 07                	jne    80105477 <holding+0x2f>
80105470:	b8 01 00 00 00       	mov    $0x1,%eax
80105475:	eb 05                	jmp    8010547c <holding+0x34>
80105477:	b8 00 00 00 00       	mov    $0x0,%eax
8010547c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010547f:	e8 5a 00 00 00       	call   801054de <popcli>
  return r;
80105484:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105487:	83 c4 14             	add    $0x14,%esp
8010548a:	5b                   	pop    %ebx
8010548b:	5d                   	pop    %ebp
8010548c:	c3                   	ret    

8010548d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010548d:	f3 0f 1e fb          	endbr32 
80105491:	55                   	push   %ebp
80105492:	89 e5                	mov    %esp,%ebp
80105494:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105497:	e8 07 fe ff ff       	call   801052a3 <readeflags>
8010549c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010549f:	e8 0f fe ff ff       	call   801052b3 <cli>
  if(mycpu()->ncli == 0)
801054a4:	e8 7b ef ff ff       	call   80104424 <mycpu>
801054a9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054af:	85 c0                	test   %eax,%eax
801054b1:	75 14                	jne    801054c7 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801054b3:	e8 6c ef ff ff       	call   80104424 <mycpu>
801054b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054bb:	81 e2 00 02 00 00    	and    $0x200,%edx
801054c1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054c7:	e8 58 ef ff ff       	call   80104424 <mycpu>
801054cc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054d2:	83 c2 01             	add    $0x1,%edx
801054d5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054db:	90                   	nop
801054dc:	c9                   	leave  
801054dd:	c3                   	ret    

801054de <popcli>:

void
popcli(void)
{
801054de:	f3 0f 1e fb          	endbr32 
801054e2:	55                   	push   %ebp
801054e3:	89 e5                	mov    %esp,%ebp
801054e5:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054e8:	e8 b6 fd ff ff       	call   801052a3 <readeflags>
801054ed:	25 00 02 00 00       	and    $0x200,%eax
801054f2:	85 c0                	test   %eax,%eax
801054f4:	74 0d                	je     80105503 <popcli+0x25>
    panic("popcli - interruptible");
801054f6:	83 ec 0c             	sub    $0xc,%esp
801054f9:	68 1a 97 10 80       	push   $0x8010971a
801054fe:	e8 05 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
80105503:	e8 1c ef ff ff       	call   80104424 <mycpu>
80105508:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010550e:	83 ea 01             	sub    $0x1,%edx
80105511:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105517:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010551d:	85 c0                	test   %eax,%eax
8010551f:	79 0d                	jns    8010552e <popcli+0x50>
    panic("popcli");
80105521:	83 ec 0c             	sub    $0xc,%esp
80105524:	68 31 97 10 80       	push   $0x80109731
80105529:	e8 da b0 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010552e:	e8 f1 ee ff ff       	call   80104424 <mycpu>
80105533:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105539:	85 c0                	test   %eax,%eax
8010553b:	75 14                	jne    80105551 <popcli+0x73>
8010553d:	e8 e2 ee ff ff       	call   80104424 <mycpu>
80105542:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105548:	85 c0                	test   %eax,%eax
8010554a:	74 05                	je     80105551 <popcli+0x73>
    sti();
8010554c:	e8 69 fd ff ff       	call   801052ba <sti>
}
80105551:	90                   	nop
80105552:	c9                   	leave  
80105553:	c3                   	ret    

80105554 <stosb>:
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	57                   	push   %edi
80105558:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105559:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010555c:	8b 55 10             	mov    0x10(%ebp),%edx
8010555f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105562:	89 cb                	mov    %ecx,%ebx
80105564:	89 df                	mov    %ebx,%edi
80105566:	89 d1                	mov    %edx,%ecx
80105568:	fc                   	cld    
80105569:	f3 aa                	rep stos %al,%es:(%edi)
8010556b:	89 ca                	mov    %ecx,%edx
8010556d:	89 fb                	mov    %edi,%ebx
8010556f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105572:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105575:	90                   	nop
80105576:	5b                   	pop    %ebx
80105577:	5f                   	pop    %edi
80105578:	5d                   	pop    %ebp
80105579:	c3                   	ret    

8010557a <stosl>:
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	57                   	push   %edi
8010557e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010557f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105582:	8b 55 10             	mov    0x10(%ebp),%edx
80105585:	8b 45 0c             	mov    0xc(%ebp),%eax
80105588:	89 cb                	mov    %ecx,%ebx
8010558a:	89 df                	mov    %ebx,%edi
8010558c:	89 d1                	mov    %edx,%ecx
8010558e:	fc                   	cld    
8010558f:	f3 ab                	rep stos %eax,%es:(%edi)
80105591:	89 ca                	mov    %ecx,%edx
80105593:	89 fb                	mov    %edi,%ebx
80105595:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105598:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010559b:	90                   	nop
8010559c:	5b                   	pop    %ebx
8010559d:	5f                   	pop    %edi
8010559e:	5d                   	pop    %ebp
8010559f:	c3                   	ret    

801055a0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055a0:	f3 0f 1e fb          	endbr32 
801055a4:	55                   	push   %ebp
801055a5:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801055a7:	8b 45 08             	mov    0x8(%ebp),%eax
801055aa:	83 e0 03             	and    $0x3,%eax
801055ad:	85 c0                	test   %eax,%eax
801055af:	75 43                	jne    801055f4 <memset+0x54>
801055b1:	8b 45 10             	mov    0x10(%ebp),%eax
801055b4:	83 e0 03             	and    $0x3,%eax
801055b7:	85 c0                	test   %eax,%eax
801055b9:	75 39                	jne    801055f4 <memset+0x54>
    c &= 0xFF;
801055bb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055c2:	8b 45 10             	mov    0x10(%ebp),%eax
801055c5:	c1 e8 02             	shr    $0x2,%eax
801055c8:	89 c1                	mov    %eax,%ecx
801055ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cd:	c1 e0 18             	shl    $0x18,%eax
801055d0:	89 c2                	mov    %eax,%edx
801055d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d5:	c1 e0 10             	shl    $0x10,%eax
801055d8:	09 c2                	or     %eax,%edx
801055da:	8b 45 0c             	mov    0xc(%ebp),%eax
801055dd:	c1 e0 08             	shl    $0x8,%eax
801055e0:	09 d0                	or     %edx,%eax
801055e2:	0b 45 0c             	or     0xc(%ebp),%eax
801055e5:	51                   	push   %ecx
801055e6:	50                   	push   %eax
801055e7:	ff 75 08             	pushl  0x8(%ebp)
801055ea:	e8 8b ff ff ff       	call   8010557a <stosl>
801055ef:	83 c4 0c             	add    $0xc,%esp
801055f2:	eb 12                	jmp    80105606 <memset+0x66>
  } else
    stosb(dst, c, n);
801055f4:	8b 45 10             	mov    0x10(%ebp),%eax
801055f7:	50                   	push   %eax
801055f8:	ff 75 0c             	pushl  0xc(%ebp)
801055fb:	ff 75 08             	pushl  0x8(%ebp)
801055fe:	e8 51 ff ff ff       	call   80105554 <stosb>
80105603:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105609:	c9                   	leave  
8010560a:	c3                   	ret    

8010560b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010560b:	f3 0f 1e fb          	endbr32 
8010560f:	55                   	push   %ebp
80105610:	89 e5                	mov    %esp,%ebp
80105612:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105615:	8b 45 08             	mov    0x8(%ebp),%eax
80105618:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010561b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105621:	eb 30                	jmp    80105653 <memcmp+0x48>
    if(*s1 != *s2)
80105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105626:	0f b6 10             	movzbl (%eax),%edx
80105629:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010562c:	0f b6 00             	movzbl (%eax),%eax
8010562f:	38 c2                	cmp    %al,%dl
80105631:	74 18                	je     8010564b <memcmp+0x40>
      return *s1 - *s2;
80105633:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105636:	0f b6 00             	movzbl (%eax),%eax
80105639:	0f b6 d0             	movzbl %al,%edx
8010563c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010563f:	0f b6 00             	movzbl (%eax),%eax
80105642:	0f b6 c0             	movzbl %al,%eax
80105645:	29 c2                	sub    %eax,%edx
80105647:	89 d0                	mov    %edx,%eax
80105649:	eb 1a                	jmp    80105665 <memcmp+0x5a>
    s1++, s2++;
8010564b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010564f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105653:	8b 45 10             	mov    0x10(%ebp),%eax
80105656:	8d 50 ff             	lea    -0x1(%eax),%edx
80105659:	89 55 10             	mov    %edx,0x10(%ebp)
8010565c:	85 c0                	test   %eax,%eax
8010565e:	75 c3                	jne    80105623 <memcmp+0x18>
  }

  return 0;
80105660:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105665:	c9                   	leave  
80105666:	c3                   	ret    

80105667 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105667:	f3 0f 1e fb          	endbr32 
8010566b:	55                   	push   %ebp
8010566c:	89 e5                	mov    %esp,%ebp
8010566e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105671:	8b 45 0c             	mov    0xc(%ebp),%eax
80105674:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105677:	8b 45 08             	mov    0x8(%ebp),%eax
8010567a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010567d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105680:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105683:	73 54                	jae    801056d9 <memmove+0x72>
80105685:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105688:	8b 45 10             	mov    0x10(%ebp),%eax
8010568b:	01 d0                	add    %edx,%eax
8010568d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105690:	73 47                	jae    801056d9 <memmove+0x72>
    s += n;
80105692:	8b 45 10             	mov    0x10(%ebp),%eax
80105695:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105698:	8b 45 10             	mov    0x10(%ebp),%eax
8010569b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010569e:	eb 13                	jmp    801056b3 <memmove+0x4c>
      *--d = *--s;
801056a0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056a4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ab:	0f b6 10             	movzbl (%eax),%edx
801056ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056b1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056b3:	8b 45 10             	mov    0x10(%ebp),%eax
801056b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b9:	89 55 10             	mov    %edx,0x10(%ebp)
801056bc:	85 c0                	test   %eax,%eax
801056be:	75 e0                	jne    801056a0 <memmove+0x39>
  if(s < d && s + n > d){
801056c0:	eb 24                	jmp    801056e6 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056c5:	8d 42 01             	lea    0x1(%edx),%eax
801056c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056ce:	8d 48 01             	lea    0x1(%eax),%ecx
801056d1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056d4:	0f b6 12             	movzbl (%edx),%edx
801056d7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056d9:	8b 45 10             	mov    0x10(%ebp),%eax
801056dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801056df:	89 55 10             	mov    %edx,0x10(%ebp)
801056e2:	85 c0                	test   %eax,%eax
801056e4:	75 dc                	jne    801056c2 <memmove+0x5b>

  return dst;
801056e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056e9:	c9                   	leave  
801056ea:	c3                   	ret    

801056eb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056eb:	f3 0f 1e fb          	endbr32 
801056ef:	55                   	push   %ebp
801056f0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056f2:	ff 75 10             	pushl  0x10(%ebp)
801056f5:	ff 75 0c             	pushl  0xc(%ebp)
801056f8:	ff 75 08             	pushl  0x8(%ebp)
801056fb:	e8 67 ff ff ff       	call   80105667 <memmove>
80105700:	83 c4 0c             	add    $0xc,%esp
}
80105703:	c9                   	leave  
80105704:	c3                   	ret    

80105705 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105705:	f3 0f 1e fb          	endbr32 
80105709:	55                   	push   %ebp
8010570a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010570c:	eb 0c                	jmp    8010571a <strncmp+0x15>
    n--, p++, q++;
8010570e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105712:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105716:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010571a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010571e:	74 1a                	je     8010573a <strncmp+0x35>
80105720:	8b 45 08             	mov    0x8(%ebp),%eax
80105723:	0f b6 00             	movzbl (%eax),%eax
80105726:	84 c0                	test   %al,%al
80105728:	74 10                	je     8010573a <strncmp+0x35>
8010572a:	8b 45 08             	mov    0x8(%ebp),%eax
8010572d:	0f b6 10             	movzbl (%eax),%edx
80105730:	8b 45 0c             	mov    0xc(%ebp),%eax
80105733:	0f b6 00             	movzbl (%eax),%eax
80105736:	38 c2                	cmp    %al,%dl
80105738:	74 d4                	je     8010570e <strncmp+0x9>
  if(n == 0)
8010573a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010573e:	75 07                	jne    80105747 <strncmp+0x42>
    return 0;
80105740:	b8 00 00 00 00       	mov    $0x0,%eax
80105745:	eb 16                	jmp    8010575d <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105747:	8b 45 08             	mov    0x8(%ebp),%eax
8010574a:	0f b6 00             	movzbl (%eax),%eax
8010574d:	0f b6 d0             	movzbl %al,%edx
80105750:	8b 45 0c             	mov    0xc(%ebp),%eax
80105753:	0f b6 00             	movzbl (%eax),%eax
80105756:	0f b6 c0             	movzbl %al,%eax
80105759:	29 c2                	sub    %eax,%edx
8010575b:	89 d0                	mov    %edx,%eax
}
8010575d:	5d                   	pop    %ebp
8010575e:	c3                   	ret    

8010575f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010575f:	f3 0f 1e fb          	endbr32 
80105763:	55                   	push   %ebp
80105764:	89 e5                	mov    %esp,%ebp
80105766:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105769:	8b 45 08             	mov    0x8(%ebp),%eax
8010576c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010576f:	90                   	nop
80105770:	8b 45 10             	mov    0x10(%ebp),%eax
80105773:	8d 50 ff             	lea    -0x1(%eax),%edx
80105776:	89 55 10             	mov    %edx,0x10(%ebp)
80105779:	85 c0                	test   %eax,%eax
8010577b:	7e 2c                	jle    801057a9 <strncpy+0x4a>
8010577d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105780:	8d 42 01             	lea    0x1(%edx),%eax
80105783:	89 45 0c             	mov    %eax,0xc(%ebp)
80105786:	8b 45 08             	mov    0x8(%ebp),%eax
80105789:	8d 48 01             	lea    0x1(%eax),%ecx
8010578c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010578f:	0f b6 12             	movzbl (%edx),%edx
80105792:	88 10                	mov    %dl,(%eax)
80105794:	0f b6 00             	movzbl (%eax),%eax
80105797:	84 c0                	test   %al,%al
80105799:	75 d5                	jne    80105770 <strncpy+0x11>
    ;
  while(n-- > 0)
8010579b:	eb 0c                	jmp    801057a9 <strncpy+0x4a>
    *s++ = 0;
8010579d:	8b 45 08             	mov    0x8(%ebp),%eax
801057a0:	8d 50 01             	lea    0x1(%eax),%edx
801057a3:	89 55 08             	mov    %edx,0x8(%ebp)
801057a6:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801057a9:	8b 45 10             	mov    0x10(%ebp),%eax
801057ac:	8d 50 ff             	lea    -0x1(%eax),%edx
801057af:	89 55 10             	mov    %edx,0x10(%ebp)
801057b2:	85 c0                	test   %eax,%eax
801057b4:	7f e7                	jg     8010579d <strncpy+0x3e>
  return os;
801057b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b9:	c9                   	leave  
801057ba:	c3                   	ret    

801057bb <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057bb:	f3 0f 1e fb          	endbr32 
801057bf:	55                   	push   %ebp
801057c0:	89 e5                	mov    %esp,%ebp
801057c2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057c5:	8b 45 08             	mov    0x8(%ebp),%eax
801057c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057cf:	7f 05                	jg     801057d6 <safestrcpy+0x1b>
    return os;
801057d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d4:	eb 31                	jmp    80105807 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057de:	7e 1e                	jle    801057fe <safestrcpy+0x43>
801057e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801057e3:	8d 42 01             	lea    0x1(%edx),%eax
801057e6:	89 45 0c             	mov    %eax,0xc(%ebp)
801057e9:	8b 45 08             	mov    0x8(%ebp),%eax
801057ec:	8d 48 01             	lea    0x1(%eax),%ecx
801057ef:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057f2:	0f b6 12             	movzbl (%edx),%edx
801057f5:	88 10                	mov    %dl,(%eax)
801057f7:	0f b6 00             	movzbl (%eax),%eax
801057fa:	84 c0                	test   %al,%al
801057fc:	75 d8                	jne    801057d6 <safestrcpy+0x1b>
    ;
  *s = 0;
801057fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105801:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105804:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105807:	c9                   	leave  
80105808:	c3                   	ret    

80105809 <strlen>:

int
strlen(const char *s)
{
80105809:	f3 0f 1e fb          	endbr32 
8010580d:	55                   	push   %ebp
8010580e:	89 e5                	mov    %esp,%ebp
80105810:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105813:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010581a:	eb 04                	jmp    80105820 <strlen+0x17>
8010581c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105820:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105823:	8b 45 08             	mov    0x8(%ebp),%eax
80105826:	01 d0                	add    %edx,%eax
80105828:	0f b6 00             	movzbl (%eax),%eax
8010582b:	84 c0                	test   %al,%al
8010582d:	75 ed                	jne    8010581c <strlen+0x13>
    ;
  return n;
8010582f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105832:	c9                   	leave  
80105833:	c3                   	ret    

80105834 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105834:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105838:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
8010583c:	55                   	push   %ebp
  pushl %ebx
8010583d:	53                   	push   %ebx
  pushl %esi
8010583e:	56                   	push   %esi
  pushl %edi
8010583f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105840:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105842:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105844:	5f                   	pop    %edi
  popl %esi
80105845:	5e                   	pop    %esi
  popl %ebx
80105846:	5b                   	pop    %ebx
  popl %ebp
80105847:	5d                   	pop    %ebp
  ret
80105848:	c3                   	ret    

80105849 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105849:	f3 0f 1e fb          	endbr32 
8010584d:	55                   	push   %ebp
8010584e:	89 e5                	mov    %esp,%ebp
80105850:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105853:	e8 48 ec ff ff       	call   801044a0 <myproc>
80105858:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010585b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585e:	8b 00                	mov    (%eax),%eax
80105860:	39 45 08             	cmp    %eax,0x8(%ebp)
80105863:	73 0f                	jae    80105874 <fetchint+0x2b>
80105865:	8b 45 08             	mov    0x8(%ebp),%eax
80105868:	8d 50 04             	lea    0x4(%eax),%edx
8010586b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586e:	8b 00                	mov    (%eax),%eax
80105870:	39 c2                	cmp    %eax,%edx
80105872:	76 07                	jbe    8010587b <fetchint+0x32>
    return -1;
80105874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105879:	eb 0f                	jmp    8010588a <fetchint+0x41>
  *ip = *(int*)(addr);
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	8b 10                	mov    (%eax),%edx
80105880:	8b 45 0c             	mov    0xc(%ebp),%eax
80105883:	89 10                	mov    %edx,(%eax)
  return 0;
80105885:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010588a:	c9                   	leave  
8010588b:	c3                   	ret    

8010588c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010588c:	f3 0f 1e fb          	endbr32 
80105890:	55                   	push   %ebp
80105891:	89 e5                	mov    %esp,%ebp
80105893:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105896:	e8 05 ec ff ff       	call   801044a0 <myproc>
8010589b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010589e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a1:	8b 00                	mov    (%eax),%eax
801058a3:	39 45 08             	cmp    %eax,0x8(%ebp)
801058a6:	72 07                	jb     801058af <fetchstr+0x23>
    return -1;
801058a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ad:	eb 43                	jmp    801058f2 <fetchstr+0x66>
  *pp = (char*)addr;
801058af:	8b 55 08             	mov    0x8(%ebp),%edx
801058b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b5:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ba:	8b 00                	mov    (%eax),%eax
801058bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c2:	8b 00                	mov    (%eax),%eax
801058c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c7:	eb 1c                	jmp    801058e5 <fetchstr+0x59>
    if(*s == 0)
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cc:	0f b6 00             	movzbl (%eax),%eax
801058cf:	84 c0                	test   %al,%al
801058d1:	75 0e                	jne    801058e1 <fetchstr+0x55>
      return s - *pp;
801058d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d6:	8b 00                	mov    (%eax),%eax
801058d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058db:	29 c2                	sub    %eax,%edx
801058dd:	89 d0                	mov    %edx,%eax
801058df:	eb 11                	jmp    801058f2 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058eb:	72 dc                	jb     801058c9 <fetchstr+0x3d>
  }
  return -1;
801058ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058f2:	c9                   	leave  
801058f3:	c3                   	ret    

801058f4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058f4:	f3 0f 1e fb          	endbr32 
801058f8:	55                   	push   %ebp
801058f9:	89 e5                	mov    %esp,%ebp
801058fb:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058fe:	e8 9d eb ff ff       	call   801044a0 <myproc>
80105903:	8b 40 18             	mov    0x18(%eax),%eax
80105906:	8b 40 44             	mov    0x44(%eax),%eax
80105909:	8b 55 08             	mov    0x8(%ebp),%edx
8010590c:	c1 e2 02             	shl    $0x2,%edx
8010590f:	01 d0                	add    %edx,%eax
80105911:	83 c0 04             	add    $0x4,%eax
80105914:	83 ec 08             	sub    $0x8,%esp
80105917:	ff 75 0c             	pushl  0xc(%ebp)
8010591a:	50                   	push   %eax
8010591b:	e8 29 ff ff ff       	call   80105849 <fetchint>
80105920:	83 c4 10             	add    $0x10,%esp
}
80105923:	c9                   	leave  
80105924:	c3                   	ret    

80105925 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105925:	f3 0f 1e fb          	endbr32 
80105929:	55                   	push   %ebp
8010592a:	89 e5                	mov    %esp,%ebp
8010592c:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010592f:	e8 6c eb ff ff       	call   801044a0 <myproc>
80105934:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105937:	83 ec 08             	sub    $0x8,%esp
8010593a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010593d:	50                   	push   %eax
8010593e:	ff 75 08             	pushl  0x8(%ebp)
80105941:	e8 ae ff ff ff       	call   801058f4 <argint>
80105946:	83 c4 10             	add    $0x10,%esp
80105949:	85 c0                	test   %eax,%eax
8010594b:	79 07                	jns    80105954 <argptr+0x2f>
    return -1;
8010594d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105952:	eb 3b                	jmp    8010598f <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105954:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105958:	78 1f                	js     80105979 <argptr+0x54>
8010595a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595d:	8b 00                	mov    (%eax),%eax
8010595f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105962:	39 d0                	cmp    %edx,%eax
80105964:	76 13                	jbe    80105979 <argptr+0x54>
80105966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105969:	89 c2                	mov    %eax,%edx
8010596b:	8b 45 10             	mov    0x10(%ebp),%eax
8010596e:	01 c2                	add    %eax,%edx
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	8b 00                	mov    (%eax),%eax
80105975:	39 c2                	cmp    %eax,%edx
80105977:	76 07                	jbe    80105980 <argptr+0x5b>
    return -1;
80105979:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597e:	eb 0f                	jmp    8010598f <argptr+0x6a>
  *pp = (char*)i;
80105980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105983:	89 c2                	mov    %eax,%edx
80105985:	8b 45 0c             	mov    0xc(%ebp),%eax
80105988:	89 10                	mov    %edx,(%eax)
  return 0;
8010598a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010598f:	c9                   	leave  
80105990:	c3                   	ret    

80105991 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105991:	f3 0f 1e fb          	endbr32 
80105995:	55                   	push   %ebp
80105996:	89 e5                	mov    %esp,%ebp
80105998:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010599b:	83 ec 08             	sub    $0x8,%esp
8010599e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a1:	50                   	push   %eax
801059a2:	ff 75 08             	pushl  0x8(%ebp)
801059a5:	e8 4a ff ff ff       	call   801058f4 <argint>
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	85 c0                	test   %eax,%eax
801059af:	79 07                	jns    801059b8 <argstr+0x27>
    return -1;
801059b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b6:	eb 12                	jmp    801059ca <argstr+0x39>
  return fetchstr(addr, pp);
801059b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bb:	83 ec 08             	sub    $0x8,%esp
801059be:	ff 75 0c             	pushl  0xc(%ebp)
801059c1:	50                   	push   %eax
801059c2:	e8 c5 fe ff ff       	call   8010588c <fetchstr>
801059c7:	83 c4 10             	add    $0x10,%esp
}
801059ca:	c9                   	leave  
801059cb:	c3                   	ret    

801059cc <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059cc:	f3 0f 1e fb          	endbr32 
801059d0:	55                   	push   %ebp
801059d1:	89 e5                	mov    %esp,%ebp
801059d3:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059d6:	e8 c5 ea ff ff       	call   801044a0 <myproc>
801059db:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e1:	8b 40 18             	mov    0x18(%eax),%eax
801059e4:	8b 40 1c             	mov    0x1c(%eax),%eax
801059e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059ee:	7e 2f                	jle    80105a1f <syscall+0x53>
801059f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f3:	83 f8 18             	cmp    $0x18,%eax
801059f6:	77 27                	ja     80105a1f <syscall+0x53>
801059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fb:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105a02:	85 c0                	test   %eax,%eax
80105a04:	74 19                	je     80105a1f <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105a10:	ff d0                	call   *%eax
80105a12:	89 c2                	mov    %eax,%edx
80105a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a17:	8b 40 18             	mov    0x18(%eax),%eax
80105a1a:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a1d:	eb 2c                	jmp    80105a4b <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a28:	8b 40 10             	mov    0x10(%eax),%eax
80105a2b:	ff 75 f0             	pushl  -0x10(%ebp)
80105a2e:	52                   	push   %edx
80105a2f:	50                   	push   %eax
80105a30:	68 38 97 10 80       	push   $0x80109738
80105a35:	e8 de a9 ff ff       	call   80100418 <cprintf>
80105a3a:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	8b 40 18             	mov    0x18(%eax),%eax
80105a43:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a4a:	90                   	nop
80105a4b:	90                   	nop
80105a4c:	c9                   	leave  
80105a4d:	c3                   	ret    

80105a4e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a4e:	f3 0f 1e fb          	endbr32 
80105a52:	55                   	push   %ebp
80105a53:	89 e5                	mov    %esp,%ebp
80105a55:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a58:	83 ec 08             	sub    $0x8,%esp
80105a5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a5e:	50                   	push   %eax
80105a5f:	ff 75 08             	pushl  0x8(%ebp)
80105a62:	e8 8d fe ff ff       	call   801058f4 <argint>
80105a67:	83 c4 10             	add    $0x10,%esp
80105a6a:	85 c0                	test   %eax,%eax
80105a6c:	79 07                	jns    80105a75 <argfd+0x27>
    return -1;
80105a6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a73:	eb 4f                	jmp    80105ac4 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a78:	85 c0                	test   %eax,%eax
80105a7a:	78 20                	js     80105a9c <argfd+0x4e>
80105a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7f:	83 f8 0f             	cmp    $0xf,%eax
80105a82:	7f 18                	jg     80105a9c <argfd+0x4e>
80105a84:	e8 17 ea ff ff       	call   801044a0 <myproc>
80105a89:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a8c:	83 c2 08             	add    $0x8,%edx
80105a8f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a9a:	75 07                	jne    80105aa3 <argfd+0x55>
    return -1;
80105a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa1:	eb 21                	jmp    80105ac4 <argfd+0x76>
  if(pfd)
80105aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105aa7:	74 08                	je     80105ab1 <argfd+0x63>
    *pfd = fd;
80105aa9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aac:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aaf:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ab1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ab5:	74 08                	je     80105abf <argfd+0x71>
    *pf = f;
80105ab7:	8b 45 10             	mov    0x10(%ebp),%eax
80105aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105abd:	89 10                	mov    %edx,(%eax)
  return 0;
80105abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ac4:	c9                   	leave  
80105ac5:	c3                   	ret    

80105ac6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ac6:	f3 0f 1e fb          	endbr32 
80105aca:	55                   	push   %ebp
80105acb:	89 e5                	mov    %esp,%ebp
80105acd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ad0:	e8 cb e9 ff ff       	call   801044a0 <myproc>
80105ad5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105adf:	eb 2a                	jmp    80105b0b <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ae7:	83 c2 08             	add    $0x8,%edx
80105aea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105aee:	85 c0                	test   %eax,%eax
80105af0:	75 15                	jne    80105b07 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af8:	8d 4a 08             	lea    0x8(%edx),%ecx
80105afb:	8b 55 08             	mov    0x8(%ebp),%edx
80105afe:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	eb 0f                	jmp    80105b16 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b0b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b0f:	7e d0                	jle    80105ae1 <fdalloc+0x1b>
    }
  }
  return -1;
80105b11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b16:	c9                   	leave  
80105b17:	c3                   	ret    

80105b18 <sys_dup>:

int
sys_dup(void)
{
80105b18:	f3 0f 1e fb          	endbr32 
80105b1c:	55                   	push   %ebp
80105b1d:	89 e5                	mov    %esp,%ebp
80105b1f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b22:	83 ec 04             	sub    $0x4,%esp
80105b25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b28:	50                   	push   %eax
80105b29:	6a 00                	push   $0x0
80105b2b:	6a 00                	push   $0x0
80105b2d:	e8 1c ff ff ff       	call   80105a4e <argfd>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	85 c0                	test   %eax,%eax
80105b37:	79 07                	jns    80105b40 <sys_dup+0x28>
    return -1;
80105b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3e:	eb 31                	jmp    80105b71 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b43:	83 ec 0c             	sub    $0xc,%esp
80105b46:	50                   	push   %eax
80105b47:	e8 7a ff ff ff       	call   80105ac6 <fdalloc>
80105b4c:	83 c4 10             	add    $0x10,%esp
80105b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b56:	79 07                	jns    80105b5f <sys_dup+0x47>
    return -1;
80105b58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5d:	eb 12                	jmp    80105b71 <sys_dup+0x59>
  filedup(f);
80105b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b62:	83 ec 0c             	sub    $0xc,%esp
80105b65:	50                   	push   %eax
80105b66:	e8 d2 b5 ff ff       	call   8010113d <filedup>
80105b6b:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b71:	c9                   	leave  
80105b72:	c3                   	ret    

80105b73 <sys_read>:

int
sys_read(void)
{
80105b73:	f3 0f 1e fb          	endbr32 
80105b77:	55                   	push   %ebp
80105b78:	89 e5                	mov    %esp,%ebp
80105b7a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b7d:	83 ec 04             	sub    $0x4,%esp
80105b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b83:	50                   	push   %eax
80105b84:	6a 00                	push   $0x0
80105b86:	6a 00                	push   $0x0
80105b88:	e8 c1 fe ff ff       	call   80105a4e <argfd>
80105b8d:	83 c4 10             	add    $0x10,%esp
80105b90:	85 c0                	test   %eax,%eax
80105b92:	78 2e                	js     80105bc2 <sys_read+0x4f>
80105b94:	83 ec 08             	sub    $0x8,%esp
80105b97:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b9a:	50                   	push   %eax
80105b9b:	6a 02                	push   $0x2
80105b9d:	e8 52 fd ff ff       	call   801058f4 <argint>
80105ba2:	83 c4 10             	add    $0x10,%esp
80105ba5:	85 c0                	test   %eax,%eax
80105ba7:	78 19                	js     80105bc2 <sys_read+0x4f>
80105ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bac:	83 ec 04             	sub    $0x4,%esp
80105baf:	50                   	push   %eax
80105bb0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bb3:	50                   	push   %eax
80105bb4:	6a 01                	push   $0x1
80105bb6:	e8 6a fd ff ff       	call   80105925 <argptr>
80105bbb:	83 c4 10             	add    $0x10,%esp
80105bbe:	85 c0                	test   %eax,%eax
80105bc0:	79 07                	jns    80105bc9 <sys_read+0x56>
    return -1;
80105bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc7:	eb 17                	jmp    80105be0 <sys_read+0x6d>
  return fileread(f, p, n);
80105bc9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bcc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd2:	83 ec 04             	sub    $0x4,%esp
80105bd5:	51                   	push   %ecx
80105bd6:	52                   	push   %edx
80105bd7:	50                   	push   %eax
80105bd8:	e8 fc b6 ff ff       	call   801012d9 <fileread>
80105bdd:	83 c4 10             	add    $0x10,%esp
}
80105be0:	c9                   	leave  
80105be1:	c3                   	ret    

80105be2 <sys_write>:

int
sys_write(void)
{
80105be2:	f3 0f 1e fb          	endbr32 
80105be6:	55                   	push   %ebp
80105be7:	89 e5                	mov    %esp,%ebp
80105be9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bec:	83 ec 04             	sub    $0x4,%esp
80105bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bf2:	50                   	push   %eax
80105bf3:	6a 00                	push   $0x0
80105bf5:	6a 00                	push   $0x0
80105bf7:	e8 52 fe ff ff       	call   80105a4e <argfd>
80105bfc:	83 c4 10             	add    $0x10,%esp
80105bff:	85 c0                	test   %eax,%eax
80105c01:	78 2e                	js     80105c31 <sys_write+0x4f>
80105c03:	83 ec 08             	sub    $0x8,%esp
80105c06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c09:	50                   	push   %eax
80105c0a:	6a 02                	push   $0x2
80105c0c:	e8 e3 fc ff ff       	call   801058f4 <argint>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	85 c0                	test   %eax,%eax
80105c16:	78 19                	js     80105c31 <sys_write+0x4f>
80105c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1b:	83 ec 04             	sub    $0x4,%esp
80105c1e:	50                   	push   %eax
80105c1f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c22:	50                   	push   %eax
80105c23:	6a 01                	push   $0x1
80105c25:	e8 fb fc ff ff       	call   80105925 <argptr>
80105c2a:	83 c4 10             	add    $0x10,%esp
80105c2d:	85 c0                	test   %eax,%eax
80105c2f:	79 07                	jns    80105c38 <sys_write+0x56>
    return -1;
80105c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c36:	eb 17                	jmp    80105c4f <sys_write+0x6d>
  return filewrite(f, p, n);
80105c38:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c41:	83 ec 04             	sub    $0x4,%esp
80105c44:	51                   	push   %ecx
80105c45:	52                   	push   %edx
80105c46:	50                   	push   %eax
80105c47:	e8 49 b7 ff ff       	call   80101395 <filewrite>
80105c4c:	83 c4 10             	add    $0x10,%esp
}
80105c4f:	c9                   	leave  
80105c50:	c3                   	ret    

80105c51 <sys_close>:

int
sys_close(void)
{
80105c51:	f3 0f 1e fb          	endbr32 
80105c55:	55                   	push   %ebp
80105c56:	89 e5                	mov    %esp,%ebp
80105c58:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c5b:	83 ec 04             	sub    $0x4,%esp
80105c5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c61:	50                   	push   %eax
80105c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c65:	50                   	push   %eax
80105c66:	6a 00                	push   $0x0
80105c68:	e8 e1 fd ff ff       	call   80105a4e <argfd>
80105c6d:	83 c4 10             	add    $0x10,%esp
80105c70:	85 c0                	test   %eax,%eax
80105c72:	79 07                	jns    80105c7b <sys_close+0x2a>
    return -1;
80105c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c79:	eb 27                	jmp    80105ca2 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c7b:	e8 20 e8 ff ff       	call   801044a0 <myproc>
80105c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c83:	83 c2 08             	add    $0x8,%edx
80105c86:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c8d:	00 
  fileclose(f);
80105c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c91:	83 ec 0c             	sub    $0xc,%esp
80105c94:	50                   	push   %eax
80105c95:	e8 f8 b4 ff ff       	call   80101192 <fileclose>
80105c9a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ca2:	c9                   	leave  
80105ca3:	c3                   	ret    

80105ca4 <sys_fstat>:

int
sys_fstat(void)
{
80105ca4:	f3 0f 1e fb          	endbr32 
80105ca8:	55                   	push   %ebp
80105ca9:	89 e5                	mov    %esp,%ebp
80105cab:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105cae:	83 ec 04             	sub    $0x4,%esp
80105cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cb4:	50                   	push   %eax
80105cb5:	6a 00                	push   $0x0
80105cb7:	6a 00                	push   $0x0
80105cb9:	e8 90 fd ff ff       	call   80105a4e <argfd>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	85 c0                	test   %eax,%eax
80105cc3:	78 17                	js     80105cdc <sys_fstat+0x38>
80105cc5:	83 ec 04             	sub    $0x4,%esp
80105cc8:	6a 14                	push   $0x14
80105cca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ccd:	50                   	push   %eax
80105cce:	6a 01                	push   $0x1
80105cd0:	e8 50 fc ff ff       	call   80105925 <argptr>
80105cd5:	83 c4 10             	add    $0x10,%esp
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	79 07                	jns    80105ce3 <sys_fstat+0x3f>
    return -1;
80105cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce1:	eb 13                	jmp    80105cf6 <sys_fstat+0x52>
  return filestat(f, st);
80105ce3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce9:	83 ec 08             	sub    $0x8,%esp
80105cec:	52                   	push   %edx
80105ced:	50                   	push   %eax
80105cee:	e8 8b b5 ff ff       	call   8010127e <filestat>
80105cf3:	83 c4 10             	add    $0x10,%esp
}
80105cf6:	c9                   	leave  
80105cf7:	c3                   	ret    

80105cf8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cf8:	f3 0f 1e fb          	endbr32 
80105cfc:	55                   	push   %ebp
80105cfd:	89 e5                	mov    %esp,%ebp
80105cff:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d02:	83 ec 08             	sub    $0x8,%esp
80105d05:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d08:	50                   	push   %eax
80105d09:	6a 00                	push   $0x0
80105d0b:	e8 81 fc ff ff       	call   80105991 <argstr>
80105d10:	83 c4 10             	add    $0x10,%esp
80105d13:	85 c0                	test   %eax,%eax
80105d15:	78 15                	js     80105d2c <sys_link+0x34>
80105d17:	83 ec 08             	sub    $0x8,%esp
80105d1a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d1d:	50                   	push   %eax
80105d1e:	6a 01                	push   $0x1
80105d20:	e8 6c fc ff ff       	call   80105991 <argstr>
80105d25:	83 c4 10             	add    $0x10,%esp
80105d28:	85 c0                	test   %eax,%eax
80105d2a:	79 0a                	jns    80105d36 <sys_link+0x3e>
    return -1;
80105d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d31:	e9 68 01 00 00       	jmp    80105e9e <sys_link+0x1a6>

  begin_op();
80105d36:	e8 a6 d9 ff ff       	call   801036e1 <begin_op>
  if((ip = namei(old)) == 0){
80105d3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d3e:	83 ec 0c             	sub    $0xc,%esp
80105d41:	50                   	push   %eax
80105d42:	e8 36 c9 ff ff       	call   8010267d <namei>
80105d47:	83 c4 10             	add    $0x10,%esp
80105d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d51:	75 0f                	jne    80105d62 <sys_link+0x6a>
    end_op();
80105d53:	e8 19 da ff ff       	call   80103771 <end_op>
    return -1;
80105d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5d:	e9 3c 01 00 00       	jmp    80105e9e <sys_link+0x1a6>
  }

  ilock(ip);
80105d62:	83 ec 0c             	sub    $0xc,%esp
80105d65:	ff 75 f4             	pushl  -0xc(%ebp)
80105d68:	e8 a5 bd ff ff       	call   80101b12 <ilock>
80105d6d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d73:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d77:	66 83 f8 01          	cmp    $0x1,%ax
80105d7b:	75 1d                	jne    80105d9a <sys_link+0xa2>
    iunlockput(ip);
80105d7d:	83 ec 0c             	sub    $0xc,%esp
80105d80:	ff 75 f4             	pushl  -0xc(%ebp)
80105d83:	e8 c7 bf ff ff       	call   80101d4f <iunlockput>
80105d88:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d8b:	e8 e1 d9 ff ff       	call   80103771 <end_op>
    return -1;
80105d90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d95:	e9 04 01 00 00       	jmp    80105e9e <sys_link+0x1a6>
  }

  ip->nlink++;
80105d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105da1:	83 c0 01             	add    $0x1,%eax
80105da4:	89 c2                	mov    %eax,%edx
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dad:	83 ec 0c             	sub    $0xc,%esp
80105db0:	ff 75 f4             	pushl  -0xc(%ebp)
80105db3:	e8 71 bb ff ff       	call   80101929 <iupdate>
80105db8:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc1:	e8 63 be ff ff       	call   80101c29 <iunlock>
80105dc6:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105dcc:	83 ec 08             	sub    $0x8,%esp
80105dcf:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105dd2:	52                   	push   %edx
80105dd3:	50                   	push   %eax
80105dd4:	e8 c4 c8 ff ff       	call   8010269d <nameiparent>
80105dd9:	83 c4 10             	add    $0x10,%esp
80105ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ddf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105de3:	74 71                	je     80105e56 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105de5:	83 ec 0c             	sub    $0xc,%esp
80105de8:	ff 75 f0             	pushl  -0x10(%ebp)
80105deb:	e8 22 bd ff ff       	call   80101b12 <ilock>
80105df0:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df6:	8b 10                	mov    (%eax),%edx
80105df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfb:	8b 00                	mov    (%eax),%eax
80105dfd:	39 c2                	cmp    %eax,%edx
80105dff:	75 1d                	jne    80105e1e <sys_link+0x126>
80105e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e04:	8b 40 04             	mov    0x4(%eax),%eax
80105e07:	83 ec 04             	sub    $0x4,%esp
80105e0a:	50                   	push   %eax
80105e0b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e0e:	50                   	push   %eax
80105e0f:	ff 75 f0             	pushl  -0x10(%ebp)
80105e12:	e8 c3 c5 ff ff       	call   801023da <dirlink>
80105e17:	83 c4 10             	add    $0x10,%esp
80105e1a:	85 c0                	test   %eax,%eax
80105e1c:	79 10                	jns    80105e2e <sys_link+0x136>
    iunlockput(dp);
80105e1e:	83 ec 0c             	sub    $0xc,%esp
80105e21:	ff 75 f0             	pushl  -0x10(%ebp)
80105e24:	e8 26 bf ff ff       	call   80101d4f <iunlockput>
80105e29:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e2c:	eb 29                	jmp    80105e57 <sys_link+0x15f>
  }
  iunlockput(dp);
80105e2e:	83 ec 0c             	sub    $0xc,%esp
80105e31:	ff 75 f0             	pushl  -0x10(%ebp)
80105e34:	e8 16 bf ff ff       	call   80101d4f <iunlockput>
80105e39:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e3c:	83 ec 0c             	sub    $0xc,%esp
80105e3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e42:	e8 34 be ff ff       	call   80101c7b <iput>
80105e47:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e4a:	e8 22 d9 ff ff       	call   80103771 <end_op>

  return 0;
80105e4f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e54:	eb 48                	jmp    80105e9e <sys_link+0x1a6>
    goto bad;
80105e56:	90                   	nop

bad:
  ilock(ip);
80105e57:	83 ec 0c             	sub    $0xc,%esp
80105e5a:	ff 75 f4             	pushl  -0xc(%ebp)
80105e5d:	e8 b0 bc ff ff       	call   80101b12 <ilock>
80105e62:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e68:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e6c:	83 e8 01             	sub    $0x1,%eax
80105e6f:	89 c2                	mov    %eax,%edx
80105e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e74:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e78:	83 ec 0c             	sub    $0xc,%esp
80105e7b:	ff 75 f4             	pushl  -0xc(%ebp)
80105e7e:	e8 a6 ba ff ff       	call   80101929 <iupdate>
80105e83:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e86:	83 ec 0c             	sub    $0xc,%esp
80105e89:	ff 75 f4             	pushl  -0xc(%ebp)
80105e8c:	e8 be be ff ff       	call   80101d4f <iunlockput>
80105e91:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e94:	e8 d8 d8 ff ff       	call   80103771 <end_op>
  return -1;
80105e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e9e:	c9                   	leave  
80105e9f:	c3                   	ret    

80105ea0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ea0:	f3 0f 1e fb          	endbr32 
80105ea4:	55                   	push   %ebp
80105ea5:	89 e5                	mov    %esp,%ebp
80105ea7:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eaa:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105eb1:	eb 40                	jmp    80105ef3 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	6a 10                	push   $0x10
80105eb8:	50                   	push   %eax
80105eb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ebc:	50                   	push   %eax
80105ebd:	ff 75 08             	pushl  0x8(%ebp)
80105ec0:	e8 55 c1 ff ff       	call   8010201a <readi>
80105ec5:	83 c4 10             	add    $0x10,%esp
80105ec8:	83 f8 10             	cmp    $0x10,%eax
80105ecb:	74 0d                	je     80105eda <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ecd:	83 ec 0c             	sub    $0xc,%esp
80105ed0:	68 54 97 10 80       	push   $0x80109754
80105ed5:	e8 2e a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105eda:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ede:	66 85 c0             	test   %ax,%ax
80105ee1:	74 07                	je     80105eea <isdirempty+0x4a>
      return 0;
80105ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ee8:	eb 1b                	jmp    80105f05 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eed:	83 c0 10             	add    $0x10,%eax
80105ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ef6:	8b 50 58             	mov    0x58(%eax),%edx
80105ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efc:	39 c2                	cmp    %eax,%edx
80105efe:	77 b3                	ja     80105eb3 <isdirempty+0x13>
  }
  return 1;
80105f00:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f05:	c9                   	leave  
80105f06:	c3                   	ret    

80105f07 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f07:	f3 0f 1e fb          	endbr32 
80105f0b:	55                   	push   %ebp
80105f0c:	89 e5                	mov    %esp,%ebp
80105f0e:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f11:	83 ec 08             	sub    $0x8,%esp
80105f14:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f17:	50                   	push   %eax
80105f18:	6a 00                	push   $0x0
80105f1a:	e8 72 fa ff ff       	call   80105991 <argstr>
80105f1f:	83 c4 10             	add    $0x10,%esp
80105f22:	85 c0                	test   %eax,%eax
80105f24:	79 0a                	jns    80105f30 <sys_unlink+0x29>
    return -1;
80105f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2b:	e9 bf 01 00 00       	jmp    801060ef <sys_unlink+0x1e8>

  begin_op();
80105f30:	e8 ac d7 ff ff       	call   801036e1 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f35:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f38:	83 ec 08             	sub    $0x8,%esp
80105f3b:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f3e:	52                   	push   %edx
80105f3f:	50                   	push   %eax
80105f40:	e8 58 c7 ff ff       	call   8010269d <nameiparent>
80105f45:	83 c4 10             	add    $0x10,%esp
80105f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4f:	75 0f                	jne    80105f60 <sys_unlink+0x59>
    end_op();
80105f51:	e8 1b d8 ff ff       	call   80103771 <end_op>
    return -1;
80105f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5b:	e9 8f 01 00 00       	jmp    801060ef <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	ff 75 f4             	pushl  -0xc(%ebp)
80105f66:	e8 a7 bb ff ff       	call   80101b12 <ilock>
80105f6b:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f6e:	83 ec 08             	sub    $0x8,%esp
80105f71:	68 66 97 10 80       	push   $0x80109766
80105f76:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f79:	50                   	push   %eax
80105f7a:	e8 7e c3 ff ff       	call   801022fd <namecmp>
80105f7f:	83 c4 10             	add    $0x10,%esp
80105f82:	85 c0                	test   %eax,%eax
80105f84:	0f 84 49 01 00 00    	je     801060d3 <sys_unlink+0x1cc>
80105f8a:	83 ec 08             	sub    $0x8,%esp
80105f8d:	68 68 97 10 80       	push   $0x80109768
80105f92:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f95:	50                   	push   %eax
80105f96:	e8 62 c3 ff ff       	call   801022fd <namecmp>
80105f9b:	83 c4 10             	add    $0x10,%esp
80105f9e:	85 c0                	test   %eax,%eax
80105fa0:	0f 84 2d 01 00 00    	je     801060d3 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fa6:	83 ec 04             	sub    $0x4,%esp
80105fa9:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105fac:	50                   	push   %eax
80105fad:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fb0:	50                   	push   %eax
80105fb1:	ff 75 f4             	pushl  -0xc(%ebp)
80105fb4:	e8 63 c3 ff ff       	call   8010231c <dirlookup>
80105fb9:	83 c4 10             	add    $0x10,%esp
80105fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fc3:	0f 84 0d 01 00 00    	je     801060d6 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fc9:	83 ec 0c             	sub    $0xc,%esp
80105fcc:	ff 75 f0             	pushl  -0x10(%ebp)
80105fcf:	e8 3e bb ff ff       	call   80101b12 <ilock>
80105fd4:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fda:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fde:	66 85 c0             	test   %ax,%ax
80105fe1:	7f 0d                	jg     80105ff0 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fe3:	83 ec 0c             	sub    $0xc,%esp
80105fe6:	68 6b 97 10 80       	push   $0x8010976b
80105feb:	e8 18 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ff7:	66 83 f8 01          	cmp    $0x1,%ax
80105ffb:	75 25                	jne    80106022 <sys_unlink+0x11b>
80105ffd:	83 ec 0c             	sub    $0xc,%esp
80106000:	ff 75 f0             	pushl  -0x10(%ebp)
80106003:	e8 98 fe ff ff       	call   80105ea0 <isdirempty>
80106008:	83 c4 10             	add    $0x10,%esp
8010600b:	85 c0                	test   %eax,%eax
8010600d:	75 13                	jne    80106022 <sys_unlink+0x11b>
    iunlockput(ip);
8010600f:	83 ec 0c             	sub    $0xc,%esp
80106012:	ff 75 f0             	pushl  -0x10(%ebp)
80106015:	e8 35 bd ff ff       	call   80101d4f <iunlockput>
8010601a:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010601d:	e9 b5 00 00 00       	jmp    801060d7 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106022:	83 ec 04             	sub    $0x4,%esp
80106025:	6a 10                	push   $0x10
80106027:	6a 00                	push   $0x0
80106029:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010602c:	50                   	push   %eax
8010602d:	e8 6e f5 ff ff       	call   801055a0 <memset>
80106032:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106035:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106038:	6a 10                	push   $0x10
8010603a:	50                   	push   %eax
8010603b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010603e:	50                   	push   %eax
8010603f:	ff 75 f4             	pushl  -0xc(%ebp)
80106042:	e8 2c c1 ff ff       	call   80102173 <writei>
80106047:	83 c4 10             	add    $0x10,%esp
8010604a:	83 f8 10             	cmp    $0x10,%eax
8010604d:	74 0d                	je     8010605c <sys_unlink+0x155>
    panic("unlink: writei");
8010604f:	83 ec 0c             	sub    $0xc,%esp
80106052:	68 7d 97 10 80       	push   $0x8010977d
80106057:	e8 ac a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106063:	66 83 f8 01          	cmp    $0x1,%ax
80106067:	75 21                	jne    8010608a <sys_unlink+0x183>
    dp->nlink--;
80106069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106070:	83 e8 01             	sub    $0x1,%eax
80106073:	89 c2                	mov    %eax,%edx
80106075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106078:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010607c:	83 ec 0c             	sub    $0xc,%esp
8010607f:	ff 75 f4             	pushl  -0xc(%ebp)
80106082:	e8 a2 b8 ff ff       	call   80101929 <iupdate>
80106087:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010608a:	83 ec 0c             	sub    $0xc,%esp
8010608d:	ff 75 f4             	pushl  -0xc(%ebp)
80106090:	e8 ba bc ff ff       	call   80101d4f <iunlockput>
80106095:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010609f:	83 e8 01             	sub    $0x1,%eax
801060a2:	89 c2                	mov    %eax,%edx
801060a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801060ab:	83 ec 0c             	sub    $0xc,%esp
801060ae:	ff 75 f0             	pushl  -0x10(%ebp)
801060b1:	e8 73 b8 ff ff       	call   80101929 <iupdate>
801060b6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060b9:	83 ec 0c             	sub    $0xc,%esp
801060bc:	ff 75 f0             	pushl  -0x10(%ebp)
801060bf:	e8 8b bc ff ff       	call   80101d4f <iunlockput>
801060c4:	83 c4 10             	add    $0x10,%esp

  end_op();
801060c7:	e8 a5 d6 ff ff       	call   80103771 <end_op>

  return 0;
801060cc:	b8 00 00 00 00       	mov    $0x0,%eax
801060d1:	eb 1c                	jmp    801060ef <sys_unlink+0x1e8>
    goto bad;
801060d3:	90                   	nop
801060d4:	eb 01                	jmp    801060d7 <sys_unlink+0x1d0>
    goto bad;
801060d6:	90                   	nop

bad:
  iunlockput(dp);
801060d7:	83 ec 0c             	sub    $0xc,%esp
801060da:	ff 75 f4             	pushl  -0xc(%ebp)
801060dd:	e8 6d bc ff ff       	call   80101d4f <iunlockput>
801060e2:	83 c4 10             	add    $0x10,%esp
  end_op();
801060e5:	e8 87 d6 ff ff       	call   80103771 <end_op>
  return -1;
801060ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ef:	c9                   	leave  
801060f0:	c3                   	ret    

801060f1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060f1:	f3 0f 1e fb          	endbr32 
801060f5:	55                   	push   %ebp
801060f6:	89 e5                	mov    %esp,%ebp
801060f8:	83 ec 38             	sub    $0x38,%esp
801060fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060fe:	8b 55 10             	mov    0x10(%ebp),%edx
80106101:	8b 45 14             	mov    0x14(%ebp),%eax
80106104:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106108:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010610c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106110:	83 ec 08             	sub    $0x8,%esp
80106113:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106116:	50                   	push   %eax
80106117:	ff 75 08             	pushl  0x8(%ebp)
8010611a:	e8 7e c5 ff ff       	call   8010269d <nameiparent>
8010611f:	83 c4 10             	add    $0x10,%esp
80106122:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106125:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106129:	75 0a                	jne    80106135 <create+0x44>
    return 0;
8010612b:	b8 00 00 00 00       	mov    $0x0,%eax
80106130:	e9 8e 01 00 00       	jmp    801062c3 <create+0x1d2>
  ilock(dp);
80106135:	83 ec 0c             	sub    $0xc,%esp
80106138:	ff 75 f4             	pushl  -0xc(%ebp)
8010613b:	e8 d2 b9 ff ff       	call   80101b12 <ilock>
80106140:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106143:	83 ec 04             	sub    $0x4,%esp
80106146:	6a 00                	push   $0x0
80106148:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010614b:	50                   	push   %eax
8010614c:	ff 75 f4             	pushl  -0xc(%ebp)
8010614f:	e8 c8 c1 ff ff       	call   8010231c <dirlookup>
80106154:	83 c4 10             	add    $0x10,%esp
80106157:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010615a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010615e:	74 50                	je     801061b0 <create+0xbf>
    iunlockput(dp);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	ff 75 f4             	pushl  -0xc(%ebp)
80106166:	e8 e4 bb ff ff       	call   80101d4f <iunlockput>
8010616b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010616e:	83 ec 0c             	sub    $0xc,%esp
80106171:	ff 75 f0             	pushl  -0x10(%ebp)
80106174:	e8 99 b9 ff ff       	call   80101b12 <ilock>
80106179:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010617c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106181:	75 15                	jne    80106198 <create+0xa7>
80106183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106186:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010618a:	66 83 f8 02          	cmp    $0x2,%ax
8010618e:	75 08                	jne    80106198 <create+0xa7>
      return ip;
80106190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106193:	e9 2b 01 00 00       	jmp    801062c3 <create+0x1d2>
    iunlockput(ip);
80106198:	83 ec 0c             	sub    $0xc,%esp
8010619b:	ff 75 f0             	pushl  -0x10(%ebp)
8010619e:	e8 ac bb ff ff       	call   80101d4f <iunlockput>
801061a3:	83 c4 10             	add    $0x10,%esp
    return 0;
801061a6:	b8 00 00 00 00       	mov    $0x0,%eax
801061ab:	e9 13 01 00 00       	jmp    801062c3 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061b0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b7:	8b 00                	mov    (%eax),%eax
801061b9:	83 ec 08             	sub    $0x8,%esp
801061bc:	52                   	push   %edx
801061bd:	50                   	push   %eax
801061be:	e8 8b b6 ff ff       	call   8010184e <ialloc>
801061c3:	83 c4 10             	add    $0x10,%esp
801061c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061cd:	75 0d                	jne    801061dc <create+0xeb>
    panic("create: ialloc");
801061cf:	83 ec 0c             	sub    $0xc,%esp
801061d2:	68 8c 97 10 80       	push   $0x8010978c
801061d7:	e8 2c a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061dc:	83 ec 0c             	sub    $0xc,%esp
801061df:	ff 75 f0             	pushl  -0x10(%ebp)
801061e2:	e8 2b b9 ff ff       	call   80101b12 <ilock>
801061e7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ed:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061f1:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061fc:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106203:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106209:	83 ec 0c             	sub    $0xc,%esp
8010620c:	ff 75 f0             	pushl  -0x10(%ebp)
8010620f:	e8 15 b7 ff ff       	call   80101929 <iupdate>
80106214:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106217:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010621c:	75 6a                	jne    80106288 <create+0x197>
    dp->nlink++;  // for ".."
8010621e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106221:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106225:	83 c0 01             	add    $0x1,%eax
80106228:	89 c2                	mov    %eax,%edx
8010622a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	ff 75 f4             	pushl  -0xc(%ebp)
80106237:	e8 ed b6 ff ff       	call   80101929 <iupdate>
8010623c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010623f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106242:	8b 40 04             	mov    0x4(%eax),%eax
80106245:	83 ec 04             	sub    $0x4,%esp
80106248:	50                   	push   %eax
80106249:	68 66 97 10 80       	push   $0x80109766
8010624e:	ff 75 f0             	pushl  -0x10(%ebp)
80106251:	e8 84 c1 ff ff       	call   801023da <dirlink>
80106256:	83 c4 10             	add    $0x10,%esp
80106259:	85 c0                	test   %eax,%eax
8010625b:	78 1e                	js     8010627b <create+0x18a>
8010625d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106260:	8b 40 04             	mov    0x4(%eax),%eax
80106263:	83 ec 04             	sub    $0x4,%esp
80106266:	50                   	push   %eax
80106267:	68 68 97 10 80       	push   $0x80109768
8010626c:	ff 75 f0             	pushl  -0x10(%ebp)
8010626f:	e8 66 c1 ff ff       	call   801023da <dirlink>
80106274:	83 c4 10             	add    $0x10,%esp
80106277:	85 c0                	test   %eax,%eax
80106279:	79 0d                	jns    80106288 <create+0x197>
      panic("create dots");
8010627b:	83 ec 0c             	sub    $0xc,%esp
8010627e:	68 9b 97 10 80       	push   $0x8010979b
80106283:	e8 80 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628b:	8b 40 04             	mov    0x4(%eax),%eax
8010628e:	83 ec 04             	sub    $0x4,%esp
80106291:	50                   	push   %eax
80106292:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106295:	50                   	push   %eax
80106296:	ff 75 f4             	pushl  -0xc(%ebp)
80106299:	e8 3c c1 ff ff       	call   801023da <dirlink>
8010629e:	83 c4 10             	add    $0x10,%esp
801062a1:	85 c0                	test   %eax,%eax
801062a3:	79 0d                	jns    801062b2 <create+0x1c1>
    panic("create: dirlink");
801062a5:	83 ec 0c             	sub    $0xc,%esp
801062a8:	68 a7 97 10 80       	push   $0x801097a7
801062ad:	e8 56 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
801062b2:	83 ec 0c             	sub    $0xc,%esp
801062b5:	ff 75 f4             	pushl  -0xc(%ebp)
801062b8:	e8 92 ba ff ff       	call   80101d4f <iunlockput>
801062bd:	83 c4 10             	add    $0x10,%esp

  return ip;
801062c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062c3:	c9                   	leave  
801062c4:	c3                   	ret    

801062c5 <sys_open>:

int
sys_open(void)
{
801062c5:	f3 0f 1e fb          	endbr32 
801062c9:	55                   	push   %ebp
801062ca:	89 e5                	mov    %esp,%ebp
801062cc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062cf:	83 ec 08             	sub    $0x8,%esp
801062d2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062d5:	50                   	push   %eax
801062d6:	6a 00                	push   $0x0
801062d8:	e8 b4 f6 ff ff       	call   80105991 <argstr>
801062dd:	83 c4 10             	add    $0x10,%esp
801062e0:	85 c0                	test   %eax,%eax
801062e2:	78 15                	js     801062f9 <sys_open+0x34>
801062e4:	83 ec 08             	sub    $0x8,%esp
801062e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062ea:	50                   	push   %eax
801062eb:	6a 01                	push   $0x1
801062ed:	e8 02 f6 ff ff       	call   801058f4 <argint>
801062f2:	83 c4 10             	add    $0x10,%esp
801062f5:	85 c0                	test   %eax,%eax
801062f7:	79 0a                	jns    80106303 <sys_open+0x3e>
    return -1;
801062f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fe:	e9 61 01 00 00       	jmp    80106464 <sys_open+0x19f>

  begin_op();
80106303:	e8 d9 d3 ff ff       	call   801036e1 <begin_op>

  if(omode & O_CREATE){
80106308:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010630b:	25 00 02 00 00       	and    $0x200,%eax
80106310:	85 c0                	test   %eax,%eax
80106312:	74 2a                	je     8010633e <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106314:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106317:	6a 00                	push   $0x0
80106319:	6a 00                	push   $0x0
8010631b:	6a 02                	push   $0x2
8010631d:	50                   	push   %eax
8010631e:	e8 ce fd ff ff       	call   801060f1 <create>
80106323:	83 c4 10             	add    $0x10,%esp
80106326:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632d:	75 75                	jne    801063a4 <sys_open+0xdf>
      end_op();
8010632f:	e8 3d d4 ff ff       	call   80103771 <end_op>
      return -1;
80106334:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106339:	e9 26 01 00 00       	jmp    80106464 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
8010633e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106341:	83 ec 0c             	sub    $0xc,%esp
80106344:	50                   	push   %eax
80106345:	e8 33 c3 ff ff       	call   8010267d <namei>
8010634a:	83 c4 10             	add    $0x10,%esp
8010634d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106350:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106354:	75 0f                	jne    80106365 <sys_open+0xa0>
      end_op();
80106356:	e8 16 d4 ff ff       	call   80103771 <end_op>
      return -1;
8010635b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106360:	e9 ff 00 00 00       	jmp    80106464 <sys_open+0x19f>
    }
    ilock(ip);
80106365:	83 ec 0c             	sub    $0xc,%esp
80106368:	ff 75 f4             	pushl  -0xc(%ebp)
8010636b:	e8 a2 b7 ff ff       	call   80101b12 <ilock>
80106370:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106376:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010637a:	66 83 f8 01          	cmp    $0x1,%ax
8010637e:	75 24                	jne    801063a4 <sys_open+0xdf>
80106380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106383:	85 c0                	test   %eax,%eax
80106385:	74 1d                	je     801063a4 <sys_open+0xdf>
      iunlockput(ip);
80106387:	83 ec 0c             	sub    $0xc,%esp
8010638a:	ff 75 f4             	pushl  -0xc(%ebp)
8010638d:	e8 bd b9 ff ff       	call   80101d4f <iunlockput>
80106392:	83 c4 10             	add    $0x10,%esp
      end_op();
80106395:	e8 d7 d3 ff ff       	call   80103771 <end_op>
      return -1;
8010639a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639f:	e9 c0 00 00 00       	jmp    80106464 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063a4:	e8 23 ad ff ff       	call   801010cc <filealloc>
801063a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b0:	74 17                	je     801063c9 <sys_open+0x104>
801063b2:	83 ec 0c             	sub    $0xc,%esp
801063b5:	ff 75 f0             	pushl  -0x10(%ebp)
801063b8:	e8 09 f7 ff ff       	call   80105ac6 <fdalloc>
801063bd:	83 c4 10             	add    $0x10,%esp
801063c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063c7:	79 2e                	jns    801063f7 <sys_open+0x132>
    if(f)
801063c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063cd:	74 0e                	je     801063dd <sys_open+0x118>
      fileclose(f);
801063cf:	83 ec 0c             	sub    $0xc,%esp
801063d2:	ff 75 f0             	pushl  -0x10(%ebp)
801063d5:	e8 b8 ad ff ff       	call   80101192 <fileclose>
801063da:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063dd:	83 ec 0c             	sub    $0xc,%esp
801063e0:	ff 75 f4             	pushl  -0xc(%ebp)
801063e3:	e8 67 b9 ff ff       	call   80101d4f <iunlockput>
801063e8:	83 c4 10             	add    $0x10,%esp
    end_op();
801063eb:	e8 81 d3 ff ff       	call   80103771 <end_op>
    return -1;
801063f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f5:	eb 6d                	jmp    80106464 <sys_open+0x19f>
  }
  iunlock(ip);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	ff 75 f4             	pushl  -0xc(%ebp)
801063fd:	e8 27 b8 ff ff       	call   80101c29 <iunlock>
80106402:	83 c4 10             	add    $0x10,%esp
  end_op();
80106405:	e8 67 d3 ff ff       	call   80103771 <end_op>

  f->type = FD_INODE;
8010640a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106416:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106419:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010641c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106426:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106429:	83 e0 01             	and    $0x1,%eax
8010642c:	85 c0                	test   %eax,%eax
8010642e:	0f 94 c0             	sete   %al
80106431:	89 c2                	mov    %eax,%edx
80106433:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106436:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643c:	83 e0 01             	and    $0x1,%eax
8010643f:	85 c0                	test   %eax,%eax
80106441:	75 0a                	jne    8010644d <sys_open+0x188>
80106443:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106446:	83 e0 02             	and    $0x2,%eax
80106449:	85 c0                	test   %eax,%eax
8010644b:	74 07                	je     80106454 <sys_open+0x18f>
8010644d:	b8 01 00 00 00       	mov    $0x1,%eax
80106452:	eb 05                	jmp    80106459 <sys_open+0x194>
80106454:	b8 00 00 00 00       	mov    $0x0,%eax
80106459:	89 c2                	mov    %eax,%edx
8010645b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106461:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106464:	c9                   	leave  
80106465:	c3                   	ret    

80106466 <sys_mkdir>:

int
sys_mkdir(void)
{
80106466:	f3 0f 1e fb          	endbr32 
8010646a:	55                   	push   %ebp
8010646b:	89 e5                	mov    %esp,%ebp
8010646d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106470:	e8 6c d2 ff ff       	call   801036e1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106475:	83 ec 08             	sub    $0x8,%esp
80106478:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010647b:	50                   	push   %eax
8010647c:	6a 00                	push   $0x0
8010647e:	e8 0e f5 ff ff       	call   80105991 <argstr>
80106483:	83 c4 10             	add    $0x10,%esp
80106486:	85 c0                	test   %eax,%eax
80106488:	78 1b                	js     801064a5 <sys_mkdir+0x3f>
8010648a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648d:	6a 00                	push   $0x0
8010648f:	6a 00                	push   $0x0
80106491:	6a 01                	push   $0x1
80106493:	50                   	push   %eax
80106494:	e8 58 fc ff ff       	call   801060f1 <create>
80106499:	83 c4 10             	add    $0x10,%esp
8010649c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010649f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064a3:	75 0c                	jne    801064b1 <sys_mkdir+0x4b>
    end_op();
801064a5:	e8 c7 d2 ff ff       	call   80103771 <end_op>
    return -1;
801064aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064af:	eb 18                	jmp    801064c9 <sys_mkdir+0x63>
  }
  iunlockput(ip);
801064b1:	83 ec 0c             	sub    $0xc,%esp
801064b4:	ff 75 f4             	pushl  -0xc(%ebp)
801064b7:	e8 93 b8 ff ff       	call   80101d4f <iunlockput>
801064bc:	83 c4 10             	add    $0x10,%esp
  end_op();
801064bf:	e8 ad d2 ff ff       	call   80103771 <end_op>
  return 0;
801064c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c9:	c9                   	leave  
801064ca:	c3                   	ret    

801064cb <sys_mknod>:

int
sys_mknod(void)
{
801064cb:	f3 0f 1e fb          	endbr32 
801064cf:	55                   	push   %ebp
801064d0:	89 e5                	mov    %esp,%ebp
801064d2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064d5:	e8 07 d2 ff ff       	call   801036e1 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064da:	83 ec 08             	sub    $0x8,%esp
801064dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064e0:	50                   	push   %eax
801064e1:	6a 00                	push   $0x0
801064e3:	e8 a9 f4 ff ff       	call   80105991 <argstr>
801064e8:	83 c4 10             	add    $0x10,%esp
801064eb:	85 c0                	test   %eax,%eax
801064ed:	78 4f                	js     8010653e <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064ef:	83 ec 08             	sub    $0x8,%esp
801064f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064f5:	50                   	push   %eax
801064f6:	6a 01                	push   $0x1
801064f8:	e8 f7 f3 ff ff       	call   801058f4 <argint>
801064fd:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106500:	85 c0                	test   %eax,%eax
80106502:	78 3a                	js     8010653e <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106504:	83 ec 08             	sub    $0x8,%esp
80106507:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010650a:	50                   	push   %eax
8010650b:	6a 02                	push   $0x2
8010650d:	e8 e2 f3 ff ff       	call   801058f4 <argint>
80106512:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106515:	85 c0                	test   %eax,%eax
80106517:	78 25                	js     8010653e <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106519:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010651c:	0f bf c8             	movswl %ax,%ecx
8010651f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106522:	0f bf d0             	movswl %ax,%edx
80106525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106528:	51                   	push   %ecx
80106529:	52                   	push   %edx
8010652a:	6a 03                	push   $0x3
8010652c:	50                   	push   %eax
8010652d:	e8 bf fb ff ff       	call   801060f1 <create>
80106532:	83 c4 10             	add    $0x10,%esp
80106535:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010653c:	75 0c                	jne    8010654a <sys_mknod+0x7f>
    end_op();
8010653e:	e8 2e d2 ff ff       	call   80103771 <end_op>
    return -1;
80106543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106548:	eb 18                	jmp    80106562 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010654a:	83 ec 0c             	sub    $0xc,%esp
8010654d:	ff 75 f4             	pushl  -0xc(%ebp)
80106550:	e8 fa b7 ff ff       	call   80101d4f <iunlockput>
80106555:	83 c4 10             	add    $0x10,%esp
  end_op();
80106558:	e8 14 d2 ff ff       	call   80103771 <end_op>
  return 0;
8010655d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106562:	c9                   	leave  
80106563:	c3                   	ret    

80106564 <sys_chdir>:

int
sys_chdir(void)
{
80106564:	f3 0f 1e fb          	endbr32 
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010656e:	e8 2d df ff ff       	call   801044a0 <myproc>
80106573:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106576:	e8 66 d1 ff ff       	call   801036e1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010657b:	83 ec 08             	sub    $0x8,%esp
8010657e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106581:	50                   	push   %eax
80106582:	6a 00                	push   $0x0
80106584:	e8 08 f4 ff ff       	call   80105991 <argstr>
80106589:	83 c4 10             	add    $0x10,%esp
8010658c:	85 c0                	test   %eax,%eax
8010658e:	78 18                	js     801065a8 <sys_chdir+0x44>
80106590:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106593:	83 ec 0c             	sub    $0xc,%esp
80106596:	50                   	push   %eax
80106597:	e8 e1 c0 ff ff       	call   8010267d <namei>
8010659c:	83 c4 10             	add    $0x10,%esp
8010659f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065a6:	75 0c                	jne    801065b4 <sys_chdir+0x50>
    end_op();
801065a8:	e8 c4 d1 ff ff       	call   80103771 <end_op>
    return -1;
801065ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b2:	eb 68                	jmp    8010661c <sys_chdir+0xb8>
  }
  ilock(ip);
801065b4:	83 ec 0c             	sub    $0xc,%esp
801065b7:	ff 75 f0             	pushl  -0x10(%ebp)
801065ba:	e8 53 b5 ff ff       	call   80101b12 <ilock>
801065bf:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065c9:	66 83 f8 01          	cmp    $0x1,%ax
801065cd:	74 1a                	je     801065e9 <sys_chdir+0x85>
    iunlockput(ip);
801065cf:	83 ec 0c             	sub    $0xc,%esp
801065d2:	ff 75 f0             	pushl  -0x10(%ebp)
801065d5:	e8 75 b7 ff ff       	call   80101d4f <iunlockput>
801065da:	83 c4 10             	add    $0x10,%esp
    end_op();
801065dd:	e8 8f d1 ff ff       	call   80103771 <end_op>
    return -1;
801065e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e7:	eb 33                	jmp    8010661c <sys_chdir+0xb8>
  }
  iunlock(ip);
801065e9:	83 ec 0c             	sub    $0xc,%esp
801065ec:	ff 75 f0             	pushl  -0x10(%ebp)
801065ef:	e8 35 b6 ff ff       	call   80101c29 <iunlock>
801065f4:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fa:	8b 40 68             	mov    0x68(%eax),%eax
801065fd:	83 ec 0c             	sub    $0xc,%esp
80106600:	50                   	push   %eax
80106601:	e8 75 b6 ff ff       	call   80101c7b <iput>
80106606:	83 c4 10             	add    $0x10,%esp
  end_op();
80106609:	e8 63 d1 ff ff       	call   80103771 <end_op>
  curproc->cwd = ip;
8010660e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106611:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106614:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106617:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661c:	c9                   	leave  
8010661d:	c3                   	ret    

8010661e <sys_exec>:

int
sys_exec(void)
{
8010661e:	f3 0f 1e fb          	endbr32 
80106622:	55                   	push   %ebp
80106623:	89 e5                	mov    %esp,%ebp
80106625:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010662b:	83 ec 08             	sub    $0x8,%esp
8010662e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106631:	50                   	push   %eax
80106632:	6a 00                	push   $0x0
80106634:	e8 58 f3 ff ff       	call   80105991 <argstr>
80106639:	83 c4 10             	add    $0x10,%esp
8010663c:	85 c0                	test   %eax,%eax
8010663e:	78 18                	js     80106658 <sys_exec+0x3a>
80106640:	83 ec 08             	sub    $0x8,%esp
80106643:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106649:	50                   	push   %eax
8010664a:	6a 01                	push   $0x1
8010664c:	e8 a3 f2 ff ff       	call   801058f4 <argint>
80106651:	83 c4 10             	add    $0x10,%esp
80106654:	85 c0                	test   %eax,%eax
80106656:	79 0a                	jns    80106662 <sys_exec+0x44>
    return -1;
80106658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665d:	e9 c6 00 00 00       	jmp    80106728 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106662:	83 ec 04             	sub    $0x4,%esp
80106665:	68 80 00 00 00       	push   $0x80
8010666a:	6a 00                	push   $0x0
8010666c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106672:	50                   	push   %eax
80106673:	e8 28 ef ff ff       	call   801055a0 <memset>
80106678:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010667b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106685:	83 f8 1f             	cmp    $0x1f,%eax
80106688:	76 0a                	jbe    80106694 <sys_exec+0x76>
      return -1;
8010668a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668f:	e9 94 00 00 00       	jmp    80106728 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106697:	c1 e0 02             	shl    $0x2,%eax
8010669a:	89 c2                	mov    %eax,%edx
8010669c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066a2:	01 c2                	add    %eax,%edx
801066a4:	83 ec 08             	sub    $0x8,%esp
801066a7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066ad:	50                   	push   %eax
801066ae:	52                   	push   %edx
801066af:	e8 95 f1 ff ff       	call   80105849 <fetchint>
801066b4:	83 c4 10             	add    $0x10,%esp
801066b7:	85 c0                	test   %eax,%eax
801066b9:	79 07                	jns    801066c2 <sys_exec+0xa4>
      return -1;
801066bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c0:	eb 66                	jmp    80106728 <sys_exec+0x10a>
    if(uarg == 0){
801066c2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066c8:	85 c0                	test   %eax,%eax
801066ca:	75 27                	jne    801066f3 <sys_exec+0xd5>
      argv[i] = 0;
801066cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066d6:	00 00 00 00 
      break;
801066da:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066de:	83 ec 08             	sub    $0x8,%esp
801066e1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066e7:	52                   	push   %edx
801066e8:	50                   	push   %eax
801066e9:	e8 42 a5 ff ff       	call   80100c30 <exec>
801066ee:	83 c4 10             	add    $0x10,%esp
801066f1:	eb 35                	jmp    80106728 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066f3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066fc:	c1 e2 02             	shl    $0x2,%edx
801066ff:	01 c2                	add    %eax,%edx
80106701:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106707:	83 ec 08             	sub    $0x8,%esp
8010670a:	52                   	push   %edx
8010670b:	50                   	push   %eax
8010670c:	e8 7b f1 ff ff       	call   8010588c <fetchstr>
80106711:	83 c4 10             	add    $0x10,%esp
80106714:	85 c0                	test   %eax,%eax
80106716:	79 07                	jns    8010671f <sys_exec+0x101>
      return -1;
80106718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671d:	eb 09                	jmp    80106728 <sys_exec+0x10a>
  for(i=0;; i++){
8010671f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106723:	e9 5a ff ff ff       	jmp    80106682 <sys_exec+0x64>
}
80106728:	c9                   	leave  
80106729:	c3                   	ret    

8010672a <sys_pipe>:

int
sys_pipe(void)
{
8010672a:	f3 0f 1e fb          	endbr32 
8010672e:	55                   	push   %ebp
8010672f:	89 e5                	mov    %esp,%ebp
80106731:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106734:	83 ec 04             	sub    $0x4,%esp
80106737:	6a 08                	push   $0x8
80106739:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010673c:	50                   	push   %eax
8010673d:	6a 00                	push   $0x0
8010673f:	e8 e1 f1 ff ff       	call   80105925 <argptr>
80106744:	83 c4 10             	add    $0x10,%esp
80106747:	85 c0                	test   %eax,%eax
80106749:	79 0a                	jns    80106755 <sys_pipe+0x2b>
    return -1;
8010674b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106750:	e9 ae 00 00 00       	jmp    80106803 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106755:	83 ec 08             	sub    $0x8,%esp
80106758:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010675b:	50                   	push   %eax
8010675c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010675f:	50                   	push   %eax
80106760:	e8 5c d8 ff ff       	call   80103fc1 <pipealloc>
80106765:	83 c4 10             	add    $0x10,%esp
80106768:	85 c0                	test   %eax,%eax
8010676a:	79 0a                	jns    80106776 <sys_pipe+0x4c>
    return -1;
8010676c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106771:	e9 8d 00 00 00       	jmp    80106803 <sys_pipe+0xd9>
  fd0 = -1;
80106776:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010677d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106780:	83 ec 0c             	sub    $0xc,%esp
80106783:	50                   	push   %eax
80106784:	e8 3d f3 ff ff       	call   80105ac6 <fdalloc>
80106789:	83 c4 10             	add    $0x10,%esp
8010678c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010678f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106793:	78 18                	js     801067ad <sys_pipe+0x83>
80106795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106798:	83 ec 0c             	sub    $0xc,%esp
8010679b:	50                   	push   %eax
8010679c:	e8 25 f3 ff ff       	call   80105ac6 <fdalloc>
801067a1:	83 c4 10             	add    $0x10,%esp
801067a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067ab:	79 3e                	jns    801067eb <sys_pipe+0xc1>
    if(fd0 >= 0)
801067ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067b1:	78 13                	js     801067c6 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801067b3:	e8 e8 dc ff ff       	call   801044a0 <myproc>
801067b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067bb:	83 c2 08             	add    $0x8,%edx
801067be:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067c5:	00 
    fileclose(rf);
801067c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067c9:	83 ec 0c             	sub    $0xc,%esp
801067cc:	50                   	push   %eax
801067cd:	e8 c0 a9 ff ff       	call   80101192 <fileclose>
801067d2:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d8:	83 ec 0c             	sub    $0xc,%esp
801067db:	50                   	push   %eax
801067dc:	e8 b1 a9 ff ff       	call   80101192 <fileclose>
801067e1:	83 c4 10             	add    $0x10,%esp
    return -1;
801067e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e9:	eb 18                	jmp    80106803 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067f1:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067f6:	8d 50 04             	lea    0x4(%eax),%edx
801067f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fc:	89 02                	mov    %eax,(%edx)
  return 0;
801067fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106803:	c9                   	leave  
80106804:	c3                   	ret    

80106805 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106805:	f3 0f 1e fb          	endbr32 
80106809:	55                   	push   %ebp
8010680a:	89 e5                	mov    %esp,%ebp
8010680c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010680f:	e8 ea df ff ff       	call   801047fe <fork>
}
80106814:	c9                   	leave  
80106815:	c3                   	ret    

80106816 <sys_exit>:

int
sys_exit(void)
{
80106816:	f3 0f 1e fb          	endbr32 
8010681a:	55                   	push   %ebp
8010681b:	89 e5                	mov    %esp,%ebp
8010681d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106820:	e8 0a e2 ff ff       	call   80104a2f <exit>
  return 0;  // not reached
80106825:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010682a:	c9                   	leave  
8010682b:	c3                   	ret    

8010682c <sys_wait>:

int
sys_wait(void)
{
8010682c:	f3 0f 1e fb          	endbr32 
80106830:	55                   	push   %ebp
80106831:	89 e5                	mov    %esp,%ebp
80106833:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106836:	e8 1b e3 ff ff       	call   80104b56 <wait>
}
8010683b:	c9                   	leave  
8010683c:	c3                   	ret    

8010683d <sys_kill>:

int
sys_kill(void)
{
8010683d:	f3 0f 1e fb          	endbr32 
80106841:	55                   	push   %ebp
80106842:	89 e5                	mov    %esp,%ebp
80106844:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106847:	83 ec 08             	sub    $0x8,%esp
8010684a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010684d:	50                   	push   %eax
8010684e:	6a 00                	push   $0x0
80106850:	e8 9f f0 ff ff       	call   801058f4 <argint>
80106855:	83 c4 10             	add    $0x10,%esp
80106858:	85 c0                	test   %eax,%eax
8010685a:	79 07                	jns    80106863 <sys_kill+0x26>
    return -1;
8010685c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106861:	eb 0f                	jmp    80106872 <sys_kill+0x35>
  return kill(pid);
80106863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106866:	83 ec 0c             	sub    $0xc,%esp
80106869:	50                   	push   %eax
8010686a:	e8 3f e7 ff ff       	call   80104fae <kill>
8010686f:	83 c4 10             	add    $0x10,%esp
}
80106872:	c9                   	leave  
80106873:	c3                   	ret    

80106874 <sys_getpid>:

int
sys_getpid(void)
{
80106874:	f3 0f 1e fb          	endbr32 
80106878:	55                   	push   %ebp
80106879:	89 e5                	mov    %esp,%ebp
8010687b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010687e:	e8 1d dc ff ff       	call   801044a0 <myproc>
80106883:	8b 40 10             	mov    0x10(%eax),%eax
}
80106886:	c9                   	leave  
80106887:	c3                   	ret    

80106888 <sys_sbrk>:

int
sys_sbrk(void)
{
80106888:	f3 0f 1e fb          	endbr32 
8010688c:	55                   	push   %ebp
8010688d:	89 e5                	mov    %esp,%ebp
8010688f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106892:	83 ec 08             	sub    $0x8,%esp
80106895:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106898:	50                   	push   %eax
80106899:	6a 00                	push   $0x0
8010689b:	e8 54 f0 ff ff       	call   801058f4 <argint>
801068a0:	83 c4 10             	add    $0x10,%esp
801068a3:	85 c0                	test   %eax,%eax
801068a5:	79 07                	jns    801068ae <sys_sbrk+0x26>
    return -1;
801068a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ac:	eb 27                	jmp    801068d5 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801068ae:	e8 ed db ff ff       	call   801044a0 <myproc>
801068b3:	8b 00                	mov    (%eax),%eax
801068b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068bb:	83 ec 0c             	sub    $0xc,%esp
801068be:	50                   	push   %eax
801068bf:	e8 53 de ff ff       	call   80104717 <growproc>
801068c4:	83 c4 10             	add    $0x10,%esp
801068c7:	85 c0                	test   %eax,%eax
801068c9:	79 07                	jns    801068d2 <sys_sbrk+0x4a>
    return -1;
801068cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d0:	eb 03                	jmp    801068d5 <sys_sbrk+0x4d>
  return addr;
801068d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068d5:	c9                   	leave  
801068d6:	c3                   	ret    

801068d7 <sys_sleep>:

int
sys_sleep(void)
{
801068d7:	f3 0f 1e fb          	endbr32 
801068db:	55                   	push   %ebp
801068dc:	89 e5                	mov    %esp,%ebp
801068de:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068e1:	83 ec 08             	sub    $0x8,%esp
801068e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068e7:	50                   	push   %eax
801068e8:	6a 00                	push   $0x0
801068ea:	e8 05 f0 ff ff       	call   801058f4 <argint>
801068ef:	83 c4 10             	add    $0x10,%esp
801068f2:	85 c0                	test   %eax,%eax
801068f4:	79 07                	jns    801068fd <sys_sleep+0x26>
    return -1;
801068f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fb:	eb 76                	jmp    80106973 <sys_sleep+0x9c>
  acquire(&tickslock);
801068fd:	83 ec 0c             	sub    $0xc,%esp
80106900:	68 00 86 11 80       	push   $0x80118600
80106905:	e8 f7 e9 ff ff       	call   80105301 <acquire>
8010690a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010690d:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106915:	eb 38                	jmp    8010694f <sys_sleep+0x78>
    if(myproc()->killed){
80106917:	e8 84 db ff ff       	call   801044a0 <myproc>
8010691c:	8b 40 24             	mov    0x24(%eax),%eax
8010691f:	85 c0                	test   %eax,%eax
80106921:	74 17                	je     8010693a <sys_sleep+0x63>
      release(&tickslock);
80106923:	83 ec 0c             	sub    $0xc,%esp
80106926:	68 00 86 11 80       	push   $0x80118600
8010692b:	e8 43 ea ff ff       	call   80105373 <release>
80106930:	83 c4 10             	add    $0x10,%esp
      return -1;
80106933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106938:	eb 39                	jmp    80106973 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010693a:	83 ec 08             	sub    $0x8,%esp
8010693d:	68 00 86 11 80       	push   $0x80118600
80106942:	68 40 8e 11 80       	push   $0x80118e40
80106947:	e8 35 e5 ff ff       	call   80104e81 <sleep>
8010694c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010694f:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106954:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106957:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010695a:	39 d0                	cmp    %edx,%eax
8010695c:	72 b9                	jb     80106917 <sys_sleep+0x40>
  }
  release(&tickslock);
8010695e:	83 ec 0c             	sub    $0xc,%esp
80106961:	68 00 86 11 80       	push   $0x80118600
80106966:	e8 08 ea ff ff       	call   80105373 <release>
8010696b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010696e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106973:	c9                   	leave  
80106974:	c3                   	ret    

80106975 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106975:	f3 0f 1e fb          	endbr32 
80106979:	55                   	push   %ebp
8010697a:	89 e5                	mov    %esp,%ebp
8010697c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010697f:	83 ec 0c             	sub    $0xc,%esp
80106982:	68 00 86 11 80       	push   $0x80118600
80106987:	e8 75 e9 ff ff       	call   80105301 <acquire>
8010698c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010698f:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106994:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106997:	83 ec 0c             	sub    $0xc,%esp
8010699a:	68 00 86 11 80       	push   $0x80118600
8010699f:	e8 cf e9 ff ff       	call   80105373 <release>
801069a4:	83 c4 10             	add    $0x10,%esp
  return xticks;
801069a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069aa:	c9                   	leave  
801069ab:	c3                   	ret    

801069ac <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
801069ac:	f3 0f 1e fb          	endbr32 
801069b0:	55                   	push   %ebp
801069b1:	89 e5                	mov    %esp,%ebp
801069b3:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
801069b6:	83 ec 08             	sub    $0x8,%esp
801069b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069bc:	50                   	push   %eax
801069bd:	6a 01                	push   $0x1
801069bf:	e8 30 ef ff ff       	call   801058f4 <argint>
801069c4:	83 c4 10             	add    $0x10,%esp
801069c7:	85 c0                	test   %eax,%eax
801069c9:	79 07                	jns    801069d2 <sys_mencrypt+0x26>
    return -1;
801069cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d0:	eb 5e                	jmp    80106a30 <sys_mencrypt+0x84>
  if (len == 0) {
801069d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d5:	85 c0                	test   %eax,%eax
801069d7:	75 07                	jne    801069e0 <sys_mencrypt+0x34>
    return 0;
801069d9:	b8 00 00 00 00       	mov    $0x0,%eax
801069de:	eb 50                	jmp    80106a30 <sys_mencrypt+0x84>
  }
  if (len < 0) {
801069e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e3:	85 c0                	test   %eax,%eax
801069e5:	79 07                	jns    801069ee <sys_mencrypt+0x42>
    return -1;
801069e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ec:	eb 42                	jmp    80106a30 <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
801069ee:	83 ec 04             	sub    $0x4,%esp
801069f1:	6a 01                	push   $0x1
801069f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069f6:	50                   	push   %eax
801069f7:	6a 00                	push   $0x0
801069f9:	e8 27 ef ff ff       	call   80105925 <argptr>
801069fe:	83 c4 10             	add    $0x10,%esp
80106a01:	85 c0                	test   %eax,%eax
80106a03:	79 07                	jns    80106a0c <sys_mencrypt+0x60>
    return -1;
80106a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a0a:	eb 24                	jmp    80106a30 <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
80106a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0f:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106a14:	76 07                	jbe    80106a1d <sys_mencrypt+0x71>
    return -1;
80106a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1b:	eb 13                	jmp    80106a30 <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
80106a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a23:	83 ec 08             	sub    $0x8,%esp
80106a26:	52                   	push   %edx
80106a27:	50                   	push   %eax
80106a28:	e8 45 24 00 00       	call   80108e72 <mencrypt>
80106a2d:	83 c4 10             	add    $0x10,%esp
}
80106a30:	c9                   	leave  
80106a31:	c3                   	ret    

80106a32 <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
80106a32:	f3 0f 1e fb          	endbr32 
80106a36:	55                   	push   %ebp
80106a37:	89 e5                	mov    %esp,%ebp
80106a39:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if((argint(1, &num) < 0)||(argint(2,&wsetOnly)))
80106a3c:	83 ec 08             	sub    $0x8,%esp
80106a3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a42:	50                   	push   %eax
80106a43:	6a 01                	push   $0x1
80106a45:	e8 aa ee ff ff       	call   801058f4 <argint>
80106a4a:	83 c4 10             	add    $0x10,%esp
80106a4d:	85 c0                	test   %eax,%eax
80106a4f:	78 15                	js     80106a66 <sys_getpgtable+0x34>
80106a51:	83 ec 08             	sub    $0x8,%esp
80106a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a57:	50                   	push   %eax
80106a58:	6a 02                	push   $0x2
80106a5a:	e8 95 ee ff ff       	call   801058f4 <argint>
80106a5f:	83 c4 10             	add    $0x10,%esp
80106a62:	85 c0                	test   %eax,%eax
80106a64:	74 07                	je     80106a6d <sys_getpgtable+0x3b>

    return -1;
80106a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6b:	eb 3a                	jmp    80106aa7 <sys_getpgtable+0x75>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a70:	c1 e0 03             	shl    $0x3,%eax
80106a73:	83 ec 04             	sub    $0x4,%esp
80106a76:	50                   	push   %eax
80106a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a7a:	50                   	push   %eax
80106a7b:	6a 00                	push   $0x0
80106a7d:	e8 a3 ee ff ff       	call   80105925 <argptr>
80106a82:	83 c4 10             	add    $0x10,%esp
80106a85:	85 c0                	test   %eax,%eax
80106a87:	79 07                	jns    80106a90 <sys_getpgtable+0x5e>
    return -1;
80106a89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8e:	eb 17                	jmp    80106aa7 <sys_getpgtable+0x75>
  }
  return getpgtable(entries, num, wsetOnly);
80106a90:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a93:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a99:	83 ec 04             	sub    $0x4,%esp
80106a9c:	51                   	push   %ecx
80106a9d:	52                   	push   %edx
80106a9e:	50                   	push   %eax
80106a9f:	e8 1b 25 00 00       	call   80108fbf <getpgtable>
80106aa4:	83 c4 10             	add    $0x10,%esp
}
80106aa7:	c9                   	leave  
80106aa8:	c3                   	ret    

80106aa9 <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
80106aa9:	f3 0f 1e fb          	endbr32 
80106aad:	55                   	push   %ebp
80106aae:	89 e5                	mov    %esp,%ebp
80106ab0:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106ab3:	83 ec 04             	sub    $0x4,%esp
80106ab6:	68 00 10 00 00       	push   $0x1000
80106abb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106abe:	50                   	push   %eax
80106abf:	6a 01                	push   $0x1
80106ac1:	e8 5f ee ff ff       	call   80105925 <argptr>
80106ac6:	83 c4 10             	add    $0x10,%esp
80106ac9:	85 c0                	test   %eax,%eax
80106acb:	79 07                	jns    80106ad4 <sys_dump_rawphymem+0x2b>
    return -1;
80106acd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad2:	eb 2f                	jmp    80106b03 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106ad4:	83 ec 08             	sub    $0x8,%esp
80106ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ada:	50                   	push   %eax
80106adb:	6a 00                	push   $0x0
80106add:	e8 12 ee ff ff       	call   801058f4 <argint>
80106ae2:	83 c4 10             	add    $0x10,%esp
80106ae5:	85 c0                	test   %eax,%eax
80106ae7:	79 07                	jns    80106af0 <sys_dump_rawphymem+0x47>
    return -1;
80106ae9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aee:	eb 13                	jmp    80106b03 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af6:	83 ec 08             	sub    $0x8,%esp
80106af9:	52                   	push   %edx
80106afa:	50                   	push   %eax
80106afb:	e8 23 27 00 00       	call   80109223 <dump_rawphymem>
80106b00:	83 c4 10             	add    $0x10,%esp
80106b03:	c9                   	leave  
80106b04:	c3                   	ret    

80106b05 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b05:	1e                   	push   %ds
  pushl %es
80106b06:	06                   	push   %es
  pushl %fs
80106b07:	0f a0                	push   %fs
  pushl %gs
80106b09:	0f a8                	push   %gs
  pushal
80106b0b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106b0c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b10:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b12:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b14:	54                   	push   %esp
  call trap
80106b15:	e8 df 01 00 00       	call   80106cf9 <trap>
  addl $4, %esp
80106b1a:	83 c4 04             	add    $0x4,%esp

80106b1d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b1d:	61                   	popa   
  popl %gs
80106b1e:	0f a9                	pop    %gs
  popl %fs
80106b20:	0f a1                	pop    %fs
  popl %es
80106b22:	07                   	pop    %es
  popl %ds
80106b23:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b24:	83 c4 08             	add    $0x8,%esp
  iret
80106b27:	cf                   	iret   

80106b28 <lidt>:
{
80106b28:	55                   	push   %ebp
80106b29:	89 e5                	mov    %esp,%ebp
80106b2b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b31:	83 e8 01             	sub    $0x1,%eax
80106b34:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b38:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b42:	c1 e8 10             	shr    $0x10,%eax
80106b45:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b49:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b4c:	0f 01 18             	lidtl  (%eax)
}
80106b4f:	90                   	nop
80106b50:	c9                   	leave  
80106b51:	c3                   	ret    

80106b52 <rcr2>:

static inline uint
rcr2(void)
{
80106b52:	55                   	push   %ebp
80106b53:	89 e5                	mov    %esp,%ebp
80106b55:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b58:	0f 20 d0             	mov    %cr2,%eax
80106b5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b61:	c9                   	leave  
80106b62:	c3                   	ret    

80106b63 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b63:	f3 0f 1e fb          	endbr32 
80106b67:	55                   	push   %ebp
80106b68:	89 e5                	mov    %esp,%ebp
80106b6a:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b74:	e9 c3 00 00 00       	jmp    80106c3c <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7c:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b83:	89 c2                	mov    %eax,%edx
80106b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b88:	66 89 14 c5 40 86 11 	mov    %dx,-0x7fee79c0(,%eax,8)
80106b8f:	80 
80106b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b93:	66 c7 04 c5 42 86 11 	movw   $0x8,-0x7fee79be(,%eax,8)
80106b9a:	80 08 00 
80106b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba0:	0f b6 14 c5 44 86 11 	movzbl -0x7fee79bc(,%eax,8),%edx
80106ba7:	80 
80106ba8:	83 e2 e0             	and    $0xffffffe0,%edx
80106bab:	88 14 c5 44 86 11 80 	mov    %dl,-0x7fee79bc(,%eax,8)
80106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb5:	0f b6 14 c5 44 86 11 	movzbl -0x7fee79bc(,%eax,8),%edx
80106bbc:	80 
80106bbd:	83 e2 1f             	and    $0x1f,%edx
80106bc0:	88 14 c5 44 86 11 80 	mov    %dl,-0x7fee79bc(,%eax,8)
80106bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bca:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106bd1:	80 
80106bd2:	83 e2 f0             	and    $0xfffffff0,%edx
80106bd5:	83 ca 0e             	or     $0xe,%edx
80106bd8:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be2:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106be9:	80 
80106bea:	83 e2 ef             	and    $0xffffffef,%edx
80106bed:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf7:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106bfe:	80 
80106bff:	83 e2 9f             	and    $0xffffff9f,%edx
80106c02:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0c:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106c13:	80 
80106c14:	83 ca 80             	or     $0xffffff80,%edx
80106c17:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c21:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106c28:	c1 e8 10             	shr    $0x10,%eax
80106c2b:	89 c2                	mov    %eax,%edx
80106c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c30:	66 89 14 c5 46 86 11 	mov    %dx,-0x7fee79ba(,%eax,8)
80106c37:	80 
  for(i = 0; i < 256; i++)
80106c38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c3c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c43:	0f 8e 30 ff ff ff    	jle    80106b79 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c49:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c4e:	66 a3 40 88 11 80    	mov    %ax,0x80118840
80106c54:	66 c7 05 42 88 11 80 	movw   $0x8,0x80118842
80106c5b:	08 00 
80106c5d:	0f b6 05 44 88 11 80 	movzbl 0x80118844,%eax
80106c64:	83 e0 e0             	and    $0xffffffe0,%eax
80106c67:	a2 44 88 11 80       	mov    %al,0x80118844
80106c6c:	0f b6 05 44 88 11 80 	movzbl 0x80118844,%eax
80106c73:	83 e0 1f             	and    $0x1f,%eax
80106c76:	a2 44 88 11 80       	mov    %al,0x80118844
80106c7b:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106c82:	83 c8 0f             	or     $0xf,%eax
80106c85:	a2 45 88 11 80       	mov    %al,0x80118845
80106c8a:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106c91:	83 e0 ef             	and    $0xffffffef,%eax
80106c94:	a2 45 88 11 80       	mov    %al,0x80118845
80106c99:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106ca0:	83 c8 60             	or     $0x60,%eax
80106ca3:	a2 45 88 11 80       	mov    %al,0x80118845
80106ca8:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106caf:	83 c8 80             	or     $0xffffff80,%eax
80106cb2:	a2 45 88 11 80       	mov    %al,0x80118845
80106cb7:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106cbc:	c1 e8 10             	shr    $0x10,%eax
80106cbf:	66 a3 46 88 11 80    	mov    %ax,0x80118846

  initlock(&tickslock, "time");
80106cc5:	83 ec 08             	sub    $0x8,%esp
80106cc8:	68 b8 97 10 80       	push   $0x801097b8
80106ccd:	68 00 86 11 80       	push   $0x80118600
80106cd2:	e8 04 e6 ff ff       	call   801052db <initlock>
80106cd7:	83 c4 10             	add    $0x10,%esp
}
80106cda:	90                   	nop
80106cdb:	c9                   	leave  
80106cdc:	c3                   	ret    

80106cdd <idtinit>:

void
idtinit(void)
{
80106cdd:	f3 0f 1e fb          	endbr32 
80106ce1:	55                   	push   %ebp
80106ce2:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106ce4:	68 00 08 00 00       	push   $0x800
80106ce9:	68 40 86 11 80       	push   $0x80118640
80106cee:	e8 35 fe ff ff       	call   80106b28 <lidt>
80106cf3:	83 c4 08             	add    $0x8,%esp
}
80106cf6:	90                   	nop
80106cf7:	c9                   	leave  
80106cf8:	c3                   	ret    

80106cf9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cf9:	f3 0f 1e fb          	endbr32 
80106cfd:	55                   	push   %ebp
80106cfe:	89 e5                	mov    %esp,%ebp
80106d00:	57                   	push   %edi
80106d01:	56                   	push   %esi
80106d02:	53                   	push   %ebx
80106d03:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106d06:	8b 45 08             	mov    0x8(%ebp),%eax
80106d09:	8b 40 30             	mov    0x30(%eax),%eax
80106d0c:	83 f8 40             	cmp    $0x40,%eax
80106d0f:	75 3b                	jne    80106d4c <trap+0x53>
    if(myproc()->killed)
80106d11:	e8 8a d7 ff ff       	call   801044a0 <myproc>
80106d16:	8b 40 24             	mov    0x24(%eax),%eax
80106d19:	85 c0                	test   %eax,%eax
80106d1b:	74 05                	je     80106d22 <trap+0x29>
      exit();
80106d1d:	e8 0d dd ff ff       	call   80104a2f <exit>
    myproc()->tf = tf;
80106d22:	e8 79 d7 ff ff       	call   801044a0 <myproc>
80106d27:	8b 55 08             	mov    0x8(%ebp),%edx
80106d2a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d2d:	e8 9a ec ff ff       	call   801059cc <syscall>
    if(myproc()->killed)
80106d32:	e8 69 d7 ff ff       	call   801044a0 <myproc>
80106d37:	8b 40 24             	mov    0x24(%eax),%eax
80106d3a:	85 c0                	test   %eax,%eax
80106d3c:	0f 84 28 02 00 00    	je     80106f6a <trap+0x271>
      exit();
80106d42:	e8 e8 dc ff ff       	call   80104a2f <exit>
    return;
80106d47:	e9 1e 02 00 00       	jmp    80106f6a <trap+0x271>
  }
  char *addr;
  switch(tf->trapno){
80106d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4f:	8b 40 30             	mov    0x30(%eax),%eax
80106d52:	83 e8 0e             	sub    $0xe,%eax
80106d55:	83 f8 31             	cmp    $0x31,%eax
80106d58:	0f 87 d4 00 00 00    	ja     80106e32 <trap+0x139>
80106d5e:	8b 04 85 60 98 10 80 	mov    -0x7fef67a0(,%eax,4),%eax
80106d65:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d68:	e8 98 d6 ff ff       	call   80104405 <cpuid>
80106d6d:	85 c0                	test   %eax,%eax
80106d6f:	75 3d                	jne    80106dae <trap+0xb5>
      acquire(&tickslock);
80106d71:	83 ec 0c             	sub    $0xc,%esp
80106d74:	68 00 86 11 80       	push   $0x80118600
80106d79:	e8 83 e5 ff ff       	call   80105301 <acquire>
80106d7e:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d81:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106d86:	83 c0 01             	add    $0x1,%eax
80106d89:	a3 40 8e 11 80       	mov    %eax,0x80118e40
      wakeup(&ticks);
80106d8e:	83 ec 0c             	sub    $0xc,%esp
80106d91:	68 40 8e 11 80       	push   $0x80118e40
80106d96:	e8 d8 e1 ff ff       	call   80104f73 <wakeup>
80106d9b:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d9e:	83 ec 0c             	sub    $0xc,%esp
80106da1:	68 00 86 11 80       	push   $0x80118600
80106da6:	e8 c8 e5 ff ff       	call   80105373 <release>
80106dab:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106dae:	e8 e2 c3 ff ff       	call   80103195 <lapiceoi>
    break;
80106db3:	e9 32 01 00 00       	jmp    80106eea <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106db8:	e8 0d bc ff ff       	call   801029ca <ideintr>
    lapiceoi();
80106dbd:	e8 d3 c3 ff ff       	call   80103195 <lapiceoi>
    break;
80106dc2:	e9 23 01 00 00       	jmp    80106eea <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106dc7:	e8 ff c1 ff ff       	call   80102fcb <kbdintr>
    lapiceoi();
80106dcc:	e8 c4 c3 ff ff       	call   80103195 <lapiceoi>
    break;
80106dd1:	e9 14 01 00 00       	jmp    80106eea <trap+0x1f1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106dd6:	e8 71 03 00 00       	call   8010714c <uartintr>
    lapiceoi();
80106ddb:	e8 b5 c3 ff ff       	call   80103195 <lapiceoi>
    break;
80106de0:	e9 05 01 00 00       	jmp    80106eea <trap+0x1f1>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106de5:	8b 45 08             	mov    0x8(%ebp),%eax
80106de8:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106deb:	8b 45 08             	mov    0x8(%ebp),%eax
80106dee:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106df2:	0f b7 d8             	movzwl %ax,%ebx
80106df5:	e8 0b d6 ff ff       	call   80104405 <cpuid>
80106dfa:	56                   	push   %esi
80106dfb:	53                   	push   %ebx
80106dfc:	50                   	push   %eax
80106dfd:	68 c0 97 10 80       	push   $0x801097c0
80106e02:	e8 11 96 ff ff       	call   80100418 <cprintf>
80106e07:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106e0a:	e8 86 c3 ff ff       	call   80103195 <lapiceoi>
    break;
80106e0f:	e9 d6 00 00 00       	jmp    80106eea <trap+0x1f1>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106e14:	e8 39 fd ff ff       	call   80106b52 <rcr2>
80106e19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!mdecrypt(addr)) {
80106e1c:	83 ec 0c             	sub    $0xc,%esp
80106e1f:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e22:	e8 64 1f 00 00       	call   80108d8b <mdecrypt>
80106e27:	83 c4 10             	add    $0x10,%esp
80106e2a:	85 c0                	test   %eax,%eax
80106e2c:	0f 84 b7 00 00 00    	je     80106ee9 <trap+0x1f0>

      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e32:	e8 69 d6 ff ff       	call   801044a0 <myproc>
80106e37:	85 c0                	test   %eax,%eax
80106e39:	74 11                	je     80106e4c <trap+0x153>
80106e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e42:	0f b7 c0             	movzwl %ax,%eax
80106e45:	83 e0 03             	and    $0x3,%eax
80106e48:	85 c0                	test   %eax,%eax
80106e4a:	75 39                	jne    80106e85 <trap+0x18c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e4c:	e8 01 fd ff ff       	call   80106b52 <rcr2>
80106e51:	89 c3                	mov    %eax,%ebx
80106e53:	8b 45 08             	mov    0x8(%ebp),%eax
80106e56:	8b 70 38             	mov    0x38(%eax),%esi
80106e59:	e8 a7 d5 ff ff       	call   80104405 <cpuid>
80106e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80106e61:	8b 52 30             	mov    0x30(%edx),%edx
80106e64:	83 ec 0c             	sub    $0xc,%esp
80106e67:	53                   	push   %ebx
80106e68:	56                   	push   %esi
80106e69:	50                   	push   %eax
80106e6a:	52                   	push   %edx
80106e6b:	68 e4 97 10 80       	push   $0x801097e4
80106e70:	e8 a3 95 ff ff       	call   80100418 <cprintf>
80106e75:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e78:	83 ec 0c             	sub    $0xc,%esp
80106e7b:	68 16 98 10 80       	push   $0x80109816
80106e80:	e8 83 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e85:	e8 c8 fc ff ff       	call   80106b52 <rcr2>
80106e8a:	89 c6                	mov    %eax,%esi
80106e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e8f:	8b 40 38             	mov    0x38(%eax),%eax
80106e92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e95:	e8 6b d5 ff ff       	call   80104405 <cpuid>
80106e9a:	89 c3                	mov    %eax,%ebx
80106e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9f:	8b 48 34             	mov    0x34(%eax),%ecx
80106ea2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea8:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106eab:	e8 f0 d5 ff ff       	call   801044a0 <myproc>
80106eb0:	8d 50 6c             	lea    0x6c(%eax),%edx
80106eb3:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106eb6:	e8 e5 d5 ff ff       	call   801044a0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ebb:	8b 40 10             	mov    0x10(%eax),%eax
80106ebe:	56                   	push   %esi
80106ebf:	ff 75 d4             	pushl  -0x2c(%ebp)
80106ec2:	53                   	push   %ebx
80106ec3:	ff 75 d0             	pushl  -0x30(%ebp)
80106ec6:	57                   	push   %edi
80106ec7:	ff 75 cc             	pushl  -0x34(%ebp)
80106eca:	50                   	push   %eax
80106ecb:	68 1c 98 10 80       	push   $0x8010981c
80106ed0:	e8 43 95 ff ff       	call   80100418 <cprintf>
80106ed5:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ed8:	e8 c3 d5 ff ff       	call   801044a0 <myproc>
80106edd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ee4:	eb 04                	jmp    80106eea <trap+0x1f1>
    break;
80106ee6:	90                   	nop
80106ee7:	eb 01                	jmp    80106eea <trap+0x1f1>
      break;
80106ee9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eea:	e8 b1 d5 ff ff       	call   801044a0 <myproc>
80106eef:	85 c0                	test   %eax,%eax
80106ef1:	74 23                	je     80106f16 <trap+0x21d>
80106ef3:	e8 a8 d5 ff ff       	call   801044a0 <myproc>
80106ef8:	8b 40 24             	mov    0x24(%eax),%eax
80106efb:	85 c0                	test   %eax,%eax
80106efd:	74 17                	je     80106f16 <trap+0x21d>
80106eff:	8b 45 08             	mov    0x8(%ebp),%eax
80106f02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f06:	0f b7 c0             	movzwl %ax,%eax
80106f09:	83 e0 03             	and    $0x3,%eax
80106f0c:	83 f8 03             	cmp    $0x3,%eax
80106f0f:	75 05                	jne    80106f16 <trap+0x21d>
    exit();
80106f11:	e8 19 db ff ff       	call   80104a2f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f16:	e8 85 d5 ff ff       	call   801044a0 <myproc>
80106f1b:	85 c0                	test   %eax,%eax
80106f1d:	74 1d                	je     80106f3c <trap+0x243>
80106f1f:	e8 7c d5 ff ff       	call   801044a0 <myproc>
80106f24:	8b 40 0c             	mov    0xc(%eax),%eax
80106f27:	83 f8 04             	cmp    $0x4,%eax
80106f2a:	75 10                	jne    80106f3c <trap+0x243>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2f:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f32:	83 f8 20             	cmp    $0x20,%eax
80106f35:	75 05                	jne    80106f3c <trap+0x243>
    yield();
80106f37:	e8 bd de ff ff       	call   80104df9 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f3c:	e8 5f d5 ff ff       	call   801044a0 <myproc>
80106f41:	85 c0                	test   %eax,%eax
80106f43:	74 26                	je     80106f6b <trap+0x272>
80106f45:	e8 56 d5 ff ff       	call   801044a0 <myproc>
80106f4a:	8b 40 24             	mov    0x24(%eax),%eax
80106f4d:	85 c0                	test   %eax,%eax
80106f4f:	74 1a                	je     80106f6b <trap+0x272>
80106f51:	8b 45 08             	mov    0x8(%ebp),%eax
80106f54:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f58:	0f b7 c0             	movzwl %ax,%eax
80106f5b:	83 e0 03             	and    $0x3,%eax
80106f5e:	83 f8 03             	cmp    $0x3,%eax
80106f61:	75 08                	jne    80106f6b <trap+0x272>
    exit();
80106f63:	e8 c7 da ff ff       	call   80104a2f <exit>
80106f68:	eb 01                	jmp    80106f6b <trap+0x272>
    return;
80106f6a:	90                   	nop
}
80106f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f6e:	5b                   	pop    %ebx
80106f6f:	5e                   	pop    %esi
80106f70:	5f                   	pop    %edi
80106f71:	5d                   	pop    %ebp
80106f72:	c3                   	ret    

80106f73 <inb>:
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
80106f76:	83 ec 14             	sub    $0x14,%esp
80106f79:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f80:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f84:	89 c2                	mov    %eax,%edx
80106f86:	ec                   	in     (%dx),%al
80106f87:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f8a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f8e:	c9                   	leave  
80106f8f:	c3                   	ret    

80106f90 <outb>:
{
80106f90:	55                   	push   %ebp
80106f91:	89 e5                	mov    %esp,%ebp
80106f93:	83 ec 08             	sub    $0x8,%esp
80106f96:	8b 45 08             	mov    0x8(%ebp),%eax
80106f99:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f9c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106fa0:	89 d0                	mov    %edx,%eax
80106fa2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106fa5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fa9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fad:	ee                   	out    %al,(%dx)
}
80106fae:	90                   	nop
80106faf:	c9                   	leave  
80106fb0:	c3                   	ret    

80106fb1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fb1:	f3 0f 1e fb          	endbr32 
80106fb5:	55                   	push   %ebp
80106fb6:	89 e5                	mov    %esp,%ebp
80106fb8:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fbb:	6a 00                	push   $0x0
80106fbd:	68 fa 03 00 00       	push   $0x3fa
80106fc2:	e8 c9 ff ff ff       	call   80106f90 <outb>
80106fc7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fca:	68 80 00 00 00       	push   $0x80
80106fcf:	68 fb 03 00 00       	push   $0x3fb
80106fd4:	e8 b7 ff ff ff       	call   80106f90 <outb>
80106fd9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fdc:	6a 0c                	push   $0xc
80106fde:	68 f8 03 00 00       	push   $0x3f8
80106fe3:	e8 a8 ff ff ff       	call   80106f90 <outb>
80106fe8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106feb:	6a 00                	push   $0x0
80106fed:	68 f9 03 00 00       	push   $0x3f9
80106ff2:	e8 99 ff ff ff       	call   80106f90 <outb>
80106ff7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ffa:	6a 03                	push   $0x3
80106ffc:	68 fb 03 00 00       	push   $0x3fb
80107001:	e8 8a ff ff ff       	call   80106f90 <outb>
80107006:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107009:	6a 00                	push   $0x0
8010700b:	68 fc 03 00 00       	push   $0x3fc
80107010:	e8 7b ff ff ff       	call   80106f90 <outb>
80107015:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107018:	6a 01                	push   $0x1
8010701a:	68 f9 03 00 00       	push   $0x3f9
8010701f:	e8 6c ff ff ff       	call   80106f90 <outb>
80107024:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107027:	68 fd 03 00 00       	push   $0x3fd
8010702c:	e8 42 ff ff ff       	call   80106f73 <inb>
80107031:	83 c4 04             	add    $0x4,%esp
80107034:	3c ff                	cmp    $0xff,%al
80107036:	74 61                	je     80107099 <uartinit+0xe8>
    return;
  uart = 1;
80107038:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
8010703f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107042:	68 fa 03 00 00       	push   $0x3fa
80107047:	e8 27 ff ff ff       	call   80106f73 <inb>
8010704c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010704f:	68 f8 03 00 00       	push   $0x3f8
80107054:	e8 1a ff ff ff       	call   80106f73 <inb>
80107059:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010705c:	83 ec 08             	sub    $0x8,%esp
8010705f:	6a 00                	push   $0x0
80107061:	6a 04                	push   $0x4
80107063:	e8 14 bc ff ff       	call   80102c7c <ioapicenable>
80107068:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010706b:	c7 45 f4 28 99 10 80 	movl   $0x80109928,-0xc(%ebp)
80107072:	eb 19                	jmp    8010708d <uartinit+0xdc>
    uartputc(*p);
80107074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107077:	0f b6 00             	movzbl (%eax),%eax
8010707a:	0f be c0             	movsbl %al,%eax
8010707d:	83 ec 0c             	sub    $0xc,%esp
80107080:	50                   	push   %eax
80107081:	e8 16 00 00 00       	call   8010709c <uartputc>
80107086:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107089:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010708d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107090:	0f b6 00             	movzbl (%eax),%eax
80107093:	84 c0                	test   %al,%al
80107095:	75 dd                	jne    80107074 <uartinit+0xc3>
80107097:	eb 01                	jmp    8010709a <uartinit+0xe9>
    return;
80107099:	90                   	nop
}
8010709a:	c9                   	leave  
8010709b:	c3                   	ret    

8010709c <uartputc>:

void
uartputc(int c)
{
8010709c:	f3 0f 1e fb          	endbr32 
801070a0:	55                   	push   %ebp
801070a1:	89 e5                	mov    %esp,%ebp
801070a3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801070a6:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070ab:	85 c0                	test   %eax,%eax
801070ad:	74 53                	je     80107102 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070b6:	eb 11                	jmp    801070c9 <uartputc+0x2d>
    microdelay(10);
801070b8:	83 ec 0c             	sub    $0xc,%esp
801070bb:	6a 0a                	push   $0xa
801070bd:	e8 f2 c0 ff ff       	call   801031b4 <microdelay>
801070c2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070c9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070cd:	7f 1a                	jg     801070e9 <uartputc+0x4d>
801070cf:	83 ec 0c             	sub    $0xc,%esp
801070d2:	68 fd 03 00 00       	push   $0x3fd
801070d7:	e8 97 fe ff ff       	call   80106f73 <inb>
801070dc:	83 c4 10             	add    $0x10,%esp
801070df:	0f b6 c0             	movzbl %al,%eax
801070e2:	83 e0 20             	and    $0x20,%eax
801070e5:	85 c0                	test   %eax,%eax
801070e7:	74 cf                	je     801070b8 <uartputc+0x1c>
  outb(COM1+0, c);
801070e9:	8b 45 08             	mov    0x8(%ebp),%eax
801070ec:	0f b6 c0             	movzbl %al,%eax
801070ef:	83 ec 08             	sub    $0x8,%esp
801070f2:	50                   	push   %eax
801070f3:	68 f8 03 00 00       	push   $0x3f8
801070f8:	e8 93 fe ff ff       	call   80106f90 <outb>
801070fd:	83 c4 10             	add    $0x10,%esp
80107100:	eb 01                	jmp    80107103 <uartputc+0x67>
    return;
80107102:	90                   	nop
}
80107103:	c9                   	leave  
80107104:	c3                   	ret    

80107105 <uartgetc>:

static int
uartgetc(void)
{
80107105:	f3 0f 1e fb          	endbr32 
80107109:	55                   	push   %ebp
8010710a:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010710c:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80107111:	85 c0                	test   %eax,%eax
80107113:	75 07                	jne    8010711c <uartgetc+0x17>
    return -1;
80107115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010711a:	eb 2e                	jmp    8010714a <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
8010711c:	68 fd 03 00 00       	push   $0x3fd
80107121:	e8 4d fe ff ff       	call   80106f73 <inb>
80107126:	83 c4 04             	add    $0x4,%esp
80107129:	0f b6 c0             	movzbl %al,%eax
8010712c:	83 e0 01             	and    $0x1,%eax
8010712f:	85 c0                	test   %eax,%eax
80107131:	75 07                	jne    8010713a <uartgetc+0x35>
    return -1;
80107133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107138:	eb 10                	jmp    8010714a <uartgetc+0x45>
  return inb(COM1+0);
8010713a:	68 f8 03 00 00       	push   $0x3f8
8010713f:	e8 2f fe ff ff       	call   80106f73 <inb>
80107144:	83 c4 04             	add    $0x4,%esp
80107147:	0f b6 c0             	movzbl %al,%eax
}
8010714a:	c9                   	leave  
8010714b:	c3                   	ret    

8010714c <uartintr>:

void
uartintr(void)
{
8010714c:	f3 0f 1e fb          	endbr32 
80107150:	55                   	push   %ebp
80107151:	89 e5                	mov    %esp,%ebp
80107153:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107156:	83 ec 0c             	sub    $0xc,%esp
80107159:	68 05 71 10 80       	push   $0x80107105
8010715e:	e8 45 97 ff ff       	call   801008a8 <consoleintr>
80107163:	83 c4 10             	add    $0x10,%esp
}
80107166:	90                   	nop
80107167:	c9                   	leave  
80107168:	c3                   	ret    

80107169 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $0
8010716b:	6a 00                	push   $0x0
  jmp alltraps
8010716d:	e9 93 f9 ff ff       	jmp    80106b05 <alltraps>

80107172 <vector1>:
.globl vector1
vector1:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $1
80107174:	6a 01                	push   $0x1
  jmp alltraps
80107176:	e9 8a f9 ff ff       	jmp    80106b05 <alltraps>

8010717b <vector2>:
.globl vector2
vector2:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $2
8010717d:	6a 02                	push   $0x2
  jmp alltraps
8010717f:	e9 81 f9 ff ff       	jmp    80106b05 <alltraps>

80107184 <vector3>:
.globl vector3
vector3:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $3
80107186:	6a 03                	push   $0x3
  jmp alltraps
80107188:	e9 78 f9 ff ff       	jmp    80106b05 <alltraps>

8010718d <vector4>:
.globl vector4
vector4:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $4
8010718f:	6a 04                	push   $0x4
  jmp alltraps
80107191:	e9 6f f9 ff ff       	jmp    80106b05 <alltraps>

80107196 <vector5>:
.globl vector5
vector5:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $5
80107198:	6a 05                	push   $0x5
  jmp alltraps
8010719a:	e9 66 f9 ff ff       	jmp    80106b05 <alltraps>

8010719f <vector6>:
.globl vector6
vector6:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $6
801071a1:	6a 06                	push   $0x6
  jmp alltraps
801071a3:	e9 5d f9 ff ff       	jmp    80106b05 <alltraps>

801071a8 <vector7>:
.globl vector7
vector7:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $7
801071aa:	6a 07                	push   $0x7
  jmp alltraps
801071ac:	e9 54 f9 ff ff       	jmp    80106b05 <alltraps>

801071b1 <vector8>:
.globl vector8
vector8:
  pushl $8
801071b1:	6a 08                	push   $0x8
  jmp alltraps
801071b3:	e9 4d f9 ff ff       	jmp    80106b05 <alltraps>

801071b8 <vector9>:
.globl vector9
vector9:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $9
801071ba:	6a 09                	push   $0x9
  jmp alltraps
801071bc:	e9 44 f9 ff ff       	jmp    80106b05 <alltraps>

801071c1 <vector10>:
.globl vector10
vector10:
  pushl $10
801071c1:	6a 0a                	push   $0xa
  jmp alltraps
801071c3:	e9 3d f9 ff ff       	jmp    80106b05 <alltraps>

801071c8 <vector11>:
.globl vector11
vector11:
  pushl $11
801071c8:	6a 0b                	push   $0xb
  jmp alltraps
801071ca:	e9 36 f9 ff ff       	jmp    80106b05 <alltraps>

801071cf <vector12>:
.globl vector12
vector12:
  pushl $12
801071cf:	6a 0c                	push   $0xc
  jmp alltraps
801071d1:	e9 2f f9 ff ff       	jmp    80106b05 <alltraps>

801071d6 <vector13>:
.globl vector13
vector13:
  pushl $13
801071d6:	6a 0d                	push   $0xd
  jmp alltraps
801071d8:	e9 28 f9 ff ff       	jmp    80106b05 <alltraps>

801071dd <vector14>:
.globl vector14
vector14:
  pushl $14
801071dd:	6a 0e                	push   $0xe
  jmp alltraps
801071df:	e9 21 f9 ff ff       	jmp    80106b05 <alltraps>

801071e4 <vector15>:
.globl vector15
vector15:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $15
801071e6:	6a 0f                	push   $0xf
  jmp alltraps
801071e8:	e9 18 f9 ff ff       	jmp    80106b05 <alltraps>

801071ed <vector16>:
.globl vector16
vector16:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $16
801071ef:	6a 10                	push   $0x10
  jmp alltraps
801071f1:	e9 0f f9 ff ff       	jmp    80106b05 <alltraps>

801071f6 <vector17>:
.globl vector17
vector17:
  pushl $17
801071f6:	6a 11                	push   $0x11
  jmp alltraps
801071f8:	e9 08 f9 ff ff       	jmp    80106b05 <alltraps>

801071fd <vector18>:
.globl vector18
vector18:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $18
801071ff:	6a 12                	push   $0x12
  jmp alltraps
80107201:	e9 ff f8 ff ff       	jmp    80106b05 <alltraps>

80107206 <vector19>:
.globl vector19
vector19:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $19
80107208:	6a 13                	push   $0x13
  jmp alltraps
8010720a:	e9 f6 f8 ff ff       	jmp    80106b05 <alltraps>

8010720f <vector20>:
.globl vector20
vector20:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $20
80107211:	6a 14                	push   $0x14
  jmp alltraps
80107213:	e9 ed f8 ff ff       	jmp    80106b05 <alltraps>

80107218 <vector21>:
.globl vector21
vector21:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $21
8010721a:	6a 15                	push   $0x15
  jmp alltraps
8010721c:	e9 e4 f8 ff ff       	jmp    80106b05 <alltraps>

80107221 <vector22>:
.globl vector22
vector22:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $22
80107223:	6a 16                	push   $0x16
  jmp alltraps
80107225:	e9 db f8 ff ff       	jmp    80106b05 <alltraps>

8010722a <vector23>:
.globl vector23
vector23:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $23
8010722c:	6a 17                	push   $0x17
  jmp alltraps
8010722e:	e9 d2 f8 ff ff       	jmp    80106b05 <alltraps>

80107233 <vector24>:
.globl vector24
vector24:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $24
80107235:	6a 18                	push   $0x18
  jmp alltraps
80107237:	e9 c9 f8 ff ff       	jmp    80106b05 <alltraps>

8010723c <vector25>:
.globl vector25
vector25:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $25
8010723e:	6a 19                	push   $0x19
  jmp alltraps
80107240:	e9 c0 f8 ff ff       	jmp    80106b05 <alltraps>

80107245 <vector26>:
.globl vector26
vector26:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $26
80107247:	6a 1a                	push   $0x1a
  jmp alltraps
80107249:	e9 b7 f8 ff ff       	jmp    80106b05 <alltraps>

8010724e <vector27>:
.globl vector27
vector27:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $27
80107250:	6a 1b                	push   $0x1b
  jmp alltraps
80107252:	e9 ae f8 ff ff       	jmp    80106b05 <alltraps>

80107257 <vector28>:
.globl vector28
vector28:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $28
80107259:	6a 1c                	push   $0x1c
  jmp alltraps
8010725b:	e9 a5 f8 ff ff       	jmp    80106b05 <alltraps>

80107260 <vector29>:
.globl vector29
vector29:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $29
80107262:	6a 1d                	push   $0x1d
  jmp alltraps
80107264:	e9 9c f8 ff ff       	jmp    80106b05 <alltraps>

80107269 <vector30>:
.globl vector30
vector30:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $30
8010726b:	6a 1e                	push   $0x1e
  jmp alltraps
8010726d:	e9 93 f8 ff ff       	jmp    80106b05 <alltraps>

80107272 <vector31>:
.globl vector31
vector31:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $31
80107274:	6a 1f                	push   $0x1f
  jmp alltraps
80107276:	e9 8a f8 ff ff       	jmp    80106b05 <alltraps>

8010727b <vector32>:
.globl vector32
vector32:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $32
8010727d:	6a 20                	push   $0x20
  jmp alltraps
8010727f:	e9 81 f8 ff ff       	jmp    80106b05 <alltraps>

80107284 <vector33>:
.globl vector33
vector33:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $33
80107286:	6a 21                	push   $0x21
  jmp alltraps
80107288:	e9 78 f8 ff ff       	jmp    80106b05 <alltraps>

8010728d <vector34>:
.globl vector34
vector34:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $34
8010728f:	6a 22                	push   $0x22
  jmp alltraps
80107291:	e9 6f f8 ff ff       	jmp    80106b05 <alltraps>

80107296 <vector35>:
.globl vector35
vector35:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $35
80107298:	6a 23                	push   $0x23
  jmp alltraps
8010729a:	e9 66 f8 ff ff       	jmp    80106b05 <alltraps>

8010729f <vector36>:
.globl vector36
vector36:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $36
801072a1:	6a 24                	push   $0x24
  jmp alltraps
801072a3:	e9 5d f8 ff ff       	jmp    80106b05 <alltraps>

801072a8 <vector37>:
.globl vector37
vector37:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $37
801072aa:	6a 25                	push   $0x25
  jmp alltraps
801072ac:	e9 54 f8 ff ff       	jmp    80106b05 <alltraps>

801072b1 <vector38>:
.globl vector38
vector38:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $38
801072b3:	6a 26                	push   $0x26
  jmp alltraps
801072b5:	e9 4b f8 ff ff       	jmp    80106b05 <alltraps>

801072ba <vector39>:
.globl vector39
vector39:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $39
801072bc:	6a 27                	push   $0x27
  jmp alltraps
801072be:	e9 42 f8 ff ff       	jmp    80106b05 <alltraps>

801072c3 <vector40>:
.globl vector40
vector40:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $40
801072c5:	6a 28                	push   $0x28
  jmp alltraps
801072c7:	e9 39 f8 ff ff       	jmp    80106b05 <alltraps>

801072cc <vector41>:
.globl vector41
vector41:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $41
801072ce:	6a 29                	push   $0x29
  jmp alltraps
801072d0:	e9 30 f8 ff ff       	jmp    80106b05 <alltraps>

801072d5 <vector42>:
.globl vector42
vector42:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $42
801072d7:	6a 2a                	push   $0x2a
  jmp alltraps
801072d9:	e9 27 f8 ff ff       	jmp    80106b05 <alltraps>

801072de <vector43>:
.globl vector43
vector43:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $43
801072e0:	6a 2b                	push   $0x2b
  jmp alltraps
801072e2:	e9 1e f8 ff ff       	jmp    80106b05 <alltraps>

801072e7 <vector44>:
.globl vector44
vector44:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $44
801072e9:	6a 2c                	push   $0x2c
  jmp alltraps
801072eb:	e9 15 f8 ff ff       	jmp    80106b05 <alltraps>

801072f0 <vector45>:
.globl vector45
vector45:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $45
801072f2:	6a 2d                	push   $0x2d
  jmp alltraps
801072f4:	e9 0c f8 ff ff       	jmp    80106b05 <alltraps>

801072f9 <vector46>:
.globl vector46
vector46:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $46
801072fb:	6a 2e                	push   $0x2e
  jmp alltraps
801072fd:	e9 03 f8 ff ff       	jmp    80106b05 <alltraps>

80107302 <vector47>:
.globl vector47
vector47:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $47
80107304:	6a 2f                	push   $0x2f
  jmp alltraps
80107306:	e9 fa f7 ff ff       	jmp    80106b05 <alltraps>

8010730b <vector48>:
.globl vector48
vector48:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $48
8010730d:	6a 30                	push   $0x30
  jmp alltraps
8010730f:	e9 f1 f7 ff ff       	jmp    80106b05 <alltraps>

80107314 <vector49>:
.globl vector49
vector49:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $49
80107316:	6a 31                	push   $0x31
  jmp alltraps
80107318:	e9 e8 f7 ff ff       	jmp    80106b05 <alltraps>

8010731d <vector50>:
.globl vector50
vector50:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $50
8010731f:	6a 32                	push   $0x32
  jmp alltraps
80107321:	e9 df f7 ff ff       	jmp    80106b05 <alltraps>

80107326 <vector51>:
.globl vector51
vector51:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $51
80107328:	6a 33                	push   $0x33
  jmp alltraps
8010732a:	e9 d6 f7 ff ff       	jmp    80106b05 <alltraps>

8010732f <vector52>:
.globl vector52
vector52:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $52
80107331:	6a 34                	push   $0x34
  jmp alltraps
80107333:	e9 cd f7 ff ff       	jmp    80106b05 <alltraps>

80107338 <vector53>:
.globl vector53
vector53:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $53
8010733a:	6a 35                	push   $0x35
  jmp alltraps
8010733c:	e9 c4 f7 ff ff       	jmp    80106b05 <alltraps>

80107341 <vector54>:
.globl vector54
vector54:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $54
80107343:	6a 36                	push   $0x36
  jmp alltraps
80107345:	e9 bb f7 ff ff       	jmp    80106b05 <alltraps>

8010734a <vector55>:
.globl vector55
vector55:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $55
8010734c:	6a 37                	push   $0x37
  jmp alltraps
8010734e:	e9 b2 f7 ff ff       	jmp    80106b05 <alltraps>

80107353 <vector56>:
.globl vector56
vector56:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $56
80107355:	6a 38                	push   $0x38
  jmp alltraps
80107357:	e9 a9 f7 ff ff       	jmp    80106b05 <alltraps>

8010735c <vector57>:
.globl vector57
vector57:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $57
8010735e:	6a 39                	push   $0x39
  jmp alltraps
80107360:	e9 a0 f7 ff ff       	jmp    80106b05 <alltraps>

80107365 <vector58>:
.globl vector58
vector58:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $58
80107367:	6a 3a                	push   $0x3a
  jmp alltraps
80107369:	e9 97 f7 ff ff       	jmp    80106b05 <alltraps>

8010736e <vector59>:
.globl vector59
vector59:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $59
80107370:	6a 3b                	push   $0x3b
  jmp alltraps
80107372:	e9 8e f7 ff ff       	jmp    80106b05 <alltraps>

80107377 <vector60>:
.globl vector60
vector60:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $60
80107379:	6a 3c                	push   $0x3c
  jmp alltraps
8010737b:	e9 85 f7 ff ff       	jmp    80106b05 <alltraps>

80107380 <vector61>:
.globl vector61
vector61:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $61
80107382:	6a 3d                	push   $0x3d
  jmp alltraps
80107384:	e9 7c f7 ff ff       	jmp    80106b05 <alltraps>

80107389 <vector62>:
.globl vector62
vector62:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $62
8010738b:	6a 3e                	push   $0x3e
  jmp alltraps
8010738d:	e9 73 f7 ff ff       	jmp    80106b05 <alltraps>

80107392 <vector63>:
.globl vector63
vector63:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $63
80107394:	6a 3f                	push   $0x3f
  jmp alltraps
80107396:	e9 6a f7 ff ff       	jmp    80106b05 <alltraps>

8010739b <vector64>:
.globl vector64
vector64:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $64
8010739d:	6a 40                	push   $0x40
  jmp alltraps
8010739f:	e9 61 f7 ff ff       	jmp    80106b05 <alltraps>

801073a4 <vector65>:
.globl vector65
vector65:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $65
801073a6:	6a 41                	push   $0x41
  jmp alltraps
801073a8:	e9 58 f7 ff ff       	jmp    80106b05 <alltraps>

801073ad <vector66>:
.globl vector66
vector66:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $66
801073af:	6a 42                	push   $0x42
  jmp alltraps
801073b1:	e9 4f f7 ff ff       	jmp    80106b05 <alltraps>

801073b6 <vector67>:
.globl vector67
vector67:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $67
801073b8:	6a 43                	push   $0x43
  jmp alltraps
801073ba:	e9 46 f7 ff ff       	jmp    80106b05 <alltraps>

801073bf <vector68>:
.globl vector68
vector68:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $68
801073c1:	6a 44                	push   $0x44
  jmp alltraps
801073c3:	e9 3d f7 ff ff       	jmp    80106b05 <alltraps>

801073c8 <vector69>:
.globl vector69
vector69:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $69
801073ca:	6a 45                	push   $0x45
  jmp alltraps
801073cc:	e9 34 f7 ff ff       	jmp    80106b05 <alltraps>

801073d1 <vector70>:
.globl vector70
vector70:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $70
801073d3:	6a 46                	push   $0x46
  jmp alltraps
801073d5:	e9 2b f7 ff ff       	jmp    80106b05 <alltraps>

801073da <vector71>:
.globl vector71
vector71:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $71
801073dc:	6a 47                	push   $0x47
  jmp alltraps
801073de:	e9 22 f7 ff ff       	jmp    80106b05 <alltraps>

801073e3 <vector72>:
.globl vector72
vector72:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $72
801073e5:	6a 48                	push   $0x48
  jmp alltraps
801073e7:	e9 19 f7 ff ff       	jmp    80106b05 <alltraps>

801073ec <vector73>:
.globl vector73
vector73:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $73
801073ee:	6a 49                	push   $0x49
  jmp alltraps
801073f0:	e9 10 f7 ff ff       	jmp    80106b05 <alltraps>

801073f5 <vector74>:
.globl vector74
vector74:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $74
801073f7:	6a 4a                	push   $0x4a
  jmp alltraps
801073f9:	e9 07 f7 ff ff       	jmp    80106b05 <alltraps>

801073fe <vector75>:
.globl vector75
vector75:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $75
80107400:	6a 4b                	push   $0x4b
  jmp alltraps
80107402:	e9 fe f6 ff ff       	jmp    80106b05 <alltraps>

80107407 <vector76>:
.globl vector76
vector76:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $76
80107409:	6a 4c                	push   $0x4c
  jmp alltraps
8010740b:	e9 f5 f6 ff ff       	jmp    80106b05 <alltraps>

80107410 <vector77>:
.globl vector77
vector77:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $77
80107412:	6a 4d                	push   $0x4d
  jmp alltraps
80107414:	e9 ec f6 ff ff       	jmp    80106b05 <alltraps>

80107419 <vector78>:
.globl vector78
vector78:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $78
8010741b:	6a 4e                	push   $0x4e
  jmp alltraps
8010741d:	e9 e3 f6 ff ff       	jmp    80106b05 <alltraps>

80107422 <vector79>:
.globl vector79
vector79:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $79
80107424:	6a 4f                	push   $0x4f
  jmp alltraps
80107426:	e9 da f6 ff ff       	jmp    80106b05 <alltraps>

8010742b <vector80>:
.globl vector80
vector80:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $80
8010742d:	6a 50                	push   $0x50
  jmp alltraps
8010742f:	e9 d1 f6 ff ff       	jmp    80106b05 <alltraps>

80107434 <vector81>:
.globl vector81
vector81:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $81
80107436:	6a 51                	push   $0x51
  jmp alltraps
80107438:	e9 c8 f6 ff ff       	jmp    80106b05 <alltraps>

8010743d <vector82>:
.globl vector82
vector82:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $82
8010743f:	6a 52                	push   $0x52
  jmp alltraps
80107441:	e9 bf f6 ff ff       	jmp    80106b05 <alltraps>

80107446 <vector83>:
.globl vector83
vector83:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $83
80107448:	6a 53                	push   $0x53
  jmp alltraps
8010744a:	e9 b6 f6 ff ff       	jmp    80106b05 <alltraps>

8010744f <vector84>:
.globl vector84
vector84:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $84
80107451:	6a 54                	push   $0x54
  jmp alltraps
80107453:	e9 ad f6 ff ff       	jmp    80106b05 <alltraps>

80107458 <vector85>:
.globl vector85
vector85:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $85
8010745a:	6a 55                	push   $0x55
  jmp alltraps
8010745c:	e9 a4 f6 ff ff       	jmp    80106b05 <alltraps>

80107461 <vector86>:
.globl vector86
vector86:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $86
80107463:	6a 56                	push   $0x56
  jmp alltraps
80107465:	e9 9b f6 ff ff       	jmp    80106b05 <alltraps>

8010746a <vector87>:
.globl vector87
vector87:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $87
8010746c:	6a 57                	push   $0x57
  jmp alltraps
8010746e:	e9 92 f6 ff ff       	jmp    80106b05 <alltraps>

80107473 <vector88>:
.globl vector88
vector88:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $88
80107475:	6a 58                	push   $0x58
  jmp alltraps
80107477:	e9 89 f6 ff ff       	jmp    80106b05 <alltraps>

8010747c <vector89>:
.globl vector89
vector89:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $89
8010747e:	6a 59                	push   $0x59
  jmp alltraps
80107480:	e9 80 f6 ff ff       	jmp    80106b05 <alltraps>

80107485 <vector90>:
.globl vector90
vector90:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $90
80107487:	6a 5a                	push   $0x5a
  jmp alltraps
80107489:	e9 77 f6 ff ff       	jmp    80106b05 <alltraps>

8010748e <vector91>:
.globl vector91
vector91:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $91
80107490:	6a 5b                	push   $0x5b
  jmp alltraps
80107492:	e9 6e f6 ff ff       	jmp    80106b05 <alltraps>

80107497 <vector92>:
.globl vector92
vector92:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $92
80107499:	6a 5c                	push   $0x5c
  jmp alltraps
8010749b:	e9 65 f6 ff ff       	jmp    80106b05 <alltraps>

801074a0 <vector93>:
.globl vector93
vector93:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $93
801074a2:	6a 5d                	push   $0x5d
  jmp alltraps
801074a4:	e9 5c f6 ff ff       	jmp    80106b05 <alltraps>

801074a9 <vector94>:
.globl vector94
vector94:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $94
801074ab:	6a 5e                	push   $0x5e
  jmp alltraps
801074ad:	e9 53 f6 ff ff       	jmp    80106b05 <alltraps>

801074b2 <vector95>:
.globl vector95
vector95:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $95
801074b4:	6a 5f                	push   $0x5f
  jmp alltraps
801074b6:	e9 4a f6 ff ff       	jmp    80106b05 <alltraps>

801074bb <vector96>:
.globl vector96
vector96:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $96
801074bd:	6a 60                	push   $0x60
  jmp alltraps
801074bf:	e9 41 f6 ff ff       	jmp    80106b05 <alltraps>

801074c4 <vector97>:
.globl vector97
vector97:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $97
801074c6:	6a 61                	push   $0x61
  jmp alltraps
801074c8:	e9 38 f6 ff ff       	jmp    80106b05 <alltraps>

801074cd <vector98>:
.globl vector98
vector98:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $98
801074cf:	6a 62                	push   $0x62
  jmp alltraps
801074d1:	e9 2f f6 ff ff       	jmp    80106b05 <alltraps>

801074d6 <vector99>:
.globl vector99
vector99:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $99
801074d8:	6a 63                	push   $0x63
  jmp alltraps
801074da:	e9 26 f6 ff ff       	jmp    80106b05 <alltraps>

801074df <vector100>:
.globl vector100
vector100:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $100
801074e1:	6a 64                	push   $0x64
  jmp alltraps
801074e3:	e9 1d f6 ff ff       	jmp    80106b05 <alltraps>

801074e8 <vector101>:
.globl vector101
vector101:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $101
801074ea:	6a 65                	push   $0x65
  jmp alltraps
801074ec:	e9 14 f6 ff ff       	jmp    80106b05 <alltraps>

801074f1 <vector102>:
.globl vector102
vector102:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $102
801074f3:	6a 66                	push   $0x66
  jmp alltraps
801074f5:	e9 0b f6 ff ff       	jmp    80106b05 <alltraps>

801074fa <vector103>:
.globl vector103
vector103:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $103
801074fc:	6a 67                	push   $0x67
  jmp alltraps
801074fe:	e9 02 f6 ff ff       	jmp    80106b05 <alltraps>

80107503 <vector104>:
.globl vector104
vector104:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $104
80107505:	6a 68                	push   $0x68
  jmp alltraps
80107507:	e9 f9 f5 ff ff       	jmp    80106b05 <alltraps>

8010750c <vector105>:
.globl vector105
vector105:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $105
8010750e:	6a 69                	push   $0x69
  jmp alltraps
80107510:	e9 f0 f5 ff ff       	jmp    80106b05 <alltraps>

80107515 <vector106>:
.globl vector106
vector106:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $106
80107517:	6a 6a                	push   $0x6a
  jmp alltraps
80107519:	e9 e7 f5 ff ff       	jmp    80106b05 <alltraps>

8010751e <vector107>:
.globl vector107
vector107:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $107
80107520:	6a 6b                	push   $0x6b
  jmp alltraps
80107522:	e9 de f5 ff ff       	jmp    80106b05 <alltraps>

80107527 <vector108>:
.globl vector108
vector108:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $108
80107529:	6a 6c                	push   $0x6c
  jmp alltraps
8010752b:	e9 d5 f5 ff ff       	jmp    80106b05 <alltraps>

80107530 <vector109>:
.globl vector109
vector109:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $109
80107532:	6a 6d                	push   $0x6d
  jmp alltraps
80107534:	e9 cc f5 ff ff       	jmp    80106b05 <alltraps>

80107539 <vector110>:
.globl vector110
vector110:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $110
8010753b:	6a 6e                	push   $0x6e
  jmp alltraps
8010753d:	e9 c3 f5 ff ff       	jmp    80106b05 <alltraps>

80107542 <vector111>:
.globl vector111
vector111:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $111
80107544:	6a 6f                	push   $0x6f
  jmp alltraps
80107546:	e9 ba f5 ff ff       	jmp    80106b05 <alltraps>

8010754b <vector112>:
.globl vector112
vector112:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $112
8010754d:	6a 70                	push   $0x70
  jmp alltraps
8010754f:	e9 b1 f5 ff ff       	jmp    80106b05 <alltraps>

80107554 <vector113>:
.globl vector113
vector113:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $113
80107556:	6a 71                	push   $0x71
  jmp alltraps
80107558:	e9 a8 f5 ff ff       	jmp    80106b05 <alltraps>

8010755d <vector114>:
.globl vector114
vector114:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $114
8010755f:	6a 72                	push   $0x72
  jmp alltraps
80107561:	e9 9f f5 ff ff       	jmp    80106b05 <alltraps>

80107566 <vector115>:
.globl vector115
vector115:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $115
80107568:	6a 73                	push   $0x73
  jmp alltraps
8010756a:	e9 96 f5 ff ff       	jmp    80106b05 <alltraps>

8010756f <vector116>:
.globl vector116
vector116:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $116
80107571:	6a 74                	push   $0x74
  jmp alltraps
80107573:	e9 8d f5 ff ff       	jmp    80106b05 <alltraps>

80107578 <vector117>:
.globl vector117
vector117:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $117
8010757a:	6a 75                	push   $0x75
  jmp alltraps
8010757c:	e9 84 f5 ff ff       	jmp    80106b05 <alltraps>

80107581 <vector118>:
.globl vector118
vector118:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $118
80107583:	6a 76                	push   $0x76
  jmp alltraps
80107585:	e9 7b f5 ff ff       	jmp    80106b05 <alltraps>

8010758a <vector119>:
.globl vector119
vector119:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $119
8010758c:	6a 77                	push   $0x77
  jmp alltraps
8010758e:	e9 72 f5 ff ff       	jmp    80106b05 <alltraps>

80107593 <vector120>:
.globl vector120
vector120:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $120
80107595:	6a 78                	push   $0x78
  jmp alltraps
80107597:	e9 69 f5 ff ff       	jmp    80106b05 <alltraps>

8010759c <vector121>:
.globl vector121
vector121:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $121
8010759e:	6a 79                	push   $0x79
  jmp alltraps
801075a0:	e9 60 f5 ff ff       	jmp    80106b05 <alltraps>

801075a5 <vector122>:
.globl vector122
vector122:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $122
801075a7:	6a 7a                	push   $0x7a
  jmp alltraps
801075a9:	e9 57 f5 ff ff       	jmp    80106b05 <alltraps>

801075ae <vector123>:
.globl vector123
vector123:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $123
801075b0:	6a 7b                	push   $0x7b
  jmp alltraps
801075b2:	e9 4e f5 ff ff       	jmp    80106b05 <alltraps>

801075b7 <vector124>:
.globl vector124
vector124:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $124
801075b9:	6a 7c                	push   $0x7c
  jmp alltraps
801075bb:	e9 45 f5 ff ff       	jmp    80106b05 <alltraps>

801075c0 <vector125>:
.globl vector125
vector125:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $125
801075c2:	6a 7d                	push   $0x7d
  jmp alltraps
801075c4:	e9 3c f5 ff ff       	jmp    80106b05 <alltraps>

801075c9 <vector126>:
.globl vector126
vector126:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $126
801075cb:	6a 7e                	push   $0x7e
  jmp alltraps
801075cd:	e9 33 f5 ff ff       	jmp    80106b05 <alltraps>

801075d2 <vector127>:
.globl vector127
vector127:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $127
801075d4:	6a 7f                	push   $0x7f
  jmp alltraps
801075d6:	e9 2a f5 ff ff       	jmp    80106b05 <alltraps>

801075db <vector128>:
.globl vector128
vector128:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $128
801075dd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075e2:	e9 1e f5 ff ff       	jmp    80106b05 <alltraps>

801075e7 <vector129>:
.globl vector129
vector129:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $129
801075e9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075ee:	e9 12 f5 ff ff       	jmp    80106b05 <alltraps>

801075f3 <vector130>:
.globl vector130
vector130:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $130
801075f5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075fa:	e9 06 f5 ff ff       	jmp    80106b05 <alltraps>

801075ff <vector131>:
.globl vector131
vector131:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $131
80107601:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107606:	e9 fa f4 ff ff       	jmp    80106b05 <alltraps>

8010760b <vector132>:
.globl vector132
vector132:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $132
8010760d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107612:	e9 ee f4 ff ff       	jmp    80106b05 <alltraps>

80107617 <vector133>:
.globl vector133
vector133:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $133
80107619:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010761e:	e9 e2 f4 ff ff       	jmp    80106b05 <alltraps>

80107623 <vector134>:
.globl vector134
vector134:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $134
80107625:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010762a:	e9 d6 f4 ff ff       	jmp    80106b05 <alltraps>

8010762f <vector135>:
.globl vector135
vector135:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $135
80107631:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107636:	e9 ca f4 ff ff       	jmp    80106b05 <alltraps>

8010763b <vector136>:
.globl vector136
vector136:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $136
8010763d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107642:	e9 be f4 ff ff       	jmp    80106b05 <alltraps>

80107647 <vector137>:
.globl vector137
vector137:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $137
80107649:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010764e:	e9 b2 f4 ff ff       	jmp    80106b05 <alltraps>

80107653 <vector138>:
.globl vector138
vector138:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $138
80107655:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010765a:	e9 a6 f4 ff ff       	jmp    80106b05 <alltraps>

8010765f <vector139>:
.globl vector139
vector139:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $139
80107661:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107666:	e9 9a f4 ff ff       	jmp    80106b05 <alltraps>

8010766b <vector140>:
.globl vector140
vector140:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $140
8010766d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107672:	e9 8e f4 ff ff       	jmp    80106b05 <alltraps>

80107677 <vector141>:
.globl vector141
vector141:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $141
80107679:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010767e:	e9 82 f4 ff ff       	jmp    80106b05 <alltraps>

80107683 <vector142>:
.globl vector142
vector142:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $142
80107685:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010768a:	e9 76 f4 ff ff       	jmp    80106b05 <alltraps>

8010768f <vector143>:
.globl vector143
vector143:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $143
80107691:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107696:	e9 6a f4 ff ff       	jmp    80106b05 <alltraps>

8010769b <vector144>:
.globl vector144
vector144:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $144
8010769d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076a2:	e9 5e f4 ff ff       	jmp    80106b05 <alltraps>

801076a7 <vector145>:
.globl vector145
vector145:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $145
801076a9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076ae:	e9 52 f4 ff ff       	jmp    80106b05 <alltraps>

801076b3 <vector146>:
.globl vector146
vector146:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $146
801076b5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076ba:	e9 46 f4 ff ff       	jmp    80106b05 <alltraps>

801076bf <vector147>:
.globl vector147
vector147:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $147
801076c1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076c6:	e9 3a f4 ff ff       	jmp    80106b05 <alltraps>

801076cb <vector148>:
.globl vector148
vector148:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $148
801076cd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076d2:	e9 2e f4 ff ff       	jmp    80106b05 <alltraps>

801076d7 <vector149>:
.globl vector149
vector149:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $149
801076d9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076de:	e9 22 f4 ff ff       	jmp    80106b05 <alltraps>

801076e3 <vector150>:
.globl vector150
vector150:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $150
801076e5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ea:	e9 16 f4 ff ff       	jmp    80106b05 <alltraps>

801076ef <vector151>:
.globl vector151
vector151:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $151
801076f1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076f6:	e9 0a f4 ff ff       	jmp    80106b05 <alltraps>

801076fb <vector152>:
.globl vector152
vector152:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $152
801076fd:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107702:	e9 fe f3 ff ff       	jmp    80106b05 <alltraps>

80107707 <vector153>:
.globl vector153
vector153:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $153
80107709:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010770e:	e9 f2 f3 ff ff       	jmp    80106b05 <alltraps>

80107713 <vector154>:
.globl vector154
vector154:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $154
80107715:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010771a:	e9 e6 f3 ff ff       	jmp    80106b05 <alltraps>

8010771f <vector155>:
.globl vector155
vector155:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $155
80107721:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107726:	e9 da f3 ff ff       	jmp    80106b05 <alltraps>

8010772b <vector156>:
.globl vector156
vector156:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $156
8010772d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107732:	e9 ce f3 ff ff       	jmp    80106b05 <alltraps>

80107737 <vector157>:
.globl vector157
vector157:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $157
80107739:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010773e:	e9 c2 f3 ff ff       	jmp    80106b05 <alltraps>

80107743 <vector158>:
.globl vector158
vector158:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $158
80107745:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010774a:	e9 b6 f3 ff ff       	jmp    80106b05 <alltraps>

8010774f <vector159>:
.globl vector159
vector159:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $159
80107751:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107756:	e9 aa f3 ff ff       	jmp    80106b05 <alltraps>

8010775b <vector160>:
.globl vector160
vector160:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $160
8010775d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107762:	e9 9e f3 ff ff       	jmp    80106b05 <alltraps>

80107767 <vector161>:
.globl vector161
vector161:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $161
80107769:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010776e:	e9 92 f3 ff ff       	jmp    80106b05 <alltraps>

80107773 <vector162>:
.globl vector162
vector162:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $162
80107775:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010777a:	e9 86 f3 ff ff       	jmp    80106b05 <alltraps>

8010777f <vector163>:
.globl vector163
vector163:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $163
80107781:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107786:	e9 7a f3 ff ff       	jmp    80106b05 <alltraps>

8010778b <vector164>:
.globl vector164
vector164:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $164
8010778d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107792:	e9 6e f3 ff ff       	jmp    80106b05 <alltraps>

80107797 <vector165>:
.globl vector165
vector165:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $165
80107799:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010779e:	e9 62 f3 ff ff       	jmp    80106b05 <alltraps>

801077a3 <vector166>:
.globl vector166
vector166:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $166
801077a5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077aa:	e9 56 f3 ff ff       	jmp    80106b05 <alltraps>

801077af <vector167>:
.globl vector167
vector167:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $167
801077b1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077b6:	e9 4a f3 ff ff       	jmp    80106b05 <alltraps>

801077bb <vector168>:
.globl vector168
vector168:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $168
801077bd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077c2:	e9 3e f3 ff ff       	jmp    80106b05 <alltraps>

801077c7 <vector169>:
.globl vector169
vector169:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $169
801077c9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077ce:	e9 32 f3 ff ff       	jmp    80106b05 <alltraps>

801077d3 <vector170>:
.globl vector170
vector170:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $170
801077d5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077da:	e9 26 f3 ff ff       	jmp    80106b05 <alltraps>

801077df <vector171>:
.globl vector171
vector171:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $171
801077e1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077e6:	e9 1a f3 ff ff       	jmp    80106b05 <alltraps>

801077eb <vector172>:
.globl vector172
vector172:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $172
801077ed:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077f2:	e9 0e f3 ff ff       	jmp    80106b05 <alltraps>

801077f7 <vector173>:
.globl vector173
vector173:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $173
801077f9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077fe:	e9 02 f3 ff ff       	jmp    80106b05 <alltraps>

80107803 <vector174>:
.globl vector174
vector174:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $174
80107805:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010780a:	e9 f6 f2 ff ff       	jmp    80106b05 <alltraps>

8010780f <vector175>:
.globl vector175
vector175:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $175
80107811:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107816:	e9 ea f2 ff ff       	jmp    80106b05 <alltraps>

8010781b <vector176>:
.globl vector176
vector176:
  pushl $0
8010781b:	6a 00                	push   $0x0
  pushl $176
8010781d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107822:	e9 de f2 ff ff       	jmp    80106b05 <alltraps>

80107827 <vector177>:
.globl vector177
vector177:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $177
80107829:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010782e:	e9 d2 f2 ff ff       	jmp    80106b05 <alltraps>

80107833 <vector178>:
.globl vector178
vector178:
  pushl $0
80107833:	6a 00                	push   $0x0
  pushl $178
80107835:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010783a:	e9 c6 f2 ff ff       	jmp    80106b05 <alltraps>

8010783f <vector179>:
.globl vector179
vector179:
  pushl $0
8010783f:	6a 00                	push   $0x0
  pushl $179
80107841:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107846:	e9 ba f2 ff ff       	jmp    80106b05 <alltraps>

8010784b <vector180>:
.globl vector180
vector180:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $180
8010784d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107852:	e9 ae f2 ff ff       	jmp    80106b05 <alltraps>

80107857 <vector181>:
.globl vector181
vector181:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $181
80107859:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010785e:	e9 a2 f2 ff ff       	jmp    80106b05 <alltraps>

80107863 <vector182>:
.globl vector182
vector182:
  pushl $0
80107863:	6a 00                	push   $0x0
  pushl $182
80107865:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010786a:	e9 96 f2 ff ff       	jmp    80106b05 <alltraps>

8010786f <vector183>:
.globl vector183
vector183:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $183
80107871:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107876:	e9 8a f2 ff ff       	jmp    80106b05 <alltraps>

8010787b <vector184>:
.globl vector184
vector184:
  pushl $0
8010787b:	6a 00                	push   $0x0
  pushl $184
8010787d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107882:	e9 7e f2 ff ff       	jmp    80106b05 <alltraps>

80107887 <vector185>:
.globl vector185
vector185:
  pushl $0
80107887:	6a 00                	push   $0x0
  pushl $185
80107889:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010788e:	e9 72 f2 ff ff       	jmp    80106b05 <alltraps>

80107893 <vector186>:
.globl vector186
vector186:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $186
80107895:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010789a:	e9 66 f2 ff ff       	jmp    80106b05 <alltraps>

8010789f <vector187>:
.globl vector187
vector187:
  pushl $0
8010789f:	6a 00                	push   $0x0
  pushl $187
801078a1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078a6:	e9 5a f2 ff ff       	jmp    80106b05 <alltraps>

801078ab <vector188>:
.globl vector188
vector188:
  pushl $0
801078ab:	6a 00                	push   $0x0
  pushl $188
801078ad:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078b2:	e9 4e f2 ff ff       	jmp    80106b05 <alltraps>

801078b7 <vector189>:
.globl vector189
vector189:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $189
801078b9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078be:	e9 42 f2 ff ff       	jmp    80106b05 <alltraps>

801078c3 <vector190>:
.globl vector190
vector190:
  pushl $0
801078c3:	6a 00                	push   $0x0
  pushl $190
801078c5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078ca:	e9 36 f2 ff ff       	jmp    80106b05 <alltraps>

801078cf <vector191>:
.globl vector191
vector191:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $191
801078d1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078d6:	e9 2a f2 ff ff       	jmp    80106b05 <alltraps>

801078db <vector192>:
.globl vector192
vector192:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $192
801078dd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078e2:	e9 1e f2 ff ff       	jmp    80106b05 <alltraps>

801078e7 <vector193>:
.globl vector193
vector193:
  pushl $0
801078e7:	6a 00                	push   $0x0
  pushl $193
801078e9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078ee:	e9 12 f2 ff ff       	jmp    80106b05 <alltraps>

801078f3 <vector194>:
.globl vector194
vector194:
  pushl $0
801078f3:	6a 00                	push   $0x0
  pushl $194
801078f5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078fa:	e9 06 f2 ff ff       	jmp    80106b05 <alltraps>

801078ff <vector195>:
.globl vector195
vector195:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $195
80107901:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107906:	e9 fa f1 ff ff       	jmp    80106b05 <alltraps>

8010790b <vector196>:
.globl vector196
vector196:
  pushl $0
8010790b:	6a 00                	push   $0x0
  pushl $196
8010790d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107912:	e9 ee f1 ff ff       	jmp    80106b05 <alltraps>

80107917 <vector197>:
.globl vector197
vector197:
  pushl $0
80107917:	6a 00                	push   $0x0
  pushl $197
80107919:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010791e:	e9 e2 f1 ff ff       	jmp    80106b05 <alltraps>

80107923 <vector198>:
.globl vector198
vector198:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $198
80107925:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010792a:	e9 d6 f1 ff ff       	jmp    80106b05 <alltraps>

8010792f <vector199>:
.globl vector199
vector199:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $199
80107931:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107936:	e9 ca f1 ff ff       	jmp    80106b05 <alltraps>

8010793b <vector200>:
.globl vector200
vector200:
  pushl $0
8010793b:	6a 00                	push   $0x0
  pushl $200
8010793d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107942:	e9 be f1 ff ff       	jmp    80106b05 <alltraps>

80107947 <vector201>:
.globl vector201
vector201:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $201
80107949:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010794e:	e9 b2 f1 ff ff       	jmp    80106b05 <alltraps>

80107953 <vector202>:
.globl vector202
vector202:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $202
80107955:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010795a:	e9 a6 f1 ff ff       	jmp    80106b05 <alltraps>

8010795f <vector203>:
.globl vector203
vector203:
  pushl $0
8010795f:	6a 00                	push   $0x0
  pushl $203
80107961:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107966:	e9 9a f1 ff ff       	jmp    80106b05 <alltraps>

8010796b <vector204>:
.globl vector204
vector204:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $204
8010796d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107972:	e9 8e f1 ff ff       	jmp    80106b05 <alltraps>

80107977 <vector205>:
.globl vector205
vector205:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $205
80107979:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010797e:	e9 82 f1 ff ff       	jmp    80106b05 <alltraps>

80107983 <vector206>:
.globl vector206
vector206:
  pushl $0
80107983:	6a 00                	push   $0x0
  pushl $206
80107985:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010798a:	e9 76 f1 ff ff       	jmp    80106b05 <alltraps>

8010798f <vector207>:
.globl vector207
vector207:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $207
80107991:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107996:	e9 6a f1 ff ff       	jmp    80106b05 <alltraps>

8010799b <vector208>:
.globl vector208
vector208:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $208
8010799d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079a2:	e9 5e f1 ff ff       	jmp    80106b05 <alltraps>

801079a7 <vector209>:
.globl vector209
vector209:
  pushl $0
801079a7:	6a 00                	push   $0x0
  pushl $209
801079a9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079ae:	e9 52 f1 ff ff       	jmp    80106b05 <alltraps>

801079b3 <vector210>:
.globl vector210
vector210:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $210
801079b5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079ba:	e9 46 f1 ff ff       	jmp    80106b05 <alltraps>

801079bf <vector211>:
.globl vector211
vector211:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $211
801079c1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079c6:	e9 3a f1 ff ff       	jmp    80106b05 <alltraps>

801079cb <vector212>:
.globl vector212
vector212:
  pushl $0
801079cb:	6a 00                	push   $0x0
  pushl $212
801079cd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079d2:	e9 2e f1 ff ff       	jmp    80106b05 <alltraps>

801079d7 <vector213>:
.globl vector213
vector213:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $213
801079d9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079de:	e9 22 f1 ff ff       	jmp    80106b05 <alltraps>

801079e3 <vector214>:
.globl vector214
vector214:
  pushl $0
801079e3:	6a 00                	push   $0x0
  pushl $214
801079e5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ea:	e9 16 f1 ff ff       	jmp    80106b05 <alltraps>

801079ef <vector215>:
.globl vector215
vector215:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $215
801079f1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079f6:	e9 0a f1 ff ff       	jmp    80106b05 <alltraps>

801079fb <vector216>:
.globl vector216
vector216:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $216
801079fd:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a02:	e9 fe f0 ff ff       	jmp    80106b05 <alltraps>

80107a07 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $217
80107a09:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a0e:	e9 f2 f0 ff ff       	jmp    80106b05 <alltraps>

80107a13 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a13:	6a 00                	push   $0x0
  pushl $218
80107a15:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a1a:	e9 e6 f0 ff ff       	jmp    80106b05 <alltraps>

80107a1f <vector219>:
.globl vector219
vector219:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $219
80107a21:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a26:	e9 da f0 ff ff       	jmp    80106b05 <alltraps>

80107a2b <vector220>:
.globl vector220
vector220:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $220
80107a2d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a32:	e9 ce f0 ff ff       	jmp    80106b05 <alltraps>

80107a37 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a37:	6a 00                	push   $0x0
  pushl $221
80107a39:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a3e:	e9 c2 f0 ff ff       	jmp    80106b05 <alltraps>

80107a43 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $222
80107a45:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a4a:	e9 b6 f0 ff ff       	jmp    80106b05 <alltraps>

80107a4f <vector223>:
.globl vector223
vector223:
  pushl $0
80107a4f:	6a 00                	push   $0x0
  pushl $223
80107a51:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a56:	e9 aa f0 ff ff       	jmp    80106b05 <alltraps>

80107a5b <vector224>:
.globl vector224
vector224:
  pushl $0
80107a5b:	6a 00                	push   $0x0
  pushl $224
80107a5d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a62:	e9 9e f0 ff ff       	jmp    80106b05 <alltraps>

80107a67 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $225
80107a69:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a6e:	e9 92 f0 ff ff       	jmp    80106b05 <alltraps>

80107a73 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a73:	6a 00                	push   $0x0
  pushl $226
80107a75:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a7a:	e9 86 f0 ff ff       	jmp    80106b05 <alltraps>

80107a7f <vector227>:
.globl vector227
vector227:
  pushl $0
80107a7f:	6a 00                	push   $0x0
  pushl $227
80107a81:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a86:	e9 7a f0 ff ff       	jmp    80106b05 <alltraps>

80107a8b <vector228>:
.globl vector228
vector228:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $228
80107a8d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a92:	e9 6e f0 ff ff       	jmp    80106b05 <alltraps>

80107a97 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a97:	6a 00                	push   $0x0
  pushl $229
80107a99:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a9e:	e9 62 f0 ff ff       	jmp    80106b05 <alltraps>

80107aa3 <vector230>:
.globl vector230
vector230:
  pushl $0
80107aa3:	6a 00                	push   $0x0
  pushl $230
80107aa5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107aaa:	e9 56 f0 ff ff       	jmp    80106b05 <alltraps>

80107aaf <vector231>:
.globl vector231
vector231:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $231
80107ab1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107ab6:	e9 4a f0 ff ff       	jmp    80106b05 <alltraps>

80107abb <vector232>:
.globl vector232
vector232:
  pushl $0
80107abb:	6a 00                	push   $0x0
  pushl $232
80107abd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ac2:	e9 3e f0 ff ff       	jmp    80106b05 <alltraps>

80107ac7 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $233
80107ac9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ace:	e9 32 f0 ff ff       	jmp    80106b05 <alltraps>

80107ad3 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $234
80107ad5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ada:	e9 26 f0 ff ff       	jmp    80106b05 <alltraps>

80107adf <vector235>:
.globl vector235
vector235:
  pushl $0
80107adf:	6a 00                	push   $0x0
  pushl $235
80107ae1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ae6:	e9 1a f0 ff ff       	jmp    80106b05 <alltraps>

80107aeb <vector236>:
.globl vector236
vector236:
  pushl $0
80107aeb:	6a 00                	push   $0x0
  pushl $236
80107aed:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107af2:	e9 0e f0 ff ff       	jmp    80106b05 <alltraps>

80107af7 <vector237>:
.globl vector237
vector237:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $237
80107af9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107afe:	e9 02 f0 ff ff       	jmp    80106b05 <alltraps>

80107b03 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b03:	6a 00                	push   $0x0
  pushl $238
80107b05:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b0a:	e9 f6 ef ff ff       	jmp    80106b05 <alltraps>

80107b0f <vector239>:
.globl vector239
vector239:
  pushl $0
80107b0f:	6a 00                	push   $0x0
  pushl $239
80107b11:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b16:	e9 ea ef ff ff       	jmp    80106b05 <alltraps>

80107b1b <vector240>:
.globl vector240
vector240:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $240
80107b1d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b22:	e9 de ef ff ff       	jmp    80106b05 <alltraps>

80107b27 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $241
80107b29:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b2e:	e9 d2 ef ff ff       	jmp    80106b05 <alltraps>

80107b33 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b33:	6a 00                	push   $0x0
  pushl $242
80107b35:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b3a:	e9 c6 ef ff ff       	jmp    80106b05 <alltraps>

80107b3f <vector243>:
.globl vector243
vector243:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $243
80107b41:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b46:	e9 ba ef ff ff       	jmp    80106b05 <alltraps>

80107b4b <vector244>:
.globl vector244
vector244:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $244
80107b4d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b52:	e9 ae ef ff ff       	jmp    80106b05 <alltraps>

80107b57 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b57:	6a 00                	push   $0x0
  pushl $245
80107b59:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b5e:	e9 a2 ef ff ff       	jmp    80106b05 <alltraps>

80107b63 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $246
80107b65:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b6a:	e9 96 ef ff ff       	jmp    80106b05 <alltraps>

80107b6f <vector247>:
.globl vector247
vector247:
  pushl $0
80107b6f:	6a 00                	push   $0x0
  pushl $247
80107b71:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b76:	e9 8a ef ff ff       	jmp    80106b05 <alltraps>

80107b7b <vector248>:
.globl vector248
vector248:
  pushl $0
80107b7b:	6a 00                	push   $0x0
  pushl $248
80107b7d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b82:	e9 7e ef ff ff       	jmp    80106b05 <alltraps>

80107b87 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b87:	6a 00                	push   $0x0
  pushl $249
80107b89:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b8e:	e9 72 ef ff ff       	jmp    80106b05 <alltraps>

80107b93 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b93:	6a 00                	push   $0x0
  pushl $250
80107b95:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b9a:	e9 66 ef ff ff       	jmp    80106b05 <alltraps>

80107b9f <vector251>:
.globl vector251
vector251:
  pushl $0
80107b9f:	6a 00                	push   $0x0
  pushl $251
80107ba1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ba6:	e9 5a ef ff ff       	jmp    80106b05 <alltraps>

80107bab <vector252>:
.globl vector252
vector252:
  pushl $0
80107bab:	6a 00                	push   $0x0
  pushl $252
80107bad:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bb2:	e9 4e ef ff ff       	jmp    80106b05 <alltraps>

80107bb7 <vector253>:
.globl vector253
vector253:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $253
80107bb9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bbe:	e9 42 ef ff ff       	jmp    80106b05 <alltraps>

80107bc3 <vector254>:
.globl vector254
vector254:
  pushl $0
80107bc3:	6a 00                	push   $0x0
  pushl $254
80107bc5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bca:	e9 36 ef ff ff       	jmp    80106b05 <alltraps>

80107bcf <vector255>:
.globl vector255
vector255:
  pushl $0
80107bcf:	6a 00                	push   $0x0
  pushl $255
80107bd1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bd6:	e9 2a ef ff ff       	jmp    80106b05 <alltraps>

80107bdb <lgdt>:
{
80107bdb:	55                   	push   %ebp
80107bdc:	89 e5                	mov    %esp,%ebp
80107bde:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107be1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be4:	83 e8 01             	sub    $0x1,%eax
80107be7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107beb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf5:	c1 e8 10             	shr    $0x10,%eax
80107bf8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bfc:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bff:	0f 01 10             	lgdtl  (%eax)
}
80107c02:	90                   	nop
80107c03:	c9                   	leave  
80107c04:	c3                   	ret    

80107c05 <ltr>:
{
80107c05:	55                   	push   %ebp
80107c06:	89 e5                	mov    %esp,%ebp
80107c08:	83 ec 04             	sub    $0x4,%esp
80107c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c16:	0f 00 d8             	ltr    %ax
}
80107c19:	90                   	nop
80107c1a:	c9                   	leave  
80107c1b:	c3                   	ret    

80107c1c <lcr3>:

static inline void
lcr3(uint val)
{
80107c1c:	55                   	push   %ebp
80107c1d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107c22:	0f 22 d8             	mov    %eax,%cr3
}
80107c25:	90                   	nop
80107c26:	5d                   	pop    %ebp
80107c27:	c3                   	ret    

80107c28 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c28:	f3 0f 1e fb          	endbr32 
80107c2c:	55                   	push   %ebp
80107c2d:	89 e5                	mov    %esp,%ebp
80107c2f:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c32:	e8 ce c7 ff ff       	call   80104405 <cpuid>
80107c37:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107c3d:	05 20 48 11 80       	add    $0x80114820,%eax
80107c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c51:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c65:	83 e2 f0             	and    $0xfffffff0,%edx
80107c68:	83 ca 0a             	or     $0xa,%edx
80107c6b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c75:	83 ca 10             	or     $0x10,%edx
80107c78:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c82:	83 e2 9f             	and    $0xffffff9f,%edx
80107c85:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c8f:	83 ca 80             	or     $0xffffff80,%edx
80107c92:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c9c:	83 ca 0f             	or     $0xf,%edx
80107c9f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca9:	83 e2 ef             	and    $0xffffffef,%edx
80107cac:	88 50 7e             	mov    %dl,0x7e(%eax)
80107caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cb6:	83 e2 df             	and    $0xffffffdf,%edx
80107cb9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cc3:	83 ca 40             	or     $0x40,%edx
80107cc6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cd0:	83 ca 80             	or     $0xffffff80,%edx
80107cd3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ce7:	ff ff 
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cf3:	00 00 
80107cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d09:	83 e2 f0             	and    $0xfffffff0,%edx
80107d0c:	83 ca 02             	or     $0x2,%edx
80107d0f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d18:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d1f:	83 ca 10             	or     $0x10,%edx
80107d22:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d32:	83 e2 9f             	and    $0xffffff9f,%edx
80107d35:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d45:	83 ca 80             	or     $0xffffff80,%edx
80107d48:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d51:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d58:	83 ca 0f             	or     $0xf,%edx
80107d5b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d6b:	83 e2 ef             	and    $0xffffffef,%edx
80107d6e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d77:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d7e:	83 e2 df             	and    $0xffffffdf,%edx
80107d81:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d91:	83 ca 40             	or     $0x40,%edx
80107d94:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107da4:	83 ca 80             	or     $0xffffff80,%edx
80107da7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dba:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107dc1:	ff ff 
80107dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc6:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107dcd:	00 00 
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107de3:	83 e2 f0             	and    $0xfffffff0,%edx
80107de6:	83 ca 0a             	or     $0xa,%edx
80107de9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107df9:	83 ca 10             	or     $0x10,%edx
80107dfc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e0c:	83 ca 60             	or     $0x60,%edx
80107e0f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e18:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e1f:	83 ca 80             	or     $0xffffff80,%edx
80107e22:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e32:	83 ca 0f             	or     $0xf,%edx
80107e35:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e45:	83 e2 ef             	and    $0xffffffef,%edx
80107e48:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e58:	83 e2 df             	and    $0xffffffdf,%edx
80107e5b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e6b:	83 ca 40             	or     $0x40,%edx
80107e6e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e77:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e7e:	83 ca 80             	or     $0xffffff80,%edx
80107e81:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e94:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e9b:	ff ff 
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ea7:	00 00 
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ebd:	83 e2 f0             	and    $0xfffffff0,%edx
80107ec0:	83 ca 02             	or     $0x2,%edx
80107ec3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ed3:	83 ca 10             	or     $0x10,%edx
80107ed6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ee6:	83 ca 60             	or     $0x60,%edx
80107ee9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ef9:	83 ca 80             	or     $0xffffff80,%edx
80107efc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f05:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f0c:	83 ca 0f             	or     $0xf,%edx
80107f0f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f18:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f1f:	83 e2 ef             	and    $0xffffffef,%edx
80107f22:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f32:	83 e2 df             	and    $0xffffffdf,%edx
80107f35:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f45:	83 ca 40             	or     $0x40,%edx
80107f48:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f51:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f58:	83 ca 80             	or     $0xffffff80,%edx
80107f5b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f64:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	83 c0 70             	add    $0x70,%eax
80107f71:	83 ec 08             	sub    $0x8,%esp
80107f74:	6a 30                	push   $0x30
80107f76:	50                   	push   %eax
80107f77:	e8 5f fc ff ff       	call   80107bdb <lgdt>
80107f7c:	83 c4 10             	add    $0x10,%esp
}
80107f7f:	90                   	nop
80107f80:	c9                   	leave  
80107f81:	c3                   	ret    

80107f82 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f82:	f3 0f 1e fb          	endbr32 
80107f86:	55                   	push   %ebp
80107f87:	89 e5                	mov    %esp,%ebp
80107f89:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f8f:	c1 e8 16             	shr    $0x16,%eax
80107f92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f99:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9c:	01 d0                	add    %edx,%eax
80107f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
80107fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa4:	8b 00                	mov    (%eax),%eax
80107fa6:	83 e0 01             	and    $0x1,%eax
80107fa9:	85 c0                	test   %eax,%eax
80107fab:	74 14                	je     80107fc1 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb0:	8b 00                	mov    (%eax),%eax
80107fb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb7:	05 00 00 00 80       	add    $0x80000000,%eax
80107fbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fbf:	eb 42                	jmp    80108003 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fc5:	74 0e                	je     80107fd5 <walkpgdir+0x53>
80107fc7:	e8 36 ae ff ff       	call   80102e02 <kalloc>
80107fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fcf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fd3:	75 07                	jne    80107fdc <walkpgdir+0x5a>
      return 0;
80107fd5:	b8 00 00 00 00       	mov    $0x0,%eax
80107fda:	eb 3e                	jmp    8010801a <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fdc:	83 ec 04             	sub    $0x4,%esp
80107fdf:	68 00 10 00 00       	push   $0x1000
80107fe4:	6a 00                	push   $0x0
80107fe6:	ff 75 f4             	pushl  -0xc(%ebp)
80107fe9:	e8 b2 d5 ff ff       	call   801055a0 <memset>
80107fee:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ff9:	83 c8 07             	or     $0x7,%eax
80107ffc:	89 c2                	mov    %eax,%edx
80107ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108001:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108003:	8b 45 0c             	mov    0xc(%ebp),%eax
80108006:	c1 e8 0c             	shr    $0xc,%eax
80108009:	25 ff 03 00 00       	and    $0x3ff,%eax
8010800e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108018:	01 d0                	add    %edx,%eax
}
8010801a:	c9                   	leave  
8010801b:	c3                   	ret    

8010801c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010801c:	f3 0f 1e fb          	endbr32 
80108020:	55                   	push   %ebp
80108021:	89 e5                	mov    %esp,%ebp
80108023:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108026:	8b 45 0c             	mov    0xc(%ebp),%eax
80108029:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010802e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108031:	8b 55 0c             	mov    0xc(%ebp),%edx
80108034:	8b 45 10             	mov    0x10(%ebp),%eax
80108037:	01 d0                	add    %edx,%eax
80108039:	83 e8 01             	sub    $0x1,%eax
8010803c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108041:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108044:	83 ec 04             	sub    $0x4,%esp
80108047:	6a 01                	push   $0x1
80108049:	ff 75 f4             	pushl  -0xc(%ebp)
8010804c:	ff 75 08             	pushl  0x8(%ebp)
8010804f:	e8 2e ff ff ff       	call   80107f82 <walkpgdir>
80108054:	83 c4 10             	add    $0x10,%esp
80108057:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010805a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010805e:	75 07                	jne    80108067 <mappages+0x4b>
      return -1;
80108060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108065:	eb 6f                	jmp    801080d6 <mappages+0xba>
    if(*pte & (PTE_P | PTE_E))
80108067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806a:	8b 00                	mov    (%eax),%eax
8010806c:	25 01 04 00 00       	and    $0x401,%eax
80108071:	85 c0                	test   %eax,%eax
80108073:	74 0d                	je     80108082 <mappages+0x66>
      panic("remap");
80108075:	83 ec 0c             	sub    $0xc,%esp
80108078:	68 30 99 10 80       	push   $0x80109930
8010807d:	e8 86 85 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80108082:	8b 45 18             	mov    0x18(%ebp),%eax
80108085:	25 00 04 00 00       	and    $0x400,%eax
8010808a:	85 c0                	test   %eax,%eax
8010808c:	74 17                	je     801080a5 <mappages+0x89>
      *pte = (pa | perm | PTE_E) & ~PTE_P;
8010808e:	8b 45 18             	mov    0x18(%ebp),%eax
80108091:	0b 45 14             	or     0x14(%ebp),%eax
80108094:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
80108099:	80 cc 04             	or     $0x4,%ah
8010809c:	89 c2                	mov    %eax,%edx
8010809e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a1:	89 10                	mov    %edx,(%eax)
801080a3:	eb 10                	jmp    801080b5 <mappages+0x99>
    else
      *pte = pa | perm | PTE_P;
801080a5:	8b 45 18             	mov    0x18(%ebp),%eax
801080a8:	0b 45 14             	or     0x14(%ebp),%eax
801080ab:	83 c8 01             	or     $0x1,%eax
801080ae:	89 c2                	mov    %eax,%edx
801080b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b3:	89 10                	mov    %edx,(%eax)


    if(a == last)
801080b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080bb:	74 13                	je     801080d0 <mappages+0xb4>
      break;
    a += PGSIZE;
801080bd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080c4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080cb:	e9 74 ff ff ff       	jmp    80108044 <mappages+0x28>
      break;
801080d0:	90                   	nop
  }
  return 0;
801080d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080d6:	c9                   	leave  
801080d7:	c3                   	ret    

801080d8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080d8:	f3 0f 1e fb          	endbr32 
801080dc:	55                   	push   %ebp
801080dd:	89 e5                	mov    %esp,%ebp
801080df:	53                   	push   %ebx
801080e0:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080e3:	e8 1a ad ff ff       	call   80102e02 <kalloc>
801080e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080ef:	75 07                	jne    801080f8 <setupkvm+0x20>
    return 0;
801080f1:	b8 00 00 00 00       	mov    $0x0,%eax
801080f6:	eb 78                	jmp    80108170 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080f8:	83 ec 04             	sub    $0x4,%esp
801080fb:	68 00 10 00 00       	push   $0x1000
80108100:	6a 00                	push   $0x0
80108102:	ff 75 f0             	pushl  -0x10(%ebp)
80108105:	e8 96 d4 ff ff       	call   801055a0 <memset>
8010810a:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010810d:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108114:	eb 4e                	jmp    80108164 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108119:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	8b 58 08             	mov    0x8(%eax),%ebx
80108128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812b:	8b 40 04             	mov    0x4(%eax),%eax
8010812e:	29 c3                	sub    %eax,%ebx
80108130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108133:	8b 00                	mov    (%eax),%eax
80108135:	83 ec 0c             	sub    $0xc,%esp
80108138:	51                   	push   %ecx
80108139:	52                   	push   %edx
8010813a:	53                   	push   %ebx
8010813b:	50                   	push   %eax
8010813c:	ff 75 f0             	pushl  -0x10(%ebp)
8010813f:	e8 d8 fe ff ff       	call   8010801c <mappages>
80108144:	83 c4 20             	add    $0x20,%esp
80108147:	85 c0                	test   %eax,%eax
80108149:	79 15                	jns    80108160 <setupkvm+0x88>
      freevm(pgdir);
8010814b:	83 ec 0c             	sub    $0xc,%esp
8010814e:	ff 75 f0             	pushl  -0x10(%ebp)
80108151:	e8 21 05 00 00       	call   80108677 <freevm>
80108156:	83 c4 10             	add    $0x10,%esp
      return 0;
80108159:	b8 00 00 00 00       	mov    $0x0,%eax
8010815e:	eb 10                	jmp    80108170 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108160:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108164:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010816b:	72 a9                	jb     80108116 <setupkvm+0x3e>
    }
  return pgdir;
8010816d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108173:	c9                   	leave  
80108174:	c3                   	ret    

80108175 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108175:	f3 0f 1e fb          	endbr32 
80108179:	55                   	push   %ebp
8010817a:	89 e5                	mov    %esp,%ebp
8010817c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010817f:	e8 54 ff ff ff       	call   801080d8 <setupkvm>
80108184:	a3 44 8e 11 80       	mov    %eax,0x80118e44
  switchkvm();
80108189:	e8 03 00 00 00       	call   80108191 <switchkvm>
}
8010818e:	90                   	nop
8010818f:	c9                   	leave  
80108190:	c3                   	ret    

80108191 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108191:	f3 0f 1e fb          	endbr32 
80108195:	55                   	push   %ebp
80108196:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108198:	a1 44 8e 11 80       	mov    0x80118e44,%eax
8010819d:	05 00 00 00 80       	add    $0x80000000,%eax
801081a2:	50                   	push   %eax
801081a3:	e8 74 fa ff ff       	call   80107c1c <lcr3>
801081a8:	83 c4 04             	add    $0x4,%esp
}
801081ab:	90                   	nop
801081ac:	c9                   	leave  
801081ad:	c3                   	ret    

801081ae <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081ae:	f3 0f 1e fb          	endbr32 
801081b2:	55                   	push   %ebp
801081b3:	89 e5                	mov    %esp,%ebp
801081b5:	56                   	push   %esi
801081b6:	53                   	push   %ebx
801081b7:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801081ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081be:	75 0d                	jne    801081cd <switchuvm+0x1f>
    panic("switchuvm: no process");
801081c0:	83 ec 0c             	sub    $0xc,%esp
801081c3:	68 36 99 10 80       	push   $0x80109936
801081c8:	e8 3b 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801081cd:	8b 45 08             	mov    0x8(%ebp),%eax
801081d0:	8b 40 08             	mov    0x8(%eax),%eax
801081d3:	85 c0                	test   %eax,%eax
801081d5:	75 0d                	jne    801081e4 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801081d7:	83 ec 0c             	sub    $0xc,%esp
801081da:	68 4c 99 10 80       	push   $0x8010994c
801081df:	e8 24 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801081e4:	8b 45 08             	mov    0x8(%ebp),%eax
801081e7:	8b 40 04             	mov    0x4(%eax),%eax
801081ea:	85 c0                	test   %eax,%eax
801081ec:	75 0d                	jne    801081fb <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801081ee:	83 ec 0c             	sub    $0xc,%esp
801081f1:	68 61 99 10 80       	push   $0x80109961
801081f6:	e8 0d 84 ff ff       	call   80100608 <panic>

  pushcli();
801081fb:	e8 8d d2 ff ff       	call   8010548d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108200:	e8 1f c2 ff ff       	call   80104424 <mycpu>
80108205:	89 c3                	mov    %eax,%ebx
80108207:	e8 18 c2 ff ff       	call   80104424 <mycpu>
8010820c:	83 c0 08             	add    $0x8,%eax
8010820f:	89 c6                	mov    %eax,%esi
80108211:	e8 0e c2 ff ff       	call   80104424 <mycpu>
80108216:	83 c0 08             	add    $0x8,%eax
80108219:	c1 e8 10             	shr    $0x10,%eax
8010821c:	88 45 f7             	mov    %al,-0x9(%ebp)
8010821f:	e8 00 c2 ff ff       	call   80104424 <mycpu>
80108224:	83 c0 08             	add    $0x8,%eax
80108227:	c1 e8 18             	shr    $0x18,%eax
8010822a:	89 c2                	mov    %eax,%edx
8010822c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108233:	67 00 
80108235:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010823c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108240:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108246:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010824d:	83 e0 f0             	and    $0xfffffff0,%eax
80108250:	83 c8 09             	or     $0x9,%eax
80108253:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108259:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108260:	83 c8 10             	or     $0x10,%eax
80108263:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108269:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108270:	83 e0 9f             	and    $0xffffff9f,%eax
80108273:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108279:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108280:	83 c8 80             	or     $0xffffff80,%eax
80108283:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108289:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108290:	83 e0 f0             	and    $0xfffffff0,%eax
80108293:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108299:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082a0:	83 e0 ef             	and    $0xffffffef,%eax
801082a3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082a9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082b0:	83 e0 df             	and    $0xffffffdf,%eax
801082b3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082b9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082c0:	83 c8 40             	or     $0x40,%eax
801082c3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082c9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082d0:	83 e0 7f             	and    $0x7f,%eax
801082d3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082d9:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801082df:	e8 40 c1 ff ff       	call   80104424 <mycpu>
801082e4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082eb:	83 e2 ef             	and    $0xffffffef,%edx
801082ee:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082f4:	e8 2b c1 ff ff       	call   80104424 <mycpu>
801082f9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108302:	8b 40 08             	mov    0x8(%eax),%eax
80108305:	89 c3                	mov    %eax,%ebx
80108307:	e8 18 c1 ff ff       	call   80104424 <mycpu>
8010830c:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108312:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108315:	e8 0a c1 ff ff       	call   80104424 <mycpu>
8010831a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108320:	83 ec 0c             	sub    $0xc,%esp
80108323:	6a 28                	push   $0x28
80108325:	e8 db f8 ff ff       	call   80107c05 <ltr>
8010832a:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010832d:	8b 45 08             	mov    0x8(%ebp),%eax
80108330:	8b 40 04             	mov    0x4(%eax),%eax
80108333:	05 00 00 00 80       	add    $0x80000000,%eax
80108338:	83 ec 0c             	sub    $0xc,%esp
8010833b:	50                   	push   %eax
8010833c:	e8 db f8 ff ff       	call   80107c1c <lcr3>
80108341:	83 c4 10             	add    $0x10,%esp
  popcli();
80108344:	e8 95 d1 ff ff       	call   801054de <popcli>
}
80108349:	90                   	nop
8010834a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010834d:	5b                   	pop    %ebx
8010834e:	5e                   	pop    %esi
8010834f:	5d                   	pop    %ebp
80108350:	c3                   	ret    

80108351 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108351:	f3 0f 1e fb          	endbr32 
80108355:	55                   	push   %ebp
80108356:	89 e5                	mov    %esp,%ebp
80108358:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010835b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108362:	76 0d                	jbe    80108371 <inituvm+0x20>
    panic("inituvm: more than a page");
80108364:	83 ec 0c             	sub    $0xc,%esp
80108367:	68 75 99 10 80       	push   $0x80109975
8010836c:	e8 97 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
80108371:	e8 8c aa ff ff       	call   80102e02 <kalloc>
80108376:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108379:	83 ec 04             	sub    $0x4,%esp
8010837c:	68 00 10 00 00       	push   $0x1000
80108381:	6a 00                	push   $0x0
80108383:	ff 75 f4             	pushl  -0xc(%ebp)
80108386:	e8 15 d2 ff ff       	call   801055a0 <memset>
8010838b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010838e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108391:	05 00 00 00 80       	add    $0x80000000,%eax
80108396:	83 ec 0c             	sub    $0xc,%esp
80108399:	6a 06                	push   $0x6
8010839b:	50                   	push   %eax
8010839c:	68 00 10 00 00       	push   $0x1000
801083a1:	6a 00                	push   $0x0
801083a3:	ff 75 08             	pushl  0x8(%ebp)
801083a6:	e8 71 fc ff ff       	call   8010801c <mappages>
801083ab:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801083ae:	83 ec 04             	sub    $0x4,%esp
801083b1:	ff 75 10             	pushl  0x10(%ebp)
801083b4:	ff 75 0c             	pushl  0xc(%ebp)
801083b7:	ff 75 f4             	pushl  -0xc(%ebp)
801083ba:	e8 a8 d2 ff ff       	call   80105667 <memmove>
801083bf:	83 c4 10             	add    $0x10,%esp
}
801083c2:	90                   	nop
801083c3:	c9                   	leave  
801083c4:	c3                   	ret    

801083c5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083c5:	f3 0f 1e fb          	endbr32 
801083c9:	55                   	push   %ebp
801083ca:	89 e5                	mov    %esp,%ebp
801083cc:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d2:	25 ff 0f 00 00       	and    $0xfff,%eax
801083d7:	85 c0                	test   %eax,%eax
801083d9:	74 0d                	je     801083e8 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801083db:	83 ec 0c             	sub    $0xc,%esp
801083de:	68 90 99 10 80       	push   $0x80109990
801083e3:	e8 20 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ef:	e9 8f 00 00 00       	jmp    80108483 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	01 d0                	add    %edx,%eax
801083fc:	83 ec 04             	sub    $0x4,%esp
801083ff:	6a 00                	push   $0x0
80108401:	50                   	push   %eax
80108402:	ff 75 08             	pushl  0x8(%ebp)
80108405:	e8 78 fb ff ff       	call   80107f82 <walkpgdir>
8010840a:	83 c4 10             	add    $0x10,%esp
8010840d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108410:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108414:	75 0d                	jne    80108423 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108416:	83 ec 0c             	sub    $0xc,%esp
80108419:	68 b3 99 10 80       	push   $0x801099b3
8010841e:	e8 e5 81 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108423:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108426:	8b 00                	mov    (%eax),%eax
80108428:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010842d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108430:	8b 45 18             	mov    0x18(%ebp),%eax
80108433:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108436:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010843b:	77 0b                	ja     80108448 <loaduvm+0x83>
      n = sz - i;
8010843d:	8b 45 18             	mov    0x18(%ebp),%eax
80108440:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108443:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108446:	eb 07                	jmp    8010844f <loaduvm+0x8a>
    else
      n = PGSIZE;
80108448:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010844f:	8b 55 14             	mov    0x14(%ebp),%edx
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	01 d0                	add    %edx,%eax
80108457:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010845a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108460:	ff 75 f0             	pushl  -0x10(%ebp)
80108463:	50                   	push   %eax
80108464:	52                   	push   %edx
80108465:	ff 75 10             	pushl  0x10(%ebp)
80108468:	e8 ad 9b ff ff       	call   8010201a <readi>
8010846d:	83 c4 10             	add    $0x10,%esp
80108470:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108473:	74 07                	je     8010847c <loaduvm+0xb7>
      return -1;
80108475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010847a:	eb 18                	jmp    80108494 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010847c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108486:	3b 45 18             	cmp    0x18(%ebp),%eax
80108489:	0f 82 65 ff ff ff    	jb     801083f4 <loaduvm+0x2f>
  }
  return 0;
8010848f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108494:	c9                   	leave  
80108495:	c3                   	ret    

80108496 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108496:	f3 0f 1e fb          	endbr32 
8010849a:	55                   	push   %ebp
8010849b:	89 e5                	mov    %esp,%ebp
8010849d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801084a0:	8b 45 10             	mov    0x10(%ebp),%eax
801084a3:	85 c0                	test   %eax,%eax
801084a5:	79 0a                	jns    801084b1 <allocuvm+0x1b>
    return 0;
801084a7:	b8 00 00 00 00       	mov    $0x0,%eax
801084ac:	e9 ec 00 00 00       	jmp    8010859d <allocuvm+0x107>
  if(newsz < oldsz)
801084b1:	8b 45 10             	mov    0x10(%ebp),%eax
801084b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084b7:	73 08                	jae    801084c1 <allocuvm+0x2b>
    return oldsz;
801084b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801084bc:	e9 dc 00 00 00       	jmp    8010859d <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801084c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c4:	05 ff 0f 00 00       	add    $0xfff,%eax
801084c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084d1:	e9 b8 00 00 00       	jmp    8010858e <allocuvm+0xf8>
    mem = kalloc();
801084d6:	e8 27 a9 ff ff       	call   80102e02 <kalloc>
801084db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084e2:	75 2e                	jne    80108512 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801084e4:	83 ec 0c             	sub    $0xc,%esp
801084e7:	68 d1 99 10 80       	push   $0x801099d1
801084ec:	e8 27 7f ff ff       	call   80100418 <cprintf>
801084f1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084f4:	83 ec 04             	sub    $0x4,%esp
801084f7:	ff 75 0c             	pushl  0xc(%ebp)
801084fa:	ff 75 10             	pushl  0x10(%ebp)
801084fd:	ff 75 08             	pushl  0x8(%ebp)
80108500:	e8 9a 00 00 00       	call   8010859f <deallocuvm>
80108505:	83 c4 10             	add    $0x10,%esp
      return 0;
80108508:	b8 00 00 00 00       	mov    $0x0,%eax
8010850d:	e9 8b 00 00 00       	jmp    8010859d <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108512:	83 ec 04             	sub    $0x4,%esp
80108515:	68 00 10 00 00       	push   $0x1000
8010851a:	6a 00                	push   $0x0
8010851c:	ff 75 f0             	pushl  -0x10(%ebp)
8010851f:	e8 7c d0 ff ff       	call   801055a0 <memset>
80108524:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010852a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108533:	83 ec 0c             	sub    $0xc,%esp
80108536:	6a 06                	push   $0x6
80108538:	52                   	push   %edx
80108539:	68 00 10 00 00       	push   $0x1000
8010853e:	50                   	push   %eax
8010853f:	ff 75 08             	pushl  0x8(%ebp)
80108542:	e8 d5 fa ff ff       	call   8010801c <mappages>
80108547:	83 c4 20             	add    $0x20,%esp
8010854a:	85 c0                	test   %eax,%eax
8010854c:	79 39                	jns    80108587 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010854e:	83 ec 0c             	sub    $0xc,%esp
80108551:	68 e9 99 10 80       	push   $0x801099e9
80108556:	e8 bd 7e ff ff       	call   80100418 <cprintf>
8010855b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010855e:	83 ec 04             	sub    $0x4,%esp
80108561:	ff 75 0c             	pushl  0xc(%ebp)
80108564:	ff 75 10             	pushl  0x10(%ebp)
80108567:	ff 75 08             	pushl  0x8(%ebp)
8010856a:	e8 30 00 00 00       	call   8010859f <deallocuvm>
8010856f:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108572:	83 ec 0c             	sub    $0xc,%esp
80108575:	ff 75 f0             	pushl  -0x10(%ebp)
80108578:	e8 e7 a7 ff ff       	call   80102d64 <kfree>
8010857d:	83 c4 10             	add    $0x10,%esp
      return 0;
80108580:	b8 00 00 00 00       	mov    $0x0,%eax
80108585:	eb 16                	jmp    8010859d <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108587:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010858e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108591:	3b 45 10             	cmp    0x10(%ebp),%eax
80108594:	0f 82 3c ff ff ff    	jb     801084d6 <allocuvm+0x40>
    }
  }
  return newsz;
8010859a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010859d:	c9                   	leave  
8010859e:	c3                   	ret    

8010859f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010859f:	f3 0f 1e fb          	endbr32 
801085a3:	55                   	push   %ebp
801085a4:	89 e5                	mov    %esp,%ebp
801085a6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801085a9:	8b 45 10             	mov    0x10(%ebp),%eax
801085ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085af:	72 08                	jb     801085b9 <deallocuvm+0x1a>
    return oldsz;
801085b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801085b4:	e9 bc 00 00 00       	jmp    80108675 <deallocuvm+0xd6>

  a = PGROUNDUP(newsz);
801085b9:	8b 45 10             	mov    0x10(%ebp),%eax
801085bc:	05 ff 0f 00 00       	add    $0xfff,%eax
801085c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085c9:	e9 98 00 00 00       	jmp    80108666 <deallocuvm+0xc7>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d1:	83 ec 04             	sub    $0x4,%esp
801085d4:	6a 00                	push   $0x0
801085d6:	50                   	push   %eax
801085d7:	ff 75 08             	pushl  0x8(%ebp)
801085da:	e8 a3 f9 ff ff       	call   80107f82 <walkpgdir>
801085df:	83 c4 10             	add    $0x10,%esp
801085e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085e9:	75 16                	jne    80108601 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	c1 e8 16             	shr    $0x16,%eax
801085f1:	83 c0 01             	add    $0x1,%eax
801085f4:	c1 e0 16             	shl    $0x16,%eax
801085f7:	2d 00 10 00 00       	sub    $0x1000,%eax
801085fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085ff:	eb 5e                	jmp    8010865f <deallocuvm+0xc0>
    else if((*pte & (PTE_P | PTE_E)) != 0){
80108601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108604:	8b 00                	mov    (%eax),%eax
80108606:	25 01 04 00 00       	and    $0x401,%eax
8010860b:	85 c0                	test   %eax,%eax
8010860d:	74 50                	je     8010865f <deallocuvm+0xc0>
      pa = PTE_ADDR(*pte);
8010860f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108612:	8b 00                	mov    (%eax),%eax
80108614:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108619:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010861c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108620:	75 0d                	jne    8010862f <deallocuvm+0x90>
        panic("kfree");
80108622:	83 ec 0c             	sub    $0xc,%esp
80108625:	68 05 9a 10 80       	push   $0x80109a05
8010862a:	e8 d9 7f ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
8010862f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108632:	05 00 00 00 80       	add    $0x80000000,%eax
80108637:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010863a:	83 ec 0c             	sub    $0xc,%esp
8010863d:	ff 75 e8             	pushl  -0x18(%ebp)
80108640:	e8 1f a7 ff ff       	call   80102d64 <kfree>
80108645:	83 c4 10             	add    $0x10,%esp
      cq_remove(pte);
80108648:	83 ec 0c             	sub    $0xc,%esp
8010864b:	ff 75 f0             	pushl  -0x10(%ebp)
8010864e:	e8 a5 05 00 00       	call   80108bf8 <cq_remove>
80108653:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108659:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010865f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010866c:	0f 82 5c ff ff ff    	jb     801085ce <deallocuvm+0x2f>
    }
  }
  return newsz;
80108672:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108675:	c9                   	leave  
80108676:	c3                   	ret    

80108677 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108677:	f3 0f 1e fb          	endbr32 
8010867b:	55                   	push   %ebp
8010867c:	89 e5                	mov    %esp,%ebp
8010867e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108681:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108685:	75 0d                	jne    80108694 <freevm+0x1d>
    panic("freevm: no pgdir");
80108687:	83 ec 0c             	sub    $0xc,%esp
8010868a:	68 0b 9a 10 80       	push   $0x80109a0b
8010868f:	e8 74 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108694:	83 ec 04             	sub    $0x4,%esp
80108697:	6a 00                	push   $0x0
80108699:	68 00 00 00 80       	push   $0x80000000
8010869e:	ff 75 08             	pushl  0x8(%ebp)
801086a1:	e8 f9 fe ff ff       	call   8010859f <deallocuvm>
801086a6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086b0:	eb 48                	jmp    801086fa <freevm+0x83>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
801086b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086bc:	8b 45 08             	mov    0x8(%ebp),%eax
801086bf:	01 d0                	add    %edx,%eax
801086c1:	8b 00                	mov    (%eax),%eax
801086c3:	83 e0 01             	and    $0x1,%eax
801086c6:	85 c0                	test   %eax,%eax
801086c8:	74 2c                	je     801086f6 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086d4:	8b 45 08             	mov    0x8(%ebp),%eax
801086d7:	01 d0                	add    %edx,%eax
801086d9:	8b 00                	mov    (%eax),%eax
801086db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e0:	05 00 00 00 80       	add    $0x80000000,%eax
801086e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086e8:	83 ec 0c             	sub    $0xc,%esp
801086eb:	ff 75 f0             	pushl  -0x10(%ebp)
801086ee:	e8 71 a6 ff ff       	call   80102d64 <kfree>
801086f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086fa:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108701:	76 af                	jbe    801086b2 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108703:	83 ec 0c             	sub    $0xc,%esp
80108706:	ff 75 08             	pushl  0x8(%ebp)
80108709:	e8 56 a6 ff ff       	call   80102d64 <kfree>
8010870e:	83 c4 10             	add    $0x10,%esp
}
80108711:	90                   	nop
80108712:	c9                   	leave  
80108713:	c3                   	ret    

80108714 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108714:	f3 0f 1e fb          	endbr32 
80108718:	55                   	push   %ebp
80108719:	89 e5                	mov    %esp,%ebp
8010871b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010871e:	83 ec 04             	sub    $0x4,%esp
80108721:	6a 00                	push   $0x0
80108723:	ff 75 0c             	pushl  0xc(%ebp)
80108726:	ff 75 08             	pushl  0x8(%ebp)
80108729:	e8 54 f8 ff ff       	call   80107f82 <walkpgdir>
8010872e:	83 c4 10             	add    $0x10,%esp
80108731:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108738:	75 0d                	jne    80108747 <clearpteu+0x33>
    panic("clearpteu");
8010873a:	83 ec 0c             	sub    $0xc,%esp
8010873d:	68 1c 9a 10 80       	push   $0x80109a1c
80108742:	e8 c1 7e ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874a:	8b 00                	mov    (%eax),%eax
8010874c:	83 e0 fb             	and    $0xfffffffb,%eax
8010874f:	89 c2                	mov    %eax,%edx
80108751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108754:	89 10                	mov    %edx,(%eax)
}
80108756:	90                   	nop
80108757:	c9                   	leave  
80108758:	c3                   	ret    

80108759 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108759:	f3 0f 1e fb          	endbr32 
8010875d:	55                   	push   %ebp
8010875e:	89 e5                	mov    %esp,%ebp
80108760:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108763:	e8 70 f9 ff ff       	call   801080d8 <setupkvm>
80108768:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010876b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010876f:	75 0a                	jne    8010877b <copyuvm+0x22>
    return 0;
80108771:	b8 00 00 00 00       	mov    $0x0,%eax
80108776:	e9 fa 00 00 00       	jmp    80108875 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010877b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108782:	e9 c9 00 00 00       	jmp    80108850 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878a:	83 ec 04             	sub    $0x4,%esp
8010878d:	6a 00                	push   $0x0
8010878f:	50                   	push   %eax
80108790:	ff 75 08             	pushl  0x8(%ebp)
80108793:	e8 ea f7 ff ff       	call   80107f82 <walkpgdir>
80108798:	83 c4 10             	add    $0x10,%esp
8010879b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010879e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087a2:	75 0d                	jne    801087b1 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801087a4:	83 ec 0c             	sub    $0xc,%esp
801087a7:	68 26 9a 10 80       	push   $0x80109a26
801087ac:	e8 57 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
801087b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b4:	8b 00                	mov    (%eax),%eax
801087b6:	25 01 04 00 00       	and    $0x401,%eax
801087bb:	85 c0                	test   %eax,%eax
801087bd:	75 0d                	jne    801087cc <copyuvm+0x73>
      panic("copyuvm: page not present");
801087bf:	83 ec 0c             	sub    $0xc,%esp
801087c2:	68 40 9a 10 80       	push   $0x80109a40
801087c7:	e8 3c 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801087cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087cf:	8b 00                	mov    (%eax),%eax
801087d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087dc:	8b 00                	mov    (%eax),%eax
801087de:	25 ff 0f 00 00       	and    $0xfff,%eax
801087e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087e6:	e8 17 a6 ff ff       	call   80102e02 <kalloc>
801087eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087f2:	74 6d                	je     80108861 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087f7:	05 00 00 00 80       	add    $0x80000000,%eax
801087fc:	83 ec 04             	sub    $0x4,%esp
801087ff:	68 00 10 00 00       	push   $0x1000
80108804:	50                   	push   %eax
80108805:	ff 75 e0             	pushl  -0x20(%ebp)
80108808:	e8 5a ce ff ff       	call   80105667 <memmove>
8010880d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108810:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108813:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108816:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010881c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881f:	83 ec 0c             	sub    $0xc,%esp
80108822:	52                   	push   %edx
80108823:	51                   	push   %ecx
80108824:	68 00 10 00 00       	push   $0x1000
80108829:	50                   	push   %eax
8010882a:	ff 75 f0             	pushl  -0x10(%ebp)
8010882d:	e8 ea f7 ff ff       	call   8010801c <mappages>
80108832:	83 c4 20             	add    $0x20,%esp
80108835:	85 c0                	test   %eax,%eax
80108837:	79 10                	jns    80108849 <copyuvm+0xf0>
      kfree(mem);
80108839:	83 ec 0c             	sub    $0xc,%esp
8010883c:	ff 75 e0             	pushl  -0x20(%ebp)
8010883f:	e8 20 a5 ff ff       	call   80102d64 <kfree>
80108844:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108847:	eb 19                	jmp    80108862 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108849:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108853:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108856:	0f 82 2b ff ff ff    	jb     80108787 <copyuvm+0x2e>
    }
  }
  return d;
8010885c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010885f:	eb 14                	jmp    80108875 <copyuvm+0x11c>
      goto bad;
80108861:	90                   	nop

bad:
  freevm(d);
80108862:	83 ec 0c             	sub    $0xc,%esp
80108865:	ff 75 f0             	pushl  -0x10(%ebp)
80108868:	e8 0a fe ff ff       	call   80108677 <freevm>
8010886d:	83 c4 10             	add    $0x10,%esp
  return 0;
80108870:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108875:	c9                   	leave  
80108876:	c3                   	ret    

80108877 <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108877:	f3 0f 1e fb          	endbr32 
8010887b:	55                   	push   %ebp
8010887c:	89 e5                	mov    %esp,%ebp
8010887e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108881:	83 ec 04             	sub    $0x4,%esp
80108884:	6a 00                	push   $0x0
80108886:	ff 75 0c             	pushl  0xc(%ebp)
80108889:	ff 75 08             	pushl  0x8(%ebp)
8010888c:	e8 f1 f6 ff ff       	call   80107f82 <walkpgdir>
80108891:	83 c4 10             	add    $0x10,%esp
80108894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889a:	8b 00                	mov    (%eax),%eax
8010889c:	25 01 04 00 00       	and    $0x401,%eax
801088a1:	85 c0                	test   %eax,%eax
801088a3:	75 07                	jne    801088ac <uva2ka+0x35>
    return 0;
801088a5:	b8 00 00 00 00       	mov    $0x0,%eax
801088aa:	eb 22                	jmp    801088ce <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
801088ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088af:	8b 00                	mov    (%eax),%eax
801088b1:	83 e0 04             	and    $0x4,%eax
801088b4:	85 c0                	test   %eax,%eax
801088b6:	75 07                	jne    801088bf <uva2ka+0x48>
    return 0;
801088b8:	b8 00 00 00 00       	mov    $0x0,%eax
801088bd:	eb 0f                	jmp    801088ce <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
801088bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c2:	8b 00                	mov    (%eax),%eax
801088c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088c9:	05 00 00 00 80       	add    $0x80000000,%eax
}
801088ce:	c9                   	leave  
801088cf:	c3                   	ret    

801088d0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088d0:	f3 0f 1e fb          	endbr32 
801088d4:	55                   	push   %ebp
801088d5:	89 e5                	mov    %esp,%ebp
801088d7:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088da:	8b 45 10             	mov    0x10(%ebp),%eax
801088dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088e0:	eb 7f                	jmp    80108961 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801088e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
801088ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f0:	83 ec 08             	sub    $0x8,%esp
801088f3:	50                   	push   %eax
801088f4:	ff 75 08             	pushl  0x8(%ebp)
801088f7:	e8 7b ff ff ff       	call   80108877 <uva2ka>
801088fc:	83 c4 10             	add    $0x10,%esp
801088ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108902:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108906:	75 07                	jne    8010890f <copyout+0x3f>
      return -1;
80108908:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010890d:	eb 61                	jmp    80108970 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
8010890f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108912:	2b 45 0c             	sub    0xc(%ebp),%eax
80108915:	05 00 10 00 00       	add    $0x1000,%eax
8010891a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010891d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108920:	3b 45 14             	cmp    0x14(%ebp),%eax
80108923:	76 06                	jbe    8010892b <copyout+0x5b>
      n = len;
80108925:	8b 45 14             	mov    0x14(%ebp),%eax
80108928:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010892b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010892e:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108931:	89 c2                	mov    %eax,%edx
80108933:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108936:	01 d0                	add    %edx,%eax
80108938:	83 ec 04             	sub    $0x4,%esp
8010893b:	ff 75 f0             	pushl  -0x10(%ebp)
8010893e:	ff 75 f4             	pushl  -0xc(%ebp)
80108941:	50                   	push   %eax
80108942:	e8 20 cd ff ff       	call   80105667 <memmove>
80108947:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010894a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010894d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108953:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108956:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108959:	05 00 10 00 00       	add    $0x1000,%eax
8010895e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108961:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108965:	0f 85 77 ff ff ff    	jne    801088e2 <copyout+0x12>
  }
  return 0;
8010896b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108970:	c9                   	leave  
80108971:	c3                   	ret    

80108972 <cq_init>:
//p6 melody changes
//clear the queue
void cq_init(struct proc* p){
80108972:	f3 0f 1e fb          	endbr32 
80108976:	55                   	push   %ebp
80108977:	89 e5                	mov    %esp,%ebp
80108979:	83 ec 10             	sub    $0x10,%esp
  for(int i=0;i<CLOCKSIZE;i++){
8010897c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108983:	eb 54                	jmp    801089d9 <cq_init+0x67>
    p->cq[i].empty=-1;
80108985:	8b 4d 08             	mov    0x8(%ebp),%ecx
80108988:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010898b:	89 d0                	mov    %edx,%eax
8010898d:	01 c0                	add    %eax,%eax
8010898f:	01 d0                	add    %edx,%eax
80108991:	c1 e0 02             	shl    $0x2,%eax
80108994:	01 c8                	add    %ecx,%eax
80108996:	83 c0 7c             	add    $0x7c,%eax
80108999:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
    p->cq[i].va=(void*)0;
8010899f:	8b 4d 08             	mov    0x8(%ebp),%ecx
801089a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801089a5:	89 d0                	mov    %edx,%eax
801089a7:	01 c0                	add    %eax,%eax
801089a9:	01 d0                	add    %edx,%eax
801089ab:	c1 e0 02             	shl    $0x2,%eax
801089ae:	01 c8                	add    %ecx,%eax
801089b0:	83 e8 80             	sub    $0xffffff80,%eax
801089b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    p->cq[i].pte=(void*)0;
801089b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801089bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801089bf:	89 d0                	mov    %edx,%eax
801089c1:	01 c0                	add    %eax,%eax
801089c3:	01 d0                	add    %edx,%eax
801089c5:	c1 e0 02             	shl    $0x2,%eax
801089c8:	01 c8                	add    %ecx,%eax
801089ca:	05 84 00 00 00       	add    $0x84,%eax
801089cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<CLOCKSIZE;i++){
801089d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801089d9:	83 7d fc 07          	cmpl   $0x7,-0x4(%ebp)
801089dd:	7e a6                	jle    80108985 <cq_init+0x13>
    //cprintf("cq_init: pid:%d cq:%x va:%x, pte:%x\n",p->pid,p->cq,p->cq[i]->va,p->cq[i]->pte);
  }
  p->clock_hand=-1;
801089df:	8b 45 08             	mov    0x8(%ebp),%eax
801089e2:	c7 80 dc 00 00 00 ff 	movl   $0xffffffff,0xdc(%eax)
801089e9:	ff ff ff 
  return;
801089ec:	90                   	nop
}
801089ed:	c9                   	leave  
801089ee:	c3                   	ret    

801089ef <cq_enset>:

//insert one page in the working set
//may replace a victim 
//return 0 succ
int
cq_enset(char* va){
801089ef:	f3 0f 1e fb          	endbr32 
801089f3:	55                   	push   %ebp
801089f4:	89 e5                	mov    %esp,%ebp
801089f6:	83 ec 18             	sub    $0x18,%esp
  pte_t * pte = walkpgdir(myproc()->pgdir, va, 0);
801089f9:	e8 a2 ba ff ff       	call   801044a0 <myproc>
801089fe:	8b 40 04             	mov    0x4(%eax),%eax
80108a01:	83 ec 04             	sub    $0x4,%esp
80108a04:	6a 00                	push   $0x0
80108a06:	ff 75 08             	pushl  0x8(%ebp)
80108a09:	50                   	push   %eax
80108a0a:	e8 73 f5 ff ff       	call   80107f82 <walkpgdir>
80108a0f:	83 c4 10             	add    $0x10,%esp
80108a12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(!pte) return -1;
80108a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a19:	75 0a                	jne    80108a25 <cq_enset+0x36>
80108a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a20:	e9 d1 01 00 00       	jmp    80108bf6 <cq_enset+0x207>
  //check repetion
  // cprintf("check current working set with pte:%x\n",pte);
  // for(int i=0;i<CLOCKSIZE;i++){
  //   cprintf("pid:%d cq:%x pte:%x va:%x empty:%d ref:%d\n",myproc()->pid,myproc()->cq,myproc()->cq[i].pte,myproc()->cq[i].va,myproc()->cq[i].empty,*(myproc()->cq[i].pte)&PTE_A);
  // }
  for(int i=0;i<CLOCKSIZE;i++){
80108a25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a2c:	eb 4e                	jmp    80108a7c <cq_enset+0x8d>
    if(myproc()->cq[i].pte==pte && myproc()->cq[i].empty!=-1) return 0;
80108a2e:	e8 6d ba ff ff       	call   801044a0 <myproc>
80108a33:	89 c1                	mov    %eax,%ecx
80108a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a38:	89 d0                	mov    %edx,%eax
80108a3a:	01 c0                	add    %eax,%eax
80108a3c:	01 d0                	add    %edx,%eax
80108a3e:	c1 e0 02             	shl    $0x2,%eax
80108a41:	01 c8                	add    %ecx,%eax
80108a43:	05 84 00 00 00       	add    $0x84,%eax
80108a48:	8b 00                	mov    (%eax),%eax
80108a4a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108a4d:	75 29                	jne    80108a78 <cq_enset+0x89>
80108a4f:	e8 4c ba ff ff       	call   801044a0 <myproc>
80108a54:	89 c1                	mov    %eax,%ecx
80108a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a59:	89 d0                	mov    %edx,%eax
80108a5b:	01 c0                	add    %eax,%eax
80108a5d:	01 d0                	add    %edx,%eax
80108a5f:	c1 e0 02             	shl    $0x2,%eax
80108a62:	01 c8                	add    %ecx,%eax
80108a64:	83 c0 7c             	add    $0x7c,%eax
80108a67:	8b 00                	mov    (%eax),%eax
80108a69:	83 f8 ff             	cmp    $0xffffffff,%eax
80108a6c:	74 0a                	je     80108a78 <cq_enset+0x89>
80108a6e:	b8 00 00 00 00       	mov    $0x0,%eax
80108a73:	e9 7e 01 00 00       	jmp    80108bf6 <cq_enset+0x207>
  for(int i=0;i<CLOCKSIZE;i++){
80108a78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a7c:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80108a80:	7e ac                	jle    80108a2e <cq_enset+0x3f>
  }

  int clock_hand=myproc()->clock_hand;
80108a82:	e8 19 ba ff ff       	call   801044a0 <myproc>
80108a87:	8b 80 dc 00 00 00    	mov    0xdc(%eax),%eax
80108a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(1){
    clock_hand = (clock_hand + 1) % CLOCKSIZE;
80108a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a93:	8d 50 01             	lea    0x1(%eax),%edx
80108a96:	89 d0                	mov    %edx,%eax
80108a98:	c1 f8 1f             	sar    $0x1f,%eax
80108a9b:	c1 e8 1d             	shr    $0x1d,%eax
80108a9e:	01 c2                	add    %eax,%edx
80108aa0:	83 e2 07             	and    $0x7,%edx
80108aa3:	29 c2                	sub    %eax,%edx
80108aa5:	89 d0                	mov    %edx,%eax
80108aa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // Found an empty slot.
    if ((myproc()->cq[clock_hand].empty)==-1) {
80108aaa:	e8 f1 b9 ff ff       	call   801044a0 <myproc>
80108aaf:	89 c1                	mov    %eax,%ecx
80108ab1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ab4:	89 d0                	mov    %edx,%eax
80108ab6:	01 c0                	add    %eax,%eax
80108ab8:	01 d0                	add    %edx,%eax
80108aba:	c1 e0 02             	shl    $0x2,%eax
80108abd:	01 c8                	add    %ecx,%eax
80108abf:	83 c0 7c             	add    $0x7c,%eax
80108ac2:	8b 00                	mov    (%eax),%eax
80108ac4:	83 f8 ff             	cmp    $0xffffffff,%eax
80108ac7:	75 63                	jne    80108b2c <cq_enset+0x13d>
        //printf("empty case: pid:%d va: %x pte: %d PTE_P: %d\n",myproc()->pid, va,pte,(*pte & PTE_P));
        myproc()->cq[clock_hand].va = va;
80108ac9:	e8 d2 b9 ff ff       	call   801044a0 <myproc>
80108ace:	89 c1                	mov    %eax,%ecx
80108ad0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ad3:	89 d0                	mov    %edx,%eax
80108ad5:	01 c0                	add    %eax,%eax
80108ad7:	01 d0                	add    %edx,%eax
80108ad9:	c1 e0 02             	shl    $0x2,%eax
80108adc:	01 c8                	add    %ecx,%eax
80108ade:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80108ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae7:	89 02                	mov    %eax,(%edx)
        myproc()->cq[clock_hand].pte = pte;
80108ae9:	e8 b2 b9 ff ff       	call   801044a0 <myproc>
80108aee:	89 c1                	mov    %eax,%ecx
80108af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108af3:	89 d0                	mov    %edx,%eax
80108af5:	01 c0                	add    %eax,%eax
80108af7:	01 d0                	add    %edx,%eax
80108af9:	c1 e0 02             	shl    $0x2,%eax
80108afc:	01 c8                	add    %ecx,%eax
80108afe:	8d 90 84 00 00 00    	lea    0x84(%eax),%edx
80108b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b07:	89 02                	mov    %eax,(%edx)
        myproc()->cq[clock_hand].empty=0;
80108b09:	e8 92 b9 ff ff       	call   801044a0 <myproc>
80108b0e:	89 c1                	mov    %eax,%ecx
80108b10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b13:	89 d0                	mov    %edx,%eax
80108b15:	01 c0                	add    %eax,%eax
80108b17:	01 d0                	add    %edx,%eax
80108b19:	c1 e0 02             	shl    $0x2,%eax
80108b1c:	01 c8                	add    %ecx,%eax
80108b1e:	83 c0 7c             	add    $0x7c,%eax
80108b21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        break;
80108b27:	e9 b7 00 00 00       	jmp    80108be3 <cq_enset+0x1f4>
    }
    else if(!(*(myproc()->cq[clock_hand].pte)& PTE_A)){
80108b2c:	e8 6f b9 ff ff       	call   801044a0 <myproc>
80108b31:	89 c1                	mov    %eax,%ecx
80108b33:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b36:	89 d0                	mov    %edx,%eax
80108b38:	01 c0                	add    %eax,%eax
80108b3a:	01 d0                	add    %edx,%eax
80108b3c:	c1 e0 02             	shl    $0x2,%eax
80108b3f:	01 c8                	add    %ecx,%eax
80108b41:	05 84 00 00 00       	add    $0x84,%eax
80108b46:	8b 00                	mov    (%eax),%eax
80108b48:	8b 00                	mov    (%eax),%eax
80108b4a:	83 e0 20             	and    $0x20,%eax
80108b4d:	85 c0                	test   %eax,%eax
80108b4f:	75 6a                	jne    80108bbb <cq_enset+0x1cc>
      //replace
      //cprintf("replace:\n");
      mencrypt(myproc()->cq[clock_hand].va,1);//the vicim page
80108b51:	e8 4a b9 ff ff       	call   801044a0 <myproc>
80108b56:	89 c1                	mov    %eax,%ecx
80108b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b5b:	89 d0                	mov    %edx,%eax
80108b5d:	01 c0                	add    %eax,%eax
80108b5f:	01 d0                	add    %edx,%eax
80108b61:	c1 e0 02             	shl    $0x2,%eax
80108b64:	01 c8                	add    %ecx,%eax
80108b66:	83 e8 80             	sub    $0xffffff80,%eax
80108b69:	8b 00                	mov    (%eax),%eax
80108b6b:	83 ec 08             	sub    $0x8,%esp
80108b6e:	6a 01                	push   $0x1
80108b70:	50                   	push   %eax
80108b71:	e8 fc 02 00 00       	call   80108e72 <mencrypt>
80108b76:	83 c4 10             	add    $0x10,%esp
      myproc()->cq[clock_hand].va=va;
80108b79:	e8 22 b9 ff ff       	call   801044a0 <myproc>
80108b7e:	89 c1                	mov    %eax,%ecx
80108b80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b83:	89 d0                	mov    %edx,%eax
80108b85:	01 c0                	add    %eax,%eax
80108b87:	01 d0                	add    %edx,%eax
80108b89:	c1 e0 02             	shl    $0x2,%eax
80108b8c:	01 c8                	add    %ecx,%eax
80108b8e:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
80108b94:	8b 45 08             	mov    0x8(%ebp),%eax
80108b97:	89 02                	mov    %eax,(%edx)
      myproc()->cq[clock_hand].pte=pte;
80108b99:	e8 02 b9 ff ff       	call   801044a0 <myproc>
80108b9e:	89 c1                	mov    %eax,%ecx
80108ba0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ba3:	89 d0                	mov    %edx,%eax
80108ba5:	01 c0                	add    %eax,%eax
80108ba7:	01 d0                	add    %edx,%eax
80108ba9:	c1 e0 02             	shl    $0x2,%eax
80108bac:	01 c8                	add    %ecx,%eax
80108bae:	8d 90 84 00 00 00    	lea    0x84(%eax),%edx
80108bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bb7:	89 02                	mov    %eax,(%edx)
      break;
80108bb9:	eb 28                	jmp    80108be3 <cq_enset+0x1f4>
    }else{
      //int bit=-1;
      //if(*(myproc()->cq[clock_hand].pte)&PTE_A) bit=1;
      *(myproc()->cq[clock_hand].pte)&=(~PTE_A);
80108bbb:	e8 e0 b8 ff ff       	call   801044a0 <myproc>
80108bc0:	89 c1                	mov    %eax,%ecx
80108bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bc5:	89 d0                	mov    %edx,%eax
80108bc7:	01 c0                	add    %eax,%eax
80108bc9:	01 d0                	add    %edx,%eax
80108bcb:	c1 e0 02             	shl    $0x2,%eax
80108bce:	01 c8                	add    %ecx,%eax
80108bd0:	05 84 00 00 00       	add    $0x84,%eax
80108bd5:	8b 00                	mov    (%eax),%eax
80108bd7:	8b 10                	mov    (%eax),%edx
80108bd9:	83 e2 df             	and    $0xffffffdf,%edx
80108bdc:	89 10                	mov    %edx,(%eax)
    clock_hand = (clock_hand + 1) % CLOCKSIZE;
80108bde:	e9 ad fe ff ff       	jmp    80108a90 <cq_enset+0xa1>
      //cprintf("after clear ref: %d\n",*(myproc()->cq[clock_hand].pte)&PTE_A);
    }
   }
  myproc()->clock_hand=clock_hand;
80108be3:	e8 b8 b8 ff ff       	call   801044a0 <myproc>
80108be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108beb:	89 90 dc 00 00 00    	mov    %edx,0xdc(%eax)
  return 0;
80108bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bf6:	c9                   	leave  
80108bf7:	c3                   	ret    

80108bf8 <cq_remove>:

void cq_remove(pte_t *pte){
80108bf8:	f3 0f 1e fb          	endbr32 
80108bfc:	55                   	push   %ebp
80108bfd:	89 e5                	mov    %esp,%ebp
80108bff:	56                   	push   %esi
80108c00:	53                   	push   %ebx
80108c01:	83 ec 20             	sub    $0x20,%esp
  //cprintf("hi from remove\n");
  int old_hand=myproc()->clock_hand;
80108c04:	e8 97 b8 ff ff       	call   801044a0 <myproc>
80108c09:	8b 80 dc 00 00 00    	mov    0xdc(%eax),%eax
80108c0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int del_i=-1;
80108c12:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  for(int i=0;i<CLOCKSIZE;i++){
80108c19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c20:	eb 2d                	jmp    80108c4f <cq_remove+0x57>
    if(myproc()->cq[i].pte==pte){
80108c22:	e8 79 b8 ff ff       	call   801044a0 <myproc>
80108c27:	89 c1                	mov    %eax,%ecx
80108c29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c2c:	89 d0                	mov    %edx,%eax
80108c2e:	01 c0                	add    %eax,%eax
80108c30:	01 d0                	add    %edx,%eax
80108c32:	c1 e0 02             	shl    $0x2,%eax
80108c35:	01 c8                	add    %ecx,%eax
80108c37:	05 84 00 00 00       	add    $0x84,%eax
80108c3c:	8b 00                	mov    (%eax),%eax
80108c3e:	39 45 08             	cmp    %eax,0x8(%ebp)
80108c41:	75 08                	jne    80108c4b <cq_remove+0x53>
      del_i=i;
80108c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
80108c49:	eb 0a                	jmp    80108c55 <cq_remove+0x5d>
  for(int i=0;i<CLOCKSIZE;i++){
80108c4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c4f:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
80108c53:	7e cd                	jle    80108c22 <cq_remove+0x2a>
    }
  }
  if(del_i==-1) return;
80108c55:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80108c59:	0f 84 24 01 00 00    	je     80108d83 <cq_remove+0x18b>
  for(int i=del_i;i!=old_hand;i++){
80108c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c62:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c65:	e9 be 00 00 00       	jmp    80108d28 <cq_remove+0x130>
    int next=(i+1)%CLOCKSIZE;
80108c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6d:	8d 50 01             	lea    0x1(%eax),%edx
80108c70:	89 d0                	mov    %edx,%eax
80108c72:	c1 f8 1f             	sar    $0x1f,%eax
80108c75:	c1 e8 1d             	shr    $0x1d,%eax
80108c78:	01 c2                	add    %eax,%edx
80108c7a:	83 e2 07             	and    $0x7,%edx
80108c7d:	29 c2                	sub    %eax,%edx
80108c7f:	89 d0                	mov    %edx,%eax
80108c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    myproc()->cq[i].va=myproc()->cq[next].va;
80108c84:	e8 17 b8 ff ff       	call   801044a0 <myproc>
80108c89:	89 c6                	mov    %eax,%esi
80108c8b:	e8 10 b8 ff ff       	call   801044a0 <myproc>
80108c90:	89 c3                	mov    %eax,%ebx
80108c92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108c95:	89 d0                	mov    %edx,%eax
80108c97:	01 c0                	add    %eax,%eax
80108c99:	01 d0                	add    %edx,%eax
80108c9b:	c1 e0 02             	shl    $0x2,%eax
80108c9e:	01 f0                	add    %esi,%eax
80108ca0:	83 e8 80             	sub    $0xffffff80,%eax
80108ca3:	8b 08                	mov    (%eax),%ecx
80108ca5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108ca8:	89 d0                	mov    %edx,%eax
80108caa:	01 c0                	add    %eax,%eax
80108cac:	01 d0                	add    %edx,%eax
80108cae:	c1 e0 02             	shl    $0x2,%eax
80108cb1:	01 d8                	add    %ebx,%eax
80108cb3:	83 e8 80             	sub    $0xffffff80,%eax
80108cb6:	89 08                	mov    %ecx,(%eax)
    myproc()->cq[i].pte=myproc()->cq[next].pte;
80108cb8:	e8 e3 b7 ff ff       	call   801044a0 <myproc>
80108cbd:	89 c6                	mov    %eax,%esi
80108cbf:	e8 dc b7 ff ff       	call   801044a0 <myproc>
80108cc4:	89 c3                	mov    %eax,%ebx
80108cc6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108cc9:	89 d0                	mov    %edx,%eax
80108ccb:	01 c0                	add    %eax,%eax
80108ccd:	01 d0                	add    %edx,%eax
80108ccf:	c1 e0 02             	shl    $0x2,%eax
80108cd2:	01 f0                	add    %esi,%eax
80108cd4:	05 84 00 00 00       	add    $0x84,%eax
80108cd9:	8b 08                	mov    (%eax),%ecx
80108cdb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108cde:	89 d0                	mov    %edx,%eax
80108ce0:	01 c0                	add    %eax,%eax
80108ce2:	01 d0                	add    %edx,%eax
80108ce4:	c1 e0 02             	shl    $0x2,%eax
80108ce7:	01 d8                	add    %ebx,%eax
80108ce9:	05 84 00 00 00       	add    $0x84,%eax
80108cee:	89 08                	mov    %ecx,(%eax)
    myproc()->cq[i].empty=myproc()->cq[next].empty;
80108cf0:	e8 ab b7 ff ff       	call   801044a0 <myproc>
80108cf5:	89 c6                	mov    %eax,%esi
80108cf7:	e8 a4 b7 ff ff       	call   801044a0 <myproc>
80108cfc:	89 c3                	mov    %eax,%ebx
80108cfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108d01:	89 d0                	mov    %edx,%eax
80108d03:	01 c0                	add    %eax,%eax
80108d05:	01 d0                	add    %edx,%eax
80108d07:	c1 e0 02             	shl    $0x2,%eax
80108d0a:	01 f0                	add    %esi,%eax
80108d0c:	83 c0 7c             	add    $0x7c,%eax
80108d0f:	8b 08                	mov    (%eax),%ecx
80108d11:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108d14:	89 d0                	mov    %edx,%eax
80108d16:	01 c0                	add    %eax,%eax
80108d18:	01 d0                	add    %edx,%eax
80108d1a:	c1 e0 02             	shl    $0x2,%eax
80108d1d:	01 d8                	add    %ebx,%eax
80108d1f:	83 c0 7c             	add    $0x7c,%eax
80108d22:	89 08                	mov    %ecx,(%eax)
  for(int i=del_i;i!=old_hand;i++){
80108d24:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d2b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80108d2e:	0f 85 36 ff ff ff    	jne    80108c6a <cq_remove+0x72>
  }
  myproc()->cq[old_hand].empty=-1;
80108d34:	e8 67 b7 ff ff       	call   801044a0 <myproc>
80108d39:	89 c1                	mov    %eax,%ecx
80108d3b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108d3e:	89 d0                	mov    %edx,%eax
80108d40:	01 c0                	add    %eax,%eax
80108d42:	01 d0                	add    %edx,%eax
80108d44:	c1 e0 02             	shl    $0x2,%eax
80108d47:	01 c8                	add    %ecx,%eax
80108d49:	83 c0 7c             	add    $0x7c,%eax
80108d4c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  myproc()->clock_hand=myproc()->clock_hand ==0? CLOCKSIZE-1: myproc()->clock_hand-1;
80108d52:	e8 49 b7 ff ff       	call   801044a0 <myproc>
80108d57:	8b 80 dc 00 00 00    	mov    0xdc(%eax),%eax
80108d5d:	85 c0                	test   %eax,%eax
80108d5f:	74 10                	je     80108d71 <cq_remove+0x179>
80108d61:	e8 3a b7 ff ff       	call   801044a0 <myproc>
80108d66:	8b 80 dc 00 00 00    	mov    0xdc(%eax),%eax
80108d6c:	8d 58 ff             	lea    -0x1(%eax),%ebx
80108d6f:	eb 05                	jmp    80108d76 <cq_remove+0x17e>
80108d71:	bb 07 00 00 00       	mov    $0x7,%ebx
80108d76:	e8 25 b7 ff ff       	call   801044a0 <myproc>
80108d7b:	89 98 dc 00 00 00    	mov    %ebx,0xdc(%eax)
  return;
80108d81:	eb 01                	jmp    80108d84 <cq_remove+0x18c>
  if(del_i==-1) return;
80108d83:	90                   	nop
}
80108d84:	83 c4 20             	add    $0x20,%esp
80108d87:	5b                   	pop    %ebx
80108d88:	5e                   	pop    %esi
80108d89:	5d                   	pop    %ebp
80108d8a:	c3                   	ret    

80108d8b <mdecrypt>:

//end

//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108d8b:	f3 0f 1e fb          	endbr32 
80108d8f:	55                   	push   %ebp
80108d90:	89 e5                	mov    %esp,%ebp
80108d92:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  char *tmp=virtual_addr;
80108d95:	8b 45 08             	mov    0x8(%ebp),%eax
80108d98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((uint)virtual_addr>=2147483648) return -1;
80108d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d9e:	85 c0                	test   %eax,%eax
80108da0:	79 0a                	jns    80108dac <mdecrypt+0x21>
80108da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108da7:	e9 c4 00 00 00       	jmp    80108e70 <mdecrypt+0xe5>
  struct proc * p = myproc();
80108dac:	e8 ef b6 ff ff       	call   801044a0 <myproc>
80108db1:	89 45 e8             	mov    %eax,-0x18(%ebp)

  pde_t* mypd = p->pgdir;
80108db4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108db7:	8b 40 04             	mov    0x4(%eax),%eax
80108dba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108dbd:	83 ec 04             	sub    $0x4,%esp
80108dc0:	6a 00                	push   $0x0
80108dc2:	ff 75 08             	pushl  0x8(%ebp)
80108dc5:	ff 75 e4             	pushl  -0x1c(%ebp)
80108dc8:	e8 b5 f1 ff ff       	call   80107f82 <walkpgdir>
80108dcd:	83 c4 10             	add    $0x10,%esp
80108dd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!pte || *pte == 0) {
80108dd3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108dd7:	74 09                	je     80108de2 <mdecrypt+0x57>
80108dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ddc:	8b 00                	mov    (%eax),%eax
80108dde:	85 c0                	test   %eax,%eax
80108de0:	75 0a                	jne    80108dec <mdecrypt+0x61>
    return -1;
80108de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108de7:	e9 84 00 00 00       	jmp    80108e70 <mdecrypt+0xe5>
  }

  *pte = *pte & ~PTE_E;
80108dec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108def:	8b 00                	mov    (%eax),%eax
80108df1:	80 e4 fb             	and    $0xfb,%ah
80108df4:	89 c2                	mov    %eax,%edx
80108df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108df9:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108dfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dfe:	8b 00                	mov    (%eax),%eax
80108e00:	83 c8 01             	or     $0x1,%eax
80108e03:	89 c2                	mov    %eax,%edx
80108e05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e08:	89 10                	mov    %edx,(%eax)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108e0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e12:	89 45 08             	mov    %eax,0x8(%ebp)

  char * slider = virtual_addr;
80108e15:	8b 45 08             	mov    0x8(%ebp),%eax
80108e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108e1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e22:	eb 17                	jmp    80108e3b <mdecrypt+0xb0>
    *slider = ~*slider;
80108e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e27:	0f b6 00             	movzbl (%eax),%eax
80108e2a:	f7 d0                	not    %eax
80108e2c:	89 c2                	mov    %eax,%edx
80108e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e31:	88 10                	mov    %dl,(%eax)
    slider++;
80108e33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108e37:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e3b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108e42:	7e e0                	jle    80108e24 <mdecrypt+0x99>
  }
  if(cq_enset(tmp)) return -1;
80108e44:	83 ec 0c             	sub    $0xc,%esp
80108e47:	ff 75 ec             	pushl  -0x14(%ebp)
80108e4a:	e8 a0 fb ff ff       	call   801089ef <cq_enset>
80108e4f:	83 c4 10             	add    $0x10,%esp
80108e52:	85 c0                	test   %eax,%eax
80108e54:	74 07                	je     80108e5d <mdecrypt+0xd2>
80108e56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e5b:	eb 13                	jmp    80108e70 <mdecrypt+0xe5>
  switchuvm(p);
80108e5d:	83 ec 0c             	sub    $0xc,%esp
80108e60:	ff 75 e8             	pushl  -0x18(%ebp)
80108e63:	e8 46 f3 ff ff       	call   801081ae <switchuvm>
80108e68:	83 c4 10             	add    $0x10,%esp
  return 0;
80108e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e70:	c9                   	leave  
80108e71:	c3                   	ret    

80108e72 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108e72:	f3 0f 1e fb          	endbr32 
80108e76:	55                   	push   %ebp
80108e77:	89 e5                	mov    %esp,%ebp
80108e79:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108e7c:	e8 1f b6 ff ff       	call   801044a0 <myproc>
80108e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e87:	8b 40 04             	mov    0x4(%eax),%eax
80108e8a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e95:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108e98:	8b 45 08             	mov    0x8(%ebp),%eax
80108e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108e9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ea5:	eb 2f                	jmp    80108ed6 <mencrypt+0x64>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108ea7:	83 ec 08             	sub    $0x8,%esp
80108eaa:	ff 75 f4             	pushl  -0xc(%ebp)
80108ead:	ff 75 e0             	pushl  -0x20(%ebp)
80108eb0:	e8 c2 f9 ff ff       	call   80108877 <uva2ka>
80108eb5:	83 c4 10             	add    $0x10,%esp
80108eb8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108ebb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108ebf:	75 0a                	jne    80108ecb <mencrypt+0x59>
      // cprintf("mencrypt: Could not access address\n");
      return -1;
80108ec1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ec6:	e9 b8 00 00 00       	jmp    80108f83 <mencrypt+0x111>
    }
    slider = slider + PGSIZE;
80108ecb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108ed2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ed9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108edc:	7c c9                	jl     80108ea7 <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108ede:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108ee4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108eeb:	eb 78                	jmp    80108f65 <mencrypt+0xf3>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108eed:	83 ec 04             	sub    $0x4,%esp
80108ef0:	6a 00                	push   $0x0
80108ef2:	ff 75 f4             	pushl  -0xc(%ebp)
80108ef5:	ff 75 e0             	pushl  -0x20(%ebp)
80108ef8:	e8 85 f0 ff ff       	call   80107f82 <walkpgdir>
80108efd:	83 c4 10             	add    $0x10,%esp
80108f00:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
80108f03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f06:	8b 00                	mov    (%eax),%eax
80108f08:	25 00 04 00 00       	and    $0x400,%eax
80108f0d:	85 c0                	test   %eax,%eax
80108f0f:	74 09                	je     80108f1a <mencrypt+0xa8>
      slider += PGSIZE;
80108f11:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108f18:	eb 47                	jmp    80108f61 <mencrypt+0xef>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108f1a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108f21:	eb 17                	jmp    80108f3a <mencrypt+0xc8>
      *slider = ~*slider;
80108f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f26:	0f b6 00             	movzbl (%eax),%eax
80108f29:	f7 d0                	not    %eax
80108f2b:	89 c2                	mov    %eax,%edx
80108f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f30:	88 10                	mov    %dl,(%eax)
      slider++;
80108f32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108f36:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108f3a:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108f41:	7e e0                	jle    80108f23 <mencrypt+0xb1>
    }
    *mypte = *mypte & ~PTE_P;
80108f43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f46:	8b 00                	mov    (%eax),%eax
80108f48:	83 e0 fe             	and    $0xfffffffe,%eax
80108f4b:	89 c2                	mov    %eax,%edx
80108f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f50:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
80108f52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f55:	8b 00                	mov    (%eax),%eax
80108f57:	80 cc 04             	or     $0x4,%ah
80108f5a:	89 c2                	mov    %eax,%edx
80108f5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f5f:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
80108f61:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f68:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f6b:	7c 80                	jl     80108eed <mencrypt+0x7b>
  }

  switchuvm(myproc());
80108f6d:	e8 2e b5 ff ff       	call   801044a0 <myproc>
80108f72:	83 ec 0c             	sub    $0xc,%esp
80108f75:	50                   	push   %eax
80108f76:	e8 33 f2 ff ff       	call   801081ae <switchuvm>
80108f7b:	83 c4 10             	add    $0x10,%esp
  return 0;
80108f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f83:	c9                   	leave  
80108f84:	c3                   	ret    

80108f85 <pet_in_set>:
//p6 melody changes
int pet_in_set(pte_t *pte){
80108f85:	f3 0f 1e fb          	endbr32 
80108f89:	55                   	push   %ebp
80108f8a:	89 e5                	mov    %esp,%ebp
  if(!pte) return 0;
80108f8c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108f90:	75 07                	jne    80108f99 <pet_in_set+0x14>
80108f92:	b8 00 00 00 00       	mov    $0x0,%eax
80108f97:	eb 24                	jmp    80108fbd <pet_in_set+0x38>
  // cprintf("inset:pte:%x p:%d e:%d\n",*pte,(*pte & PTE_P),(*pte & !PTE_E));
  if((*pte & PTE_P)&&(*pte & ~PTE_E)) return 1;
80108f99:	8b 45 08             	mov    0x8(%ebp),%eax
80108f9c:	8b 00                	mov    (%eax),%eax
80108f9e:	83 e0 01             	and    $0x1,%eax
80108fa1:	85 c0                	test   %eax,%eax
80108fa3:	74 13                	je     80108fb8 <pet_in_set+0x33>
80108fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa8:	8b 00                	mov    (%eax),%eax
80108faa:	80 e4 fb             	and    $0xfb,%ah
80108fad:	85 c0                	test   %eax,%eax
80108faf:	74 07                	je     80108fb8 <pet_in_set+0x33>
80108fb1:	b8 01 00 00 00       	mov    $0x1,%eax
80108fb6:	eb 05                	jmp    80108fbd <pet_in_set+0x38>
  return 0;
80108fb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fbd:	5d                   	pop    %ebp
80108fbe:	c3                   	ret    

80108fbf <getpgtable>:
//end
int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
80108fbf:	f3 0f 1e fb          	endbr32 
80108fc3:	55                   	push   %ebp
80108fc4:	89 e5                	mov    %esp,%ebp
80108fc6:	83 ec 18             	sub    $0x18,%esp
  //p6 melody changes
  if(wsetOnly!=0 && wsetOnly!=1) return -1;
80108fc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108fcd:	74 10                	je     80108fdf <getpgtable+0x20>
80108fcf:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
80108fd3:	74 0a                	je     80108fdf <getpgtable+0x20>
80108fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fda:	e9 42 02 00 00       	jmp    80109221 <getpgtable+0x262>
  //
  struct proc * me = myproc();
80108fdf:	e8 bc b4 ff ff       	call   801044a0 <myproc>
80108fe4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  int index = 0;
80108fe7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t * curr_pte;
  //reverse order

  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80108fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ff1:	8b 00                	mov    (%eax),%eax
80108ff3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ff8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ffb:	e9 0f 02 00 00       	jmp    8010920f <getpgtable+0x250>
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags
    if(i==0) break;
80109000:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109004:	0f 84 13 02 00 00    	je     8010921d <getpgtable+0x25e>
    curr_pte = walkpgdir(me->pgdir, i, 0);
8010900a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010900d:	8b 40 04             	mov    0x4(%eax),%eax
80109010:	83 ec 04             	sub    $0x4,%esp
80109013:	6a 00                	push   $0x0
80109015:	ff 75 f0             	pushl  -0x10(%ebp)
80109018:	50                   	push   %eax
80109019:	e8 64 ef ff ff       	call   80107f82 <walkpgdir>
8010901e:	83 c4 10             	add    $0x10,%esp
80109021:	89 45 e8             	mov    %eax,-0x18(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if (curr_pte && *curr_pte) {//this page is allocated
80109024:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109028:	0f 84 da 01 00 00    	je     80109208 <getpgtable+0x249>
8010902e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109031:	8b 00                	mov    (%eax),%eax
80109033:	85 c0                	test   %eax,%eax
80109035:	0f 84 cd 01 00 00    	je     80109208 <getpgtable+0x249>
      //this is the same for all pt_entries... right?
      if(!wsetOnly||(wsetOnly&&pet_in_set(curr_pte))){
8010903b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010903f:	74 20                	je     80109061 <getpgtable+0xa2>
80109041:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109045:	0f 84 bd 01 00 00    	je     80109208 <getpgtable+0x249>
8010904b:	83 ec 0c             	sub    $0xc,%esp
8010904e:	ff 75 e8             	pushl  -0x18(%ebp)
80109051:	e8 2f ff ff ff       	call   80108f85 <pet_in_set>
80109056:	83 c4 10             	add    $0x10,%esp
80109059:	85 c0                	test   %eax,%eax
8010905b:	0f 84 a7 01 00 00    	je     80109208 <getpgtable+0x249>
        entries[index].pdx = PDX(i); 
80109061:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109064:	c1 e8 16             	shr    $0x16,%eax
80109067:	89 c1                	mov    %eax,%ecx
80109069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109073:	8b 45 08             	mov    0x8(%ebp),%eax
80109076:	01 c2                	add    %eax,%edx
80109078:	89 c8                	mov    %ecx,%eax
8010907a:	66 25 ff 03          	and    $0x3ff,%ax
8010907e:	66 25 ff 03          	and    $0x3ff,%ax
80109082:	89 c1                	mov    %eax,%ecx
80109084:	0f b7 02             	movzwl (%edx),%eax
80109087:	66 25 00 fc          	and    $0xfc00,%ax
8010908b:	09 c8                	or     %ecx,%eax
8010908d:	66 89 02             	mov    %ax,(%edx)
        entries[index].ptx = PTX(i);
80109090:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109093:	c1 e8 0c             	shr    $0xc,%eax
80109096:	89 c1                	mov    %eax,%ecx
80109098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801090a2:	8b 45 08             	mov    0x8(%ebp),%eax
801090a5:	01 c2                	add    %eax,%edx
801090a7:	89 c8                	mov    %ecx,%eax
801090a9:	66 25 ff 03          	and    $0x3ff,%ax
801090ad:	0f b7 c0             	movzwl %ax,%eax
801090b0:	25 ff 03 00 00       	and    $0x3ff,%eax
801090b5:	c1 e0 0a             	shl    $0xa,%eax
801090b8:	89 c1                	mov    %eax,%ecx
801090ba:	8b 02                	mov    (%edx),%eax
801090bc:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
801090c1:	09 c8                	or     %ecx,%eax
801090c3:	89 02                	mov    %eax,(%edx)
        //convert to physical addr then shift to get PPN 
        entries[index].ppage = PPN(*curr_pte);
801090c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090c8:	8b 00                	mov    (%eax),%eax
801090ca:	c1 e8 0c             	shr    $0xc,%eax
801090cd:	89 c2                	mov    %eax,%edx
801090cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d2:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801090d9:	8b 45 08             	mov    0x8(%ebp),%eax
801090dc:	01 c8                	add    %ecx,%eax
801090de:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801090e4:	89 d1                	mov    %edx,%ecx
801090e6:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801090ec:	8b 50 04             	mov    0x4(%eax),%edx
801090ef:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801090f5:	09 ca                	or     %ecx,%edx
801090f7:	89 50 04             	mov    %edx,0x4(%eax)
        //have to set it like this because these are 1 bit wide fields
        entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
801090fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090fd:	8b 08                	mov    (%eax),%ecx
801090ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109102:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109109:	8b 45 08             	mov    0x8(%ebp),%eax
8010910c:	01 c2                	add    %eax,%edx
8010910e:	89 c8                	mov    %ecx,%eax
80109110:	83 e0 01             	and    $0x1,%eax
80109113:	83 e0 01             	and    $0x1,%eax
80109116:	c1 e0 04             	shl    $0x4,%eax
80109119:	89 c1                	mov    %eax,%ecx
8010911b:	0f b6 42 06          	movzbl 0x6(%edx),%eax
8010911f:	83 e0 ef             	and    $0xffffffef,%eax
80109122:	09 c8                	or     %ecx,%eax
80109124:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
80109127:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010912a:	8b 00                	mov    (%eax),%eax
8010912c:	d1 e8                	shr    %eax
8010912e:	89 c1                	mov    %eax,%ecx
80109130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109133:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010913a:	8b 45 08             	mov    0x8(%ebp),%eax
8010913d:	01 c2                	add    %eax,%edx
8010913f:	89 c8                	mov    %ecx,%eax
80109141:	83 e0 01             	and    $0x1,%eax
80109144:	83 e0 01             	and    $0x1,%eax
80109147:	c1 e0 05             	shl    $0x5,%eax
8010914a:	89 c1                	mov    %eax,%ecx
8010914c:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109150:	83 e0 df             	and    $0xffffffdf,%eax
80109153:	09 c8                	or     %ecx,%eax
80109155:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].user=(*curr_pte&PTE_U) ? 1:0;
80109158:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010915b:	8b 00                	mov    (%eax),%eax
8010915d:	c1 e8 02             	shr    $0x2,%eax
80109160:	89 c1                	mov    %eax,%ecx
80109162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109165:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010916c:	8b 45 08             	mov    0x8(%ebp),%eax
8010916f:	01 c2                	add    %eax,%edx
80109171:	89 c8                	mov    %ecx,%eax
80109173:	83 e0 01             	and    $0x1,%eax
80109176:	c1 e0 07             	shl    $0x7,%eax
80109179:	89 c1                	mov    %eax,%ecx
8010917b:	0f b6 42 06          	movzbl 0x6(%edx),%eax
8010917f:	83 e0 7f             	and    $0x7f,%eax
80109182:	09 c8                	or     %ecx,%eax
80109184:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
80109187:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010918a:	8b 00                	mov    (%eax),%eax
8010918c:	c1 e8 0a             	shr    $0xa,%eax
8010918f:	89 c1                	mov    %eax,%ecx
80109191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109194:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010919b:	8b 45 08             	mov    0x8(%ebp),%eax
8010919e:	01 c2                	add    %eax,%edx
801091a0:	89 c8                	mov    %ecx,%eax
801091a2:	83 e0 01             	and    $0x1,%eax
801091a5:	83 e0 01             	and    $0x1,%eax
801091a8:	c1 e0 06             	shl    $0x6,%eax
801091ab:	89 c1                	mov    %eax,%ecx
801091ad:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801091b1:	83 e0 bf             	and    $0xffffffbf,%eax
801091b4:	09 c8                	or     %ecx,%eax
801091b6:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].ref=!(*curr_pte & PTE_E) && (*curr_pte & PTE_A) ? 1:0;
801091b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091bc:	8b 00                	mov    (%eax),%eax
801091be:	25 00 04 00 00       	and    $0x400,%eax
801091c3:	85 c0                	test   %eax,%eax
801091c5:	75 13                	jne    801091da <getpgtable+0x21b>
801091c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091ca:	8b 00                	mov    (%eax),%eax
801091cc:	83 e0 20             	and    $0x20,%eax
801091cf:	85 c0                	test   %eax,%eax
801091d1:	74 07                	je     801091da <getpgtable+0x21b>
801091d3:	b9 01 00 00 00       	mov    $0x1,%ecx
801091d8:	eb 05                	jmp    801091df <getpgtable+0x220>
801091da:	b9 00 00 00 00       	mov    $0x0,%ecx
801091df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801091e9:	8b 45 08             	mov    0x8(%ebp),%eax
801091ec:	01 c2                	add    %eax,%edx
801091ee:	89 c8                	mov    %ecx,%eax
801091f0:	83 e0 01             	and    $0x1,%eax
801091f3:	83 e0 01             	and    $0x1,%eax
801091f6:	89 c1                	mov    %eax,%ecx
801091f8:	0f b6 42 07          	movzbl 0x7(%edx),%eax
801091fc:	83 e0 fe             	and    $0xfffffffe,%eax
801091ff:	09 c8                	or     %ecx,%eax
80109201:	88 42 07             	mov    %al,0x7(%edx)
        index++;
80109204:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80109208:	81 6d f0 00 10 00 00 	subl   $0x1000,-0x10(%ebp)
8010920f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109212:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109215:	0f 8c e5 fd ff ff    	jl     80109000 <getpgtable+0x41>
8010921b:	eb 01                	jmp    8010921e <getpgtable+0x25f>
    if(i==0) break;
8010921d:	90                   	nop
      }
    }
    
  }
  //index is the number of ptes copied
  return index;
8010921e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80109221:	c9                   	leave  
80109222:	c3                   	ret    

80109223 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
80109223:	f3 0f 1e fb          	endbr32 
80109227:	55                   	push   %ebp
80109228:	89 e5                	mov    %esp,%ebp
8010922a:	56                   	push   %esi
8010922b:	53                   	push   %ebx
8010922c:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  *buffer = *buffer;
8010922f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109232:	0f b6 10             	movzbl (%eax),%edx
80109235:	8b 45 0c             	mov    0xc(%ebp),%eax
80109238:	88 10                	mov    %dl,(%eax)
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
8010923a:	8b 45 08             	mov    0x8(%ebp),%eax
8010923d:	05 00 00 00 80       	add    $0x80000000,%eax
80109242:	89 c6                	mov    %eax,%esi
80109244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80109247:	e8 54 b2 ff ff       	call   801044a0 <myproc>
8010924c:	8b 40 04             	mov    0x4(%eax),%eax
8010924f:	68 00 10 00 00       	push   $0x1000
80109254:	56                   	push   %esi
80109255:	53                   	push   %ebx
80109256:	50                   	push   %eax
80109257:	e8 74 f6 ff ff       	call   801088d0 <copyout>
8010925c:	83 c4 10             	add    $0x10,%esp
8010925f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109262:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109266:	74 07                	je     8010926f <dump_rawphymem+0x4c>
    return -1;
80109268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010926d:	eb 05                	jmp    80109274 <dump_rawphymem+0x51>
  return 0;
8010926f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109274:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109277:	5b                   	pop    %ebx
80109278:	5e                   	pop    %esi
80109279:	5d                   	pop    %ebp
8010927a:	c3                   	ret    
