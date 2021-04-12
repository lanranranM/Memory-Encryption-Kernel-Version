
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
8010002d:	b8 15 3a 10 80       	mov    $0x80103a15,%eax
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
80100041:	68 70 8c 10 80       	push   $0x80108c70
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 be 51 00 00       	call   8010520e <initlock>
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
8010008f:	68 77 8c 10 80       	push   $0x80108c77
80100094:	50                   	push   %eax
80100095:	e8 e1 4f 00 00       	call   8010507b <initsleeplock>
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
801000d7:	e8 58 51 00 00       	call   80105234 <acquire>
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
80100116:	e8 8b 51 00 00       	call   801052a6 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 8e 4f 00 00       	call   801050bb <acquiresleep>
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
80100197:	e8 0a 51 00 00       	call   801052a6 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 0d 4f 00 00       	call   801050bb <acquiresleep>
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
801001cb:	68 7e 8c 10 80       	push   $0x80108c7e
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
80100207:	e8 8e 28 00 00       	call   80102a9a <iderw>
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
80100228:	e8 48 4f 00 00       	call   80105175 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 8f 8c 10 80       	push   $0x80108c8f
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
80100256:	e8 3f 28 00 00       	call   80102a9a <iderw>
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
80100275:	e8 fb 4e 00 00       	call   80105175 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 96 8c 10 80       	push   $0x80108c96
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 86 4e 00 00       	call   80105123 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 87 4f 00 00       	call   80105234 <acquire>
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
80100318:	e8 89 4f 00 00       	call   801052a6 <release>
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
80100438:	e8 3e 4f 00 00       	call   8010537b <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 e3 4d 00 00       	call   80105234 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 a0 8c 10 80       	push   $0x80108ca0
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
801004ee:	8b 04 85 b0 8c 10 80 	mov    -0x7fef7350(,%eax,4),%eax
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
8010054c:	c7 45 ec a9 8c 10 80 	movl   $0x80108ca9,-0x14(%ebp)
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
801005fd:	e8 a4 4c 00 00       	call   801052a6 <release>
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
80100621:	e8 40 2b 00 00       	call   80103166 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 08 8d 10 80       	push   $0x80108d08
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
80100649:	68 1c 8d 10 80       	push   $0x80108d1c
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 96 4c 00 00       	call   801052fc <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 1e 8d 10 80       	push   $0x80108d1e
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
80100772:	68 22 8d 10 80       	push   $0x80108d22
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
8010079f:	e8 f6 4d 00 00       	call   8010559a <memmove>
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
801007c9:	e8 05 4d 00 00       	call   801054d3 <memset>
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
80100865:	e8 65 67 00 00       	call   80106fcf <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 58 67 00 00       	call   80106fcf <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 4b 67 00 00       	call   80106fcf <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 3b 67 00 00       	call   80106fcf <uartputc>
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
801008c1:	e8 6e 49 00 00       	call   80105234 <acquire>
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
80100a17:	e8 9e 44 00 00       	call   80104eba <wakeup>
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
80100a3a:	e8 67 48 00 00       	call   801052a6 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 30 45 00 00       	call   80104f7d <procdump>
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
80100a60:	e8 bb 11 00 00       	call   80101c20 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 b9 47 00 00       	call   80105234 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 0f 3a 00 00       	call   80104497 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 0a 48 00 00       	call   801052a6 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 5f 10 00 00       	call   80101b09 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 02 43 00 00       	call   80104dcb <sleep>
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
80100b42:	e8 5f 47 00 00       	call   801052a6 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 b4 0f 00 00       	call   80101b09 <ilock>
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
80100b74:	e8 a7 10 00 00       	call   80101c20 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 ab 46 00 00       	call   80105234 <acquire>
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
80100bc6:	e8 db 46 00 00       	call   801052a6 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 30 0f 00 00       	call   80101b09 <ilock>
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
80100bee:	68 35 8d 10 80       	push   $0x80108d35
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 11 46 00 00       	call   8010520e <initlock>
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
80100c25:	e8 49 20 00 00       	call   80102c73 <ioapicenable>
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
80100c3d:	e8 55 38 00 00       	call   80104497 <myproc>
80100c42:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c45:	e8 8e 2a 00 00       	call   801036d8 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 1f 1a 00 00       	call   80102674 <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 02 2b 00 00       	call   80103768 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 3d 8d 10 80       	push   $0x80108d3d
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 1f 04 00 00       	jmp    8010109f <exec+0x46f>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 7e 0e 00 00       	call   80101b09 <ilock>
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
80100ca3:	e8 69 13 00 00       	call   80102011 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 94 03 00 00    	jne    80101048 <exec+0x418>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 86 03 00 00    	jne    8010104b <exec+0x41b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 41 73 00 00       	call   8010800b <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 77 03 00 00    	je     8010104e <exec+0x41e>
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
80100d03:	e8 09 13 00 00       	call   80102011 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 3d 03 00 00    	jne    80101051 <exec+0x421>
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
80100d31:	0f 82 1d 03 00 00    	jb     80101054 <exec+0x424>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d3d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 04 03 00 00    	jb     80101057 <exec+0x427>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d59:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 59 76 00 00       	call   801083c9 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 da 02 00 00    	je     8010105a <exec+0x42a>
      goto bad;

    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 ca 02 00 00    	jne    8010105d <exec+0x42d>
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
80100db1:	e8 42 75 00 00       	call   801082f8 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 9f 02 00 00    	js     80101060 <exec+0x430>
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
80100dea:	e8 57 0f 00 00       	call   80101d46 <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 71 29 00 00       	call   80103768 <end_op>
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
80100e20:	e8 a4 75 00 00       	call   801083c9 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 2e 02 00 00    	je     80101063 <exec+0x433>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 f0 77 00 00       	call   80108639 <clearpteu>
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
80100e62:	0f 87 fe 01 00 00    	ja     80101066 <exec+0x436>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 ba 48 00 00       	call   8010573c <strlen>
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
80100eaa:	e8 8d 48 00 00       	call   8010573c <strlen>
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
80100ed0:	e8 20 79 00 00       	call   801087f5 <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 89 01 00 00    	js     80101069 <exec+0x439>
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
80100f6c:	e8 84 78 00 00       	call   801087f5 <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 f0 00 00 00    	js     8010106c <exec+0x43c>
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
80100fba:	e8 2f 47 00 00       	call   801056ee <safestrcpy>
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
80100ffd:	e8 df 70 00 00       	call   801080e1 <switchuvm>
80101002:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	ff 75 cc             	pushl  -0x34(%ebp)
8010100b:	e8 8c 75 00 00       	call   8010859c <freevm>
80101010:	83 c4 10             	add    $0x10,%esp
  //p5 melody changes
  uint page_num=1;
80101013:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  //cprintf("exec-page_num:%d\n",page_num);
  if(mencrypt((char*)PGROUNDUP(sz-PGSIZE),page_num)!=0) return -1;
8010101a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010101d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101020:	83 ea 01             	sub    $0x1,%edx
80101023:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80101029:	83 ec 08             	sub    $0x8,%esp
8010102c:	50                   	push   %eax
8010102d:	52                   	push   %edx
8010102e:	e8 0a 79 00 00       	call   8010893d <mencrypt>
80101033:	83 c4 10             	add    $0x10,%esp
80101036:	85 c0                	test   %eax,%eax
80101038:	74 07                	je     80101041 <exec+0x411>
8010103a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010103f:	eb 5e                	jmp    8010109f <exec+0x46f>
  //ends
  return 0;
80101041:	b8 00 00 00 00       	mov    $0x0,%eax
80101046:	eb 57                	jmp    8010109f <exec+0x46f>
    goto bad;
80101048:	90                   	nop
80101049:	eb 22                	jmp    8010106d <exec+0x43d>
    goto bad;
8010104b:	90                   	nop
8010104c:	eb 1f                	jmp    8010106d <exec+0x43d>
    goto bad;
8010104e:	90                   	nop
8010104f:	eb 1c                	jmp    8010106d <exec+0x43d>
      goto bad;
80101051:	90                   	nop
80101052:	eb 19                	jmp    8010106d <exec+0x43d>
      goto bad;
80101054:	90                   	nop
80101055:	eb 16                	jmp    8010106d <exec+0x43d>
      goto bad;
80101057:	90                   	nop
80101058:	eb 13                	jmp    8010106d <exec+0x43d>
      goto bad;
8010105a:	90                   	nop
8010105b:	eb 10                	jmp    8010106d <exec+0x43d>
      goto bad;
8010105d:	90                   	nop
8010105e:	eb 0d                	jmp    8010106d <exec+0x43d>
      goto bad;
80101060:	90                   	nop
80101061:	eb 0a                	jmp    8010106d <exec+0x43d>
    goto bad;
80101063:	90                   	nop
80101064:	eb 07                	jmp    8010106d <exec+0x43d>
      goto bad;
80101066:	90                   	nop
80101067:	eb 04                	jmp    8010106d <exec+0x43d>
      goto bad;
80101069:	90                   	nop
8010106a:	eb 01                	jmp    8010106d <exec+0x43d>
    goto bad;
8010106c:	90                   	nop

 bad:
  if(pgdir)
8010106d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101071:	74 0e                	je     80101081 <exec+0x451>
    freevm(pgdir);
80101073:	83 ec 0c             	sub    $0xc,%esp
80101076:	ff 75 d4             	pushl  -0x2c(%ebp)
80101079:	e8 1e 75 00 00       	call   8010859c <freevm>
8010107e:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101081:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101085:	74 13                	je     8010109a <exec+0x46a>
    iunlockput(ip);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	ff 75 d8             	pushl  -0x28(%ebp)
8010108d:	e8 b4 0c 00 00       	call   80101d46 <iunlockput>
80101092:	83 c4 10             	add    $0x10,%esp
    end_op();
80101095:	e8 ce 26 00 00       	call   80103768 <end_op>
  }
  return -1;
8010109a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010109f:	c9                   	leave  
801010a0:	c3                   	ret    

801010a1 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010a1:	f3 0f 1e fb          	endbr32 
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010ab:	83 ec 08             	sub    $0x8,%esp
801010ae:	68 49 8d 10 80       	push   $0x80108d49
801010b3:	68 60 20 11 80       	push   $0x80112060
801010b8:	e8 51 41 00 00       	call   8010520e <initlock>
801010bd:	83 c4 10             	add    $0x10,%esp
}
801010c0:	90                   	nop
801010c1:	c9                   	leave  
801010c2:	c3                   	ret    

801010c3 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010c3:	f3 0f 1e fb          	endbr32 
801010c7:	55                   	push   %ebp
801010c8:	89 e5                	mov    %esp,%ebp
801010ca:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010cd:	83 ec 0c             	sub    $0xc,%esp
801010d0:	68 60 20 11 80       	push   $0x80112060
801010d5:	e8 5a 41 00 00       	call   80105234 <acquire>
801010da:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010dd:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
801010e4:	eb 2d                	jmp    80101113 <filealloc+0x50>
    if(f->ref == 0){
801010e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010e9:	8b 40 04             	mov    0x4(%eax),%eax
801010ec:	85 c0                	test   %eax,%eax
801010ee:	75 1f                	jne    8010110f <filealloc+0x4c>
      f->ref = 1;
801010f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010fa:	83 ec 0c             	sub    $0xc,%esp
801010fd:	68 60 20 11 80       	push   $0x80112060
80101102:	e8 9f 41 00 00       	call   801052a6 <release>
80101107:	83 c4 10             	add    $0x10,%esp
      return f;
8010110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110d:	eb 23                	jmp    80101132 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010110f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101113:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
80101118:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010111b:	72 c9                	jb     801010e6 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010111d:	83 ec 0c             	sub    $0xc,%esp
80101120:	68 60 20 11 80       	push   $0x80112060
80101125:	e8 7c 41 00 00       	call   801052a6 <release>
8010112a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010112d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101132:	c9                   	leave  
80101133:	c3                   	ret    

80101134 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101134:	f3 0f 1e fb          	endbr32 
80101138:	55                   	push   %ebp
80101139:	89 e5                	mov    %esp,%ebp
8010113b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010113e:	83 ec 0c             	sub    $0xc,%esp
80101141:	68 60 20 11 80       	push   $0x80112060
80101146:	e8 e9 40 00 00       	call   80105234 <acquire>
8010114b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010114e:	8b 45 08             	mov    0x8(%ebp),%eax
80101151:	8b 40 04             	mov    0x4(%eax),%eax
80101154:	85 c0                	test   %eax,%eax
80101156:	7f 0d                	jg     80101165 <filedup+0x31>
    panic("filedup");
80101158:	83 ec 0c             	sub    $0xc,%esp
8010115b:	68 50 8d 10 80       	push   $0x80108d50
80101160:	e8 a3 f4 ff ff       	call   80100608 <panic>
  f->ref++;
80101165:	8b 45 08             	mov    0x8(%ebp),%eax
80101168:	8b 40 04             	mov    0x4(%eax),%eax
8010116b:	8d 50 01             	lea    0x1(%eax),%edx
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101174:	83 ec 0c             	sub    $0xc,%esp
80101177:	68 60 20 11 80       	push   $0x80112060
8010117c:	e8 25 41 00 00       	call   801052a6 <release>
80101181:	83 c4 10             	add    $0x10,%esp
  return f;
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101187:	c9                   	leave  
80101188:	c3                   	ret    

80101189 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101189:	f3 0f 1e fb          	endbr32 
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101193:	83 ec 0c             	sub    $0xc,%esp
80101196:	68 60 20 11 80       	push   $0x80112060
8010119b:	e8 94 40 00 00       	call   80105234 <acquire>
801011a0:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
801011a6:	8b 40 04             	mov    0x4(%eax),%eax
801011a9:	85 c0                	test   %eax,%eax
801011ab:	7f 0d                	jg     801011ba <fileclose+0x31>
    panic("fileclose");
801011ad:	83 ec 0c             	sub    $0xc,%esp
801011b0:	68 58 8d 10 80       	push   $0x80108d58
801011b5:	e8 4e f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 04             	mov    0x4(%eax),%eax
801011c0:	8d 50 ff             	lea    -0x1(%eax),%edx
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	89 50 04             	mov    %edx,0x4(%eax)
801011c9:	8b 45 08             	mov    0x8(%ebp),%eax
801011cc:	8b 40 04             	mov    0x4(%eax),%eax
801011cf:	85 c0                	test   %eax,%eax
801011d1:	7e 15                	jle    801011e8 <fileclose+0x5f>
    release(&ftable.lock);
801011d3:	83 ec 0c             	sub    $0xc,%esp
801011d6:	68 60 20 11 80       	push   $0x80112060
801011db:	e8 c6 40 00 00       	call   801052a6 <release>
801011e0:	83 c4 10             	add    $0x10,%esp
801011e3:	e9 8b 00 00 00       	jmp    80101273 <fileclose+0xea>
    return;
  }
  ff = *f;
801011e8:	8b 45 08             	mov    0x8(%ebp),%eax
801011eb:	8b 10                	mov    (%eax),%edx
801011ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011f0:	8b 50 04             	mov    0x4(%eax),%edx
801011f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011f6:	8b 50 08             	mov    0x8(%eax),%edx
801011f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011fc:	8b 50 0c             	mov    0xc(%eax),%edx
801011ff:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101202:	8b 50 10             	mov    0x10(%eax),%edx
80101205:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101208:	8b 40 14             	mov    0x14(%eax),%eax
8010120b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010120e:	8b 45 08             	mov    0x8(%ebp),%eax
80101211:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101218:	8b 45 08             	mov    0x8(%ebp),%eax
8010121b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101221:	83 ec 0c             	sub    $0xc,%esp
80101224:	68 60 20 11 80       	push   $0x80112060
80101229:	e8 78 40 00 00       	call   801052a6 <release>
8010122e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101231:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101234:	83 f8 01             	cmp    $0x1,%eax
80101237:	75 19                	jne    80101252 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101239:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010123d:	0f be d0             	movsbl %al,%edx
80101240:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101243:	83 ec 08             	sub    $0x8,%esp
80101246:	52                   	push   %edx
80101247:	50                   	push   %eax
80101248:	e8 c1 2e 00 00       	call   8010410e <pipeclose>
8010124d:	83 c4 10             	add    $0x10,%esp
80101250:	eb 21                	jmp    80101273 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101252:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101255:	83 f8 02             	cmp    $0x2,%eax
80101258:	75 19                	jne    80101273 <fileclose+0xea>
    begin_op();
8010125a:	e8 79 24 00 00       	call   801036d8 <begin_op>
    iput(ff.ip);
8010125f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101262:	83 ec 0c             	sub    $0xc,%esp
80101265:	50                   	push   %eax
80101266:	e8 07 0a 00 00       	call   80101c72 <iput>
8010126b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010126e:	e8 f5 24 00 00       	call   80103768 <end_op>
  }
}
80101273:	c9                   	leave  
80101274:	c3                   	ret    

80101275 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101275:	f3 0f 1e fb          	endbr32 
80101279:	55                   	push   %ebp
8010127a:	89 e5                	mov    %esp,%ebp
8010127c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010127f:	8b 45 08             	mov    0x8(%ebp),%eax
80101282:	8b 00                	mov    (%eax),%eax
80101284:	83 f8 02             	cmp    $0x2,%eax
80101287:	75 40                	jne    801012c9 <filestat+0x54>
    ilock(f->ip);
80101289:	8b 45 08             	mov    0x8(%ebp),%eax
8010128c:	8b 40 10             	mov    0x10(%eax),%eax
8010128f:	83 ec 0c             	sub    $0xc,%esp
80101292:	50                   	push   %eax
80101293:	e8 71 08 00 00       	call   80101b09 <ilock>
80101298:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
8010129e:	8b 40 10             	mov    0x10(%eax),%eax
801012a1:	83 ec 08             	sub    $0x8,%esp
801012a4:	ff 75 0c             	pushl  0xc(%ebp)
801012a7:	50                   	push   %eax
801012a8:	e8 1a 0d 00 00       	call   80101fc7 <stati>
801012ad:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012b0:	8b 45 08             	mov    0x8(%ebp),%eax
801012b3:	8b 40 10             	mov    0x10(%eax),%eax
801012b6:	83 ec 0c             	sub    $0xc,%esp
801012b9:	50                   	push   %eax
801012ba:	e8 61 09 00 00       	call   80101c20 <iunlock>
801012bf:	83 c4 10             	add    $0x10,%esp
    return 0;
801012c2:	b8 00 00 00 00       	mov    $0x0,%eax
801012c7:	eb 05                	jmp    801012ce <filestat+0x59>
  }
  return -1;
801012c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012ce:	c9                   	leave  
801012cf:	c3                   	ret    

801012d0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012d0:	f3 0f 1e fb          	endbr32 
801012d4:	55                   	push   %ebp
801012d5:	89 e5                	mov    %esp,%ebp
801012d7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012da:	8b 45 08             	mov    0x8(%ebp),%eax
801012dd:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012e1:	84 c0                	test   %al,%al
801012e3:	75 0a                	jne    801012ef <fileread+0x1f>
    return -1;
801012e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ea:	e9 9b 00 00 00       	jmp    8010138a <fileread+0xba>
  if(f->type == FD_PIPE)
801012ef:	8b 45 08             	mov    0x8(%ebp),%eax
801012f2:	8b 00                	mov    (%eax),%eax
801012f4:	83 f8 01             	cmp    $0x1,%eax
801012f7:	75 1a                	jne    80101313 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 40 0c             	mov    0xc(%eax),%eax
801012ff:	83 ec 04             	sub    $0x4,%esp
80101302:	ff 75 10             	pushl  0x10(%ebp)
80101305:	ff 75 0c             	pushl  0xc(%ebp)
80101308:	50                   	push   %eax
80101309:	e8 b5 2f 00 00       	call   801042c3 <piperead>
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	eb 77                	jmp    8010138a <fileread+0xba>
  if(f->type == FD_INODE){
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	8b 00                	mov    (%eax),%eax
80101318:	83 f8 02             	cmp    $0x2,%eax
8010131b:	75 60                	jne    8010137d <fileread+0xad>
    ilock(f->ip);
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	8b 40 10             	mov    0x10(%eax),%eax
80101323:	83 ec 0c             	sub    $0xc,%esp
80101326:	50                   	push   %eax
80101327:	e8 dd 07 00 00       	call   80101b09 <ilock>
8010132c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010132f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101332:	8b 45 08             	mov    0x8(%ebp),%eax
80101335:	8b 50 14             	mov    0x14(%eax),%edx
80101338:	8b 45 08             	mov    0x8(%ebp),%eax
8010133b:	8b 40 10             	mov    0x10(%eax),%eax
8010133e:	51                   	push   %ecx
8010133f:	52                   	push   %edx
80101340:	ff 75 0c             	pushl  0xc(%ebp)
80101343:	50                   	push   %eax
80101344:	e8 c8 0c 00 00       	call   80102011 <readi>
80101349:	83 c4 10             	add    $0x10,%esp
8010134c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010134f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101353:	7e 11                	jle    80101366 <fileread+0x96>
      f->off += r;
80101355:	8b 45 08             	mov    0x8(%ebp),%eax
80101358:	8b 50 14             	mov    0x14(%eax),%edx
8010135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135e:	01 c2                	add    %eax,%edx
80101360:	8b 45 08             	mov    0x8(%ebp),%eax
80101363:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101366:	8b 45 08             	mov    0x8(%ebp),%eax
80101369:	8b 40 10             	mov    0x10(%eax),%eax
8010136c:	83 ec 0c             	sub    $0xc,%esp
8010136f:	50                   	push   %eax
80101370:	e8 ab 08 00 00       	call   80101c20 <iunlock>
80101375:	83 c4 10             	add    $0x10,%esp
    return r;
80101378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137b:	eb 0d                	jmp    8010138a <fileread+0xba>
  }
  panic("fileread");
8010137d:	83 ec 0c             	sub    $0xc,%esp
80101380:	68 62 8d 10 80       	push   $0x80108d62
80101385:	e8 7e f2 ff ff       	call   80100608 <panic>
}
8010138a:	c9                   	leave  
8010138b:	c3                   	ret    

8010138c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010138c:	f3 0f 1e fb          	endbr32 
80101390:	55                   	push   %ebp
80101391:	89 e5                	mov    %esp,%ebp
80101393:	53                   	push   %ebx
80101394:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101397:	8b 45 08             	mov    0x8(%ebp),%eax
8010139a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010139e:	84 c0                	test   %al,%al
801013a0:	75 0a                	jne    801013ac <filewrite+0x20>
    return -1;
801013a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a7:	e9 1b 01 00 00       	jmp    801014c7 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013ac:	8b 45 08             	mov    0x8(%ebp),%eax
801013af:	8b 00                	mov    (%eax),%eax
801013b1:	83 f8 01             	cmp    $0x1,%eax
801013b4:	75 1d                	jne    801013d3 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013b6:	8b 45 08             	mov    0x8(%ebp),%eax
801013b9:	8b 40 0c             	mov    0xc(%eax),%eax
801013bc:	83 ec 04             	sub    $0x4,%esp
801013bf:	ff 75 10             	pushl  0x10(%ebp)
801013c2:	ff 75 0c             	pushl  0xc(%ebp)
801013c5:	50                   	push   %eax
801013c6:	e8 f2 2d 00 00       	call   801041bd <pipewrite>
801013cb:	83 c4 10             	add    $0x10,%esp
801013ce:	e9 f4 00 00 00       	jmp    801014c7 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	8b 00                	mov    (%eax),%eax
801013d8:	83 f8 02             	cmp    $0x2,%eax
801013db:	0f 85 d9 00 00 00    	jne    801014ba <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013e1:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ef:	e9 a3 00 00 00       	jmp    80101497 <filewrite+0x10b>
      int n1 = n - i;
801013f4:	8b 45 10             	mov    0x10(%ebp),%eax
801013f7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101400:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101403:	7e 06                	jle    8010140b <filewrite+0x7f>
        n1 = max;
80101405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101408:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010140b:	e8 c8 22 00 00       	call   801036d8 <begin_op>
      ilock(f->ip);
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	8b 40 10             	mov    0x10(%eax),%eax
80101416:	83 ec 0c             	sub    $0xc,%esp
80101419:	50                   	push   %eax
8010141a:	e8 ea 06 00 00       	call   80101b09 <ilock>
8010141f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101422:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101425:	8b 45 08             	mov    0x8(%ebp),%eax
80101428:	8b 50 14             	mov    0x14(%eax),%edx
8010142b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010142e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101431:	01 c3                	add    %eax,%ebx
80101433:	8b 45 08             	mov    0x8(%ebp),%eax
80101436:	8b 40 10             	mov    0x10(%eax),%eax
80101439:	51                   	push   %ecx
8010143a:	52                   	push   %edx
8010143b:	53                   	push   %ebx
8010143c:	50                   	push   %eax
8010143d:	e8 28 0d 00 00       	call   8010216a <writei>
80101442:	83 c4 10             	add    $0x10,%esp
80101445:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101448:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010144c:	7e 11                	jle    8010145f <filewrite+0xd3>
        f->off += r;
8010144e:	8b 45 08             	mov    0x8(%ebp),%eax
80101451:	8b 50 14             	mov    0x14(%eax),%edx
80101454:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101457:	01 c2                	add    %eax,%edx
80101459:	8b 45 08             	mov    0x8(%ebp),%eax
8010145c:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010145f:	8b 45 08             	mov    0x8(%ebp),%eax
80101462:	8b 40 10             	mov    0x10(%eax),%eax
80101465:	83 ec 0c             	sub    $0xc,%esp
80101468:	50                   	push   %eax
80101469:	e8 b2 07 00 00       	call   80101c20 <iunlock>
8010146e:	83 c4 10             	add    $0x10,%esp
      end_op();
80101471:	e8 f2 22 00 00       	call   80103768 <end_op>

      if(r < 0)
80101476:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010147a:	78 29                	js     801014a5 <filewrite+0x119>
        break;
      if(r != n1)
8010147c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010147f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101482:	74 0d                	je     80101491 <filewrite+0x105>
        panic("short filewrite");
80101484:	83 ec 0c             	sub    $0xc,%esp
80101487:	68 6b 8d 10 80       	push   $0x80108d6b
8010148c:	e8 77 f1 ff ff       	call   80100608 <panic>
      i += r;
80101491:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101494:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149d:	0f 8c 51 ff ff ff    	jl     801013f4 <filewrite+0x68>
801014a3:	eb 01                	jmp    801014a6 <filewrite+0x11a>
        break;
801014a5:	90                   	nop
    }
    return i == n ? n : -1;
801014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a9:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ac:	75 05                	jne    801014b3 <filewrite+0x127>
801014ae:	8b 45 10             	mov    0x10(%ebp),%eax
801014b1:	eb 14                	jmp    801014c7 <filewrite+0x13b>
801014b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014b8:	eb 0d                	jmp    801014c7 <filewrite+0x13b>
  }
  panic("filewrite");
801014ba:	83 ec 0c             	sub    $0xc,%esp
801014bd:	68 7b 8d 10 80       	push   $0x80108d7b
801014c2:	e8 41 f1 ff ff       	call   80100608 <panic>
}
801014c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014ca:	c9                   	leave  
801014cb:	c3                   	ret    

801014cc <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014cc:	f3 0f 1e fb          	endbr32 
801014d0:	55                   	push   %ebp
801014d1:	89 e5                	mov    %esp,%ebp
801014d3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014d6:	8b 45 08             	mov    0x8(%ebp),%eax
801014d9:	83 ec 08             	sub    $0x8,%esp
801014dc:	6a 01                	push   $0x1
801014de:	50                   	push   %eax
801014df:	e8 f3 ec ff ff       	call   801001d7 <bread>
801014e4:	83 c4 10             	add    $0x10,%esp
801014e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ed:	83 c0 5c             	add    $0x5c,%eax
801014f0:	83 ec 04             	sub    $0x4,%esp
801014f3:	6a 1c                	push   $0x1c
801014f5:	50                   	push   %eax
801014f6:	ff 75 0c             	pushl  0xc(%ebp)
801014f9:	e8 9c 40 00 00       	call   8010559a <memmove>
801014fe:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101501:	83 ec 0c             	sub    $0xc,%esp
80101504:	ff 75 f4             	pushl  -0xc(%ebp)
80101507:	e8 55 ed ff ff       	call   80100261 <brelse>
8010150c:	83 c4 10             	add    $0x10,%esp
}
8010150f:	90                   	nop
80101510:	c9                   	leave  
80101511:	c3                   	ret    

80101512 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101512:	f3 0f 1e fb          	endbr32 
80101516:	55                   	push   %ebp
80101517:	89 e5                	mov    %esp,%ebp
80101519:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010151c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010151f:	8b 45 08             	mov    0x8(%ebp),%eax
80101522:	83 ec 08             	sub    $0x8,%esp
80101525:	52                   	push   %edx
80101526:	50                   	push   %eax
80101527:	e8 ab ec ff ff       	call   801001d7 <bread>
8010152c:	83 c4 10             	add    $0x10,%esp
8010152f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101535:	83 c0 5c             	add    $0x5c,%eax
80101538:	83 ec 04             	sub    $0x4,%esp
8010153b:	68 00 02 00 00       	push   $0x200
80101540:	6a 00                	push   $0x0
80101542:	50                   	push   %eax
80101543:	e8 8b 3f 00 00       	call   801054d3 <memset>
80101548:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010154b:	83 ec 0c             	sub    $0xc,%esp
8010154e:	ff 75 f4             	pushl  -0xc(%ebp)
80101551:	e8 cb 23 00 00       	call   80103921 <log_write>
80101556:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101559:	83 ec 0c             	sub    $0xc,%esp
8010155c:	ff 75 f4             	pushl  -0xc(%ebp)
8010155f:	e8 fd ec ff ff       	call   80100261 <brelse>
80101564:	83 c4 10             	add    $0x10,%esp
}
80101567:	90                   	nop
80101568:	c9                   	leave  
80101569:	c3                   	ret    

8010156a <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010156a:	f3 0f 1e fb          	endbr32 
8010156e:	55                   	push   %ebp
8010156f:	89 e5                	mov    %esp,%ebp
80101571:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101574:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010157b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101582:	e9 13 01 00 00       	jmp    8010169a <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101590:	85 c0                	test   %eax,%eax
80101592:	0f 48 c2             	cmovs  %edx,%eax
80101595:	c1 f8 0c             	sar    $0xc,%eax
80101598:	89 c2                	mov    %eax,%edx
8010159a:	a1 78 2a 11 80       	mov    0x80112a78,%eax
8010159f:	01 d0                	add    %edx,%eax
801015a1:	83 ec 08             	sub    $0x8,%esp
801015a4:	50                   	push   %eax
801015a5:	ff 75 08             	pushl  0x8(%ebp)
801015a8:	e8 2a ec ff ff       	call   801001d7 <bread>
801015ad:	83 c4 10             	add    $0x10,%esp
801015b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015ba:	e9 a6 00 00 00       	jmp    80101665 <balloc+0xfb>
      m = 1 << (bi % 8);
801015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c2:	99                   	cltd   
801015c3:	c1 ea 1d             	shr    $0x1d,%edx
801015c6:	01 d0                	add    %edx,%eax
801015c8:	83 e0 07             	and    $0x7,%eax
801015cb:	29 d0                	sub    %edx,%eax
801015cd:	ba 01 00 00 00       	mov    $0x1,%edx
801015d2:	89 c1                	mov    %eax,%ecx
801015d4:	d3 e2                	shl    %cl,%edx
801015d6:	89 d0                	mov    %edx,%eax
801015d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015de:	8d 50 07             	lea    0x7(%eax),%edx
801015e1:	85 c0                	test   %eax,%eax
801015e3:	0f 48 c2             	cmovs  %edx,%eax
801015e6:	c1 f8 03             	sar    $0x3,%eax
801015e9:	89 c2                	mov    %eax,%edx
801015eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015ee:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015f3:	0f b6 c0             	movzbl %al,%eax
801015f6:	23 45 e8             	and    -0x18(%ebp),%eax
801015f9:	85 c0                	test   %eax,%eax
801015fb:	75 64                	jne    80101661 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101600:	8d 50 07             	lea    0x7(%eax),%edx
80101603:	85 c0                	test   %eax,%eax
80101605:	0f 48 c2             	cmovs  %edx,%eax
80101608:	c1 f8 03             	sar    $0x3,%eax
8010160b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010160e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101613:	89 d1                	mov    %edx,%ecx
80101615:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101618:	09 ca                	or     %ecx,%edx
8010161a:	89 d1                	mov    %edx,%ecx
8010161c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010161f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101623:	83 ec 0c             	sub    $0xc,%esp
80101626:	ff 75 ec             	pushl  -0x14(%ebp)
80101629:	e8 f3 22 00 00       	call   80103921 <log_write>
8010162e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101631:	83 ec 0c             	sub    $0xc,%esp
80101634:	ff 75 ec             	pushl  -0x14(%ebp)
80101637:	e8 25 ec ff ff       	call   80100261 <brelse>
8010163c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101645:	01 c2                	add    %eax,%edx
80101647:	8b 45 08             	mov    0x8(%ebp),%eax
8010164a:	83 ec 08             	sub    $0x8,%esp
8010164d:	52                   	push   %edx
8010164e:	50                   	push   %eax
8010164f:	e8 be fe ff ff       	call   80101512 <bzero>
80101654:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101657:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165d:	01 d0                	add    %edx,%eax
8010165f:	eb 57                	jmp    801016b8 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101661:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101665:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010166c:	7f 17                	jg     80101685 <balloc+0x11b>
8010166e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101674:	01 d0                	add    %edx,%eax
80101676:	89 c2                	mov    %eax,%edx
80101678:	a1 60 2a 11 80       	mov    0x80112a60,%eax
8010167d:	39 c2                	cmp    %eax,%edx
8010167f:	0f 82 3a ff ff ff    	jb     801015bf <balloc+0x55>
      }
    }
    brelse(bp);
80101685:	83 ec 0c             	sub    $0xc,%esp
80101688:	ff 75 ec             	pushl  -0x14(%ebp)
8010168b:	e8 d1 eb ff ff       	call   80100261 <brelse>
80101690:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101693:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010169a:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a3:	39 c2                	cmp    %eax,%edx
801016a5:	0f 87 dc fe ff ff    	ja     80101587 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016ab:	83 ec 0c             	sub    $0xc,%esp
801016ae:	68 88 8d 10 80       	push   $0x80108d88
801016b3:	e8 50 ef ff ff       	call   80100608 <panic>
}
801016b8:	c9                   	leave  
801016b9:	c3                   	ret    

801016ba <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016ba:	f3 0f 1e fb          	endbr32 
801016be:	55                   	push   %ebp
801016bf:	89 e5                	mov    %esp,%ebp
801016c1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c7:	c1 e8 0c             	shr    $0xc,%eax
801016ca:	89 c2                	mov    %eax,%edx
801016cc:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801016d1:	01 c2                	add    %eax,%edx
801016d3:	8b 45 08             	mov    0x8(%ebp),%eax
801016d6:	83 ec 08             	sub    $0x8,%esp
801016d9:	52                   	push   %edx
801016da:	50                   	push   %eax
801016db:	e8 f7 ea ff ff       	call   801001d7 <bread>
801016e0:	83 c4 10             	add    $0x10,%esp
801016e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e9:	25 ff 0f 00 00       	and    $0xfff,%eax
801016ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f4:	99                   	cltd   
801016f5:	c1 ea 1d             	shr    $0x1d,%edx
801016f8:	01 d0                	add    %edx,%eax
801016fa:	83 e0 07             	and    $0x7,%eax
801016fd:	29 d0                	sub    %edx,%eax
801016ff:	ba 01 00 00 00       	mov    $0x1,%edx
80101704:	89 c1                	mov    %eax,%ecx
80101706:	d3 e2                	shl    %cl,%edx
80101708:	89 d0                	mov    %edx,%eax
8010170a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101710:	8d 50 07             	lea    0x7(%eax),%edx
80101713:	85 c0                	test   %eax,%eax
80101715:	0f 48 c2             	cmovs  %edx,%eax
80101718:	c1 f8 03             	sar    $0x3,%eax
8010171b:	89 c2                	mov    %eax,%edx
8010171d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101720:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101725:	0f b6 c0             	movzbl %al,%eax
80101728:	23 45 ec             	and    -0x14(%ebp),%eax
8010172b:	85 c0                	test   %eax,%eax
8010172d:	75 0d                	jne    8010173c <bfree+0x82>
    panic("freeing free block");
8010172f:	83 ec 0c             	sub    $0xc,%esp
80101732:	68 9e 8d 10 80       	push   $0x80108d9e
80101737:	e8 cc ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
8010173c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173f:	8d 50 07             	lea    0x7(%eax),%edx
80101742:	85 c0                	test   %eax,%eax
80101744:	0f 48 c2             	cmovs  %edx,%eax
80101747:	c1 f8 03             	sar    $0x3,%eax
8010174a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010174d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101752:	89 d1                	mov    %edx,%ecx
80101754:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101757:	f7 d2                	not    %edx
80101759:	21 ca                	and    %ecx,%edx
8010175b:	89 d1                	mov    %edx,%ecx
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101764:	83 ec 0c             	sub    $0xc,%esp
80101767:	ff 75 f4             	pushl  -0xc(%ebp)
8010176a:	e8 b2 21 00 00       	call   80103921 <log_write>
8010176f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101772:	83 ec 0c             	sub    $0xc,%esp
80101775:	ff 75 f4             	pushl  -0xc(%ebp)
80101778:	e8 e4 ea ff ff       	call   80100261 <brelse>
8010177d:	83 c4 10             	add    $0x10,%esp
}
80101780:	90                   	nop
80101781:	c9                   	leave  
80101782:	c3                   	ret    

80101783 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101783:	f3 0f 1e fb          	endbr32 
80101787:	55                   	push   %ebp
80101788:	89 e5                	mov    %esp,%ebp
8010178a:	57                   	push   %edi
8010178b:	56                   	push   %esi
8010178c:	53                   	push   %ebx
8010178d:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101790:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101797:	83 ec 08             	sub    $0x8,%esp
8010179a:	68 b1 8d 10 80       	push   $0x80108db1
8010179f:	68 80 2a 11 80       	push   $0x80112a80
801017a4:	e8 65 3a 00 00       	call   8010520e <initlock>
801017a9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017b3:	eb 2d                	jmp    801017e2 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017b8:	89 d0                	mov    %edx,%eax
801017ba:	c1 e0 03             	shl    $0x3,%eax
801017bd:	01 d0                	add    %edx,%eax
801017bf:	c1 e0 04             	shl    $0x4,%eax
801017c2:	83 c0 30             	add    $0x30,%eax
801017c5:	05 80 2a 11 80       	add    $0x80112a80,%eax
801017ca:	83 c0 10             	add    $0x10,%eax
801017cd:	83 ec 08             	sub    $0x8,%esp
801017d0:	68 b8 8d 10 80       	push   $0x80108db8
801017d5:	50                   	push   %eax
801017d6:	e8 a0 38 00 00       	call   8010507b <initsleeplock>
801017db:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017de:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017e2:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017e6:	7e cd                	jle    801017b5 <iinit+0x32>
  }

  readsb(dev, &sb);
801017e8:	83 ec 08             	sub    $0x8,%esp
801017eb:	68 60 2a 11 80       	push   $0x80112a60
801017f0:	ff 75 08             	pushl  0x8(%ebp)
801017f3:	e8 d4 fc ff ff       	call   801014cc <readsb>
801017f8:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017fb:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101803:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
80101809:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
8010180f:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101815:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
8010181b:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101821:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101826:	ff 75 d4             	pushl  -0x2c(%ebp)
80101829:	57                   	push   %edi
8010182a:	56                   	push   %esi
8010182b:	53                   	push   %ebx
8010182c:	51                   	push   %ecx
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	68 c0 8d 10 80       	push   $0x80108dc0
80101834:	e8 df eb ff ff       	call   80100418 <cprintf>
80101839:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010183c:	90                   	nop
8010183d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101840:	5b                   	pop    %ebx
80101841:	5e                   	pop    %esi
80101842:	5f                   	pop    %edi
80101843:	5d                   	pop    %ebp
80101844:	c3                   	ret    

80101845 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101845:	f3 0f 1e fb          	endbr32 
80101849:	55                   	push   %ebp
8010184a:	89 e5                	mov    %esp,%ebp
8010184c:	83 ec 28             	sub    $0x28,%esp
8010184f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101852:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101856:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010185d:	e9 9e 00 00 00       	jmp    80101900 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101865:	c1 e8 03             	shr    $0x3,%eax
80101868:	89 c2                	mov    %eax,%edx
8010186a:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010186f:	01 d0                	add    %edx,%eax
80101871:	83 ec 08             	sub    $0x8,%esp
80101874:	50                   	push   %eax
80101875:	ff 75 08             	pushl  0x8(%ebp)
80101878:	e8 5a e9 ff ff       	call   801001d7 <bread>
8010187d:	83 c4 10             	add    $0x10,%esp
80101880:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101886:	8d 50 5c             	lea    0x5c(%eax),%edx
80101889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188c:	83 e0 07             	and    $0x7,%eax
8010188f:	c1 e0 06             	shl    $0x6,%eax
80101892:	01 d0                	add    %edx,%eax
80101894:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101897:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010189a:	0f b7 00             	movzwl (%eax),%eax
8010189d:	66 85 c0             	test   %ax,%ax
801018a0:	75 4c                	jne    801018ee <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018a2:	83 ec 04             	sub    $0x4,%esp
801018a5:	6a 40                	push   $0x40
801018a7:	6a 00                	push   $0x0
801018a9:	ff 75 ec             	pushl  -0x14(%ebp)
801018ac:	e8 22 3c 00 00       	call   801054d3 <memset>
801018b1:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018b7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018bb:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018be:	83 ec 0c             	sub    $0xc,%esp
801018c1:	ff 75 f0             	pushl  -0x10(%ebp)
801018c4:	e8 58 20 00 00       	call   80103921 <log_write>
801018c9:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018cc:	83 ec 0c             	sub    $0xc,%esp
801018cf:	ff 75 f0             	pushl  -0x10(%ebp)
801018d2:	e8 8a e9 ff ff       	call   80100261 <brelse>
801018d7:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018dd:	83 ec 08             	sub    $0x8,%esp
801018e0:	50                   	push   %eax
801018e1:	ff 75 08             	pushl  0x8(%ebp)
801018e4:	e8 fc 00 00 00       	call   801019e5 <iget>
801018e9:	83 c4 10             	add    $0x10,%esp
801018ec:	eb 30                	jmp    8010191e <ialloc+0xd9>
    }
    brelse(bp);
801018ee:	83 ec 0c             	sub    $0xc,%esp
801018f1:	ff 75 f0             	pushl  -0x10(%ebp)
801018f4:	e8 68 e9 ff ff       	call   80100261 <brelse>
801018f9:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101900:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	39 c2                	cmp    %eax,%edx
8010190b:	0f 87 51 ff ff ff    	ja     80101862 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101911:	83 ec 0c             	sub    $0xc,%esp
80101914:	68 13 8e 10 80       	push   $0x80108e13
80101919:	e8 ea ec ff ff       	call   80100608 <panic>
}
8010191e:	c9                   	leave  
8010191f:	c3                   	ret    

80101920 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101920:	f3 0f 1e fb          	endbr32 
80101924:	55                   	push   %ebp
80101925:	89 e5                	mov    %esp,%ebp
80101927:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010192a:	8b 45 08             	mov    0x8(%ebp),%eax
8010192d:	8b 40 04             	mov    0x4(%eax),%eax
80101930:	c1 e8 03             	shr    $0x3,%eax
80101933:	89 c2                	mov    %eax,%edx
80101935:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010193a:	01 c2                	add    %eax,%edx
8010193c:	8b 45 08             	mov    0x8(%ebp),%eax
8010193f:	8b 00                	mov    (%eax),%eax
80101941:	83 ec 08             	sub    $0x8,%esp
80101944:	52                   	push   %edx
80101945:	50                   	push   %eax
80101946:	e8 8c e8 ff ff       	call   801001d7 <bread>
8010194b:	83 c4 10             	add    $0x10,%esp
8010194e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101954:	8d 50 5c             	lea    0x5c(%eax),%edx
80101957:	8b 45 08             	mov    0x8(%ebp),%eax
8010195a:	8b 40 04             	mov    0x4(%eax),%eax
8010195d:	83 e0 07             	and    $0x7,%eax
80101960:	c1 e0 06             	shl    $0x6,%eax
80101963:	01 d0                	add    %edx,%eax
80101965:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101972:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101975:	8b 45 08             	mov    0x8(%ebp),%eax
80101978:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010197c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101983:	8b 45 08             	mov    0x8(%ebp),%eax
80101986:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101991:	8b 45 08             	mov    0x8(%ebp),%eax
80101994:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010199f:	8b 45 08             	mov    0x8(%ebp),%eax
801019a2:	8b 50 58             	mov    0x58(%eax),%edx
801019a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a8:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019ab:	8b 45 08             	mov    0x8(%ebp),%eax
801019ae:	8d 50 5c             	lea    0x5c(%eax),%edx
801019b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b4:	83 c0 0c             	add    $0xc,%eax
801019b7:	83 ec 04             	sub    $0x4,%esp
801019ba:	6a 34                	push   $0x34
801019bc:	52                   	push   %edx
801019bd:	50                   	push   %eax
801019be:	e8 d7 3b 00 00       	call   8010559a <memmove>
801019c3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019c6:	83 ec 0c             	sub    $0xc,%esp
801019c9:	ff 75 f4             	pushl  -0xc(%ebp)
801019cc:	e8 50 1f 00 00       	call   80103921 <log_write>
801019d1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019d4:	83 ec 0c             	sub    $0xc,%esp
801019d7:	ff 75 f4             	pushl  -0xc(%ebp)
801019da:	e8 82 e8 ff ff       	call   80100261 <brelse>
801019df:	83 c4 10             	add    $0x10,%esp
}
801019e2:	90                   	nop
801019e3:	c9                   	leave  
801019e4:	c3                   	ret    

801019e5 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019e5:	f3 0f 1e fb          	endbr32 
801019e9:	55                   	push   %ebp
801019ea:	89 e5                	mov    %esp,%ebp
801019ec:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	68 80 2a 11 80       	push   $0x80112a80
801019f7:	e8 38 38 00 00       	call   80105234 <acquire>
801019fc:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a06:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a0d:	eb 60                	jmp    80101a6f <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a12:	8b 40 08             	mov    0x8(%eax),%eax
80101a15:	85 c0                	test   %eax,%eax
80101a17:	7e 39                	jle    80101a52 <iget+0x6d>
80101a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1c:	8b 00                	mov    (%eax),%eax
80101a1e:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a21:	75 2f                	jne    80101a52 <iget+0x6d>
80101a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a26:	8b 40 04             	mov    0x4(%eax),%eax
80101a29:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a2c:	75 24                	jne    80101a52 <iget+0x6d>
      ip->ref++;
80101a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a31:	8b 40 08             	mov    0x8(%eax),%eax
80101a34:	8d 50 01             	lea    0x1(%eax),%edx
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a3d:	83 ec 0c             	sub    $0xc,%esp
80101a40:	68 80 2a 11 80       	push   $0x80112a80
80101a45:	e8 5c 38 00 00       	call   801052a6 <release>
80101a4a:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a50:	eb 77                	jmp    80101ac9 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a56:	75 10                	jne    80101a68 <iget+0x83>
80101a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	85 c0                	test   %eax,%eax
80101a60:	75 06                	jne    80101a68 <iget+0x83>
      empty = ip;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a68:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a6f:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101a76:	72 97                	jb     80101a0f <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a7c:	75 0d                	jne    80101a8b <iget+0xa6>
    panic("iget: no inodes");
80101a7e:	83 ec 0c             	sub    $0xc,%esp
80101a81:	68 25 8e 10 80       	push   $0x80108e25
80101a86:	e8 7d eb ff ff       	call   80100608 <panic>

  ip = empty;
80101a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a94:	8b 55 08             	mov    0x8(%ebp),%edx
80101a97:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a9f:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aaf:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	68 80 2a 11 80       	push   $0x80112a80
80101abe:	e8 e3 37 00 00       	call   801052a6 <release>
80101ac3:	83 c4 10             	add    $0x10,%esp

  return ip;
80101ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ac9:	c9                   	leave  
80101aca:	c3                   	ret    

80101acb <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101acb:	f3 0f 1e fb          	endbr32 
80101acf:	55                   	push   %ebp
80101ad0:	89 e5                	mov    %esp,%ebp
80101ad2:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ad5:	83 ec 0c             	sub    $0xc,%esp
80101ad8:	68 80 2a 11 80       	push   $0x80112a80
80101add:	e8 52 37 00 00       	call   80105234 <acquire>
80101ae2:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	8b 40 08             	mov    0x8(%eax),%eax
80101aeb:	8d 50 01             	lea    0x1(%eax),%edx
80101aee:	8b 45 08             	mov    0x8(%ebp),%eax
80101af1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101af4:	83 ec 0c             	sub    $0xc,%esp
80101af7:	68 80 2a 11 80       	push   $0x80112a80
80101afc:	e8 a5 37 00 00       	call   801052a6 <release>
80101b01:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b04:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b07:	c9                   	leave  
80101b08:	c3                   	ret    

80101b09 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b09:	f3 0f 1e fb          	endbr32 
80101b0d:	55                   	push   %ebp
80101b0e:	89 e5                	mov    %esp,%ebp
80101b10:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b17:	74 0a                	je     80101b23 <ilock+0x1a>
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	8b 40 08             	mov    0x8(%eax),%eax
80101b1f:	85 c0                	test   %eax,%eax
80101b21:	7f 0d                	jg     80101b30 <ilock+0x27>
    panic("ilock");
80101b23:	83 ec 0c             	sub    $0xc,%esp
80101b26:	68 35 8e 10 80       	push   $0x80108e35
80101b2b:	e8 d8 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	83 c0 0c             	add    $0xc,%eax
80101b36:	83 ec 0c             	sub    $0xc,%esp
80101b39:	50                   	push   %eax
80101b3a:	e8 7c 35 00 00       	call   801050bb <acquiresleep>
80101b3f:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b48:	85 c0                	test   %eax,%eax
80101b4a:	0f 85 cd 00 00 00    	jne    80101c1d <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 04             	mov    0x4(%eax),%eax
80101b56:	c1 e8 03             	shr    $0x3,%eax
80101b59:	89 c2                	mov    %eax,%edx
80101b5b:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101b60:	01 c2                	add    %eax,%edx
80101b62:	8b 45 08             	mov    0x8(%ebp),%eax
80101b65:	8b 00                	mov    (%eax),%eax
80101b67:	83 ec 08             	sub    $0x8,%esp
80101b6a:	52                   	push   %edx
80101b6b:	50                   	push   %eax
80101b6c:	e8 66 e6 ff ff       	call   801001d7 <bread>
80101b71:	83 c4 10             	add    $0x10,%esp
80101b74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b80:	8b 40 04             	mov    0x4(%eax),%eax
80101b83:	83 e0 07             	and    $0x7,%eax
80101b86:	c1 e0 06             	shl    $0x6,%eax
80101b89:	01 d0                	add    %edx,%eax
80101b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b91:	0f b7 10             	movzwl (%eax),%edx
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba5:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bac:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bba:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc8:	8b 50 08             	mov    0x8(%eax),%edx
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd4:	8d 50 0c             	lea    0xc(%eax),%edx
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 5c             	add    $0x5c,%eax
80101bdd:	83 ec 04             	sub    $0x4,%esp
80101be0:	6a 34                	push   $0x34
80101be2:	52                   	push   %edx
80101be3:	50                   	push   %eax
80101be4:	e8 b1 39 00 00       	call   8010559a <memmove>
80101be9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bec:	83 ec 0c             	sub    $0xc,%esp
80101bef:	ff 75 f4             	pushl  -0xc(%ebp)
80101bf2:	e8 6a e6 ff ff       	call   80100261 <brelse>
80101bf7:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c04:	8b 45 08             	mov    0x8(%ebp),%eax
80101c07:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c0b:	66 85 c0             	test   %ax,%ax
80101c0e:	75 0d                	jne    80101c1d <ilock+0x114>
      panic("ilock: no type");
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 3b 8e 10 80       	push   $0x80108e3b
80101c18:	e8 eb e9 ff ff       	call   80100608 <panic>
  }
}
80101c1d:	90                   	nop
80101c1e:	c9                   	leave  
80101c1f:	c3                   	ret    

80101c20 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c20:	f3 0f 1e fb          	endbr32 
80101c24:	55                   	push   %ebp
80101c25:	89 e5                	mov    %esp,%ebp
80101c27:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c2e:	74 20                	je     80101c50 <iunlock+0x30>
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	83 c0 0c             	add    $0xc,%eax
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	50                   	push   %eax
80101c3a:	e8 36 35 00 00       	call   80105175 <holdingsleep>
80101c3f:	83 c4 10             	add    $0x10,%esp
80101c42:	85 c0                	test   %eax,%eax
80101c44:	74 0a                	je     80101c50 <iunlock+0x30>
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	85 c0                	test   %eax,%eax
80101c4e:	7f 0d                	jg     80101c5d <iunlock+0x3d>
    panic("iunlock");
80101c50:	83 ec 0c             	sub    $0xc,%esp
80101c53:	68 4a 8e 10 80       	push   $0x80108e4a
80101c58:	e8 ab e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	83 c0 0c             	add    $0xc,%eax
80101c63:	83 ec 0c             	sub    $0xc,%esp
80101c66:	50                   	push   %eax
80101c67:	e8 b7 34 00 00       	call   80105123 <releasesleep>
80101c6c:	83 c4 10             	add    $0x10,%esp
}
80101c6f:	90                   	nop
80101c70:	c9                   	leave  
80101c71:	c3                   	ret    

80101c72 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c72:	f3 0f 1e fb          	endbr32 
80101c76:	55                   	push   %ebp
80101c77:	89 e5                	mov    %esp,%ebp
80101c79:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	83 c0 0c             	add    $0xc,%eax
80101c82:	83 ec 0c             	sub    $0xc,%esp
80101c85:	50                   	push   %eax
80101c86:	e8 30 34 00 00       	call   801050bb <acquiresleep>
80101c8b:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c94:	85 c0                	test   %eax,%eax
80101c96:	74 6a                	je     80101d02 <iput+0x90>
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c9f:	66 85 c0             	test   %ax,%ax
80101ca2:	75 5e                	jne    80101d02 <iput+0x90>
    acquire(&icache.lock);
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	68 80 2a 11 80       	push   $0x80112a80
80101cac:	e8 83 35 00 00       	call   80105234 <acquire>
80101cb1:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb7:	8b 40 08             	mov    0x8(%eax),%eax
80101cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cbd:	83 ec 0c             	sub    $0xc,%esp
80101cc0:	68 80 2a 11 80       	push   $0x80112a80
80101cc5:	e8 dc 35 00 00       	call   801052a6 <release>
80101cca:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ccd:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cd1:	75 2f                	jne    80101d02 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cd3:	83 ec 0c             	sub    $0xc,%esp
80101cd6:	ff 75 08             	pushl  0x8(%ebp)
80101cd9:	e8 b5 01 00 00       	call   80101e93 <itrunc>
80101cde:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cea:	83 ec 0c             	sub    $0xc,%esp
80101ced:	ff 75 08             	pushl  0x8(%ebp)
80101cf0:	e8 2b fc ff ff       	call   80101920 <iupdate>
80101cf5:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	83 c0 0c             	add    $0xc,%eax
80101d08:	83 ec 0c             	sub    $0xc,%esp
80101d0b:	50                   	push   %eax
80101d0c:	e8 12 34 00 00       	call   80105123 <releasesleep>
80101d11:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d14:	83 ec 0c             	sub    $0xc,%esp
80101d17:	68 80 2a 11 80       	push   $0x80112a80
80101d1c:	e8 13 35 00 00       	call   80105234 <acquire>
80101d21:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 40 08             	mov    0x8(%eax),%eax
80101d2a:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d30:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d33:	83 ec 0c             	sub    $0xc,%esp
80101d36:	68 80 2a 11 80       	push   $0x80112a80
80101d3b:	e8 66 35 00 00       	call   801052a6 <release>
80101d40:	83 c4 10             	add    $0x10,%esp
}
80101d43:	90                   	nop
80101d44:	c9                   	leave  
80101d45:	c3                   	ret    

80101d46 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d46:	f3 0f 1e fb          	endbr32 
80101d4a:	55                   	push   %ebp
80101d4b:	89 e5                	mov    %esp,%ebp
80101d4d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d50:	83 ec 0c             	sub    $0xc,%esp
80101d53:	ff 75 08             	pushl  0x8(%ebp)
80101d56:	e8 c5 fe ff ff       	call   80101c20 <iunlock>
80101d5b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d5e:	83 ec 0c             	sub    $0xc,%esp
80101d61:	ff 75 08             	pushl  0x8(%ebp)
80101d64:	e8 09 ff ff ff       	call   80101c72 <iput>
80101d69:	83 c4 10             	add    $0x10,%esp
}
80101d6c:	90                   	nop
80101d6d:	c9                   	leave  
80101d6e:	c3                   	ret    

80101d6f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d6f:	f3 0f 1e fb          	endbr32 
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d79:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d7d:	77 42                	ja     80101dc1 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d85:	83 c2 14             	add    $0x14,%edx
80101d88:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d93:	75 24                	jne    80101db9 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 00                	mov    (%eax),%eax
80101d9a:	83 ec 0c             	sub    $0xc,%esp
80101d9d:	50                   	push   %eax
80101d9e:	e8 c7 f7 ff ff       	call   8010156a <balloc>
80101da3:	83 c4 10             	add    $0x10,%esp
80101da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	8b 55 0c             	mov    0xc(%ebp),%edx
80101daf:	8d 4a 14             	lea    0x14(%edx),%ecx
80101db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db5:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbc:	e9 d0 00 00 00       	jmp    80101e91 <bmap+0x122>
  }
  bn -= NDIRECT;
80101dc1:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101dc5:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101dc9:	0f 87 b5 00 00 00    	ja     80101e84 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ddb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ddf:	75 20                	jne    80101e01 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101de1:	8b 45 08             	mov    0x8(%ebp),%eax
80101de4:	8b 00                	mov    (%eax),%eax
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	50                   	push   %eax
80101dea:	e8 7b f7 ff ff       	call   8010156a <balloc>
80101def:	83 c4 10             	add    $0x10,%esp
80101df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df5:	8b 45 08             	mov    0x8(%ebp),%eax
80101df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dfb:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e01:	8b 45 08             	mov    0x8(%ebp),%eax
80101e04:	8b 00                	mov    (%eax),%eax
80101e06:	83 ec 08             	sub    $0x8,%esp
80101e09:	ff 75 f4             	pushl  -0xc(%ebp)
80101e0c:	50                   	push   %eax
80101e0d:	e8 c5 e3 ff ff       	call   801001d7 <bread>
80101e12:	83 c4 10             	add    $0x10,%esp
80101e15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	83 c0 5c             	add    $0x5c,%eax
80101e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e2e:	01 d0                	add    %edx,%eax
80101e30:	8b 00                	mov    (%eax),%eax
80101e32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e39:	75 36                	jne    80101e71 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3e:	8b 00                	mov    (%eax),%eax
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	50                   	push   %eax
80101e44:	e8 21 f7 ff ff       	call   8010156a <balloc>
80101e49:	83 c4 10             	add    $0x10,%esp
80101e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e5c:	01 c2                	add    %eax,%edx
80101e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e61:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e63:	83 ec 0c             	sub    $0xc,%esp
80101e66:	ff 75 f0             	pushl  -0x10(%ebp)
80101e69:	e8 b3 1a 00 00       	call   80103921 <log_write>
80101e6e:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e71:	83 ec 0c             	sub    $0xc,%esp
80101e74:	ff 75 f0             	pushl  -0x10(%ebp)
80101e77:	e8 e5 e3 ff ff       	call   80100261 <brelse>
80101e7c:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e82:	eb 0d                	jmp    80101e91 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e84:	83 ec 0c             	sub    $0xc,%esp
80101e87:	68 52 8e 10 80       	push   $0x80108e52
80101e8c:	e8 77 e7 ff ff       	call   80100608 <panic>
}
80101e91:	c9                   	leave  
80101e92:	c3                   	ret    

80101e93 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e93:	f3 0f 1e fb          	endbr32 
80101e97:	55                   	push   %ebp
80101e98:	89 e5                	mov    %esp,%ebp
80101e9a:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea4:	eb 45                	jmp    80101eeb <itrunc+0x58>
    if(ip->addrs[i]){
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eac:	83 c2 14             	add    $0x14,%edx
80101eaf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101eb3:	85 c0                	test   %eax,%eax
80101eb5:	74 30                	je     80101ee7 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebd:	83 c2 14             	add    $0x14,%edx
80101ec0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ec4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec7:	8b 12                	mov    (%edx),%edx
80101ec9:	83 ec 08             	sub    $0x8,%esp
80101ecc:	50                   	push   %eax
80101ecd:	52                   	push   %edx
80101ece:	e8 e7 f7 ff ff       	call   801016ba <bfree>
80101ed3:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101edc:	83 c2 14             	add    $0x14,%edx
80101edf:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ee6:	00 
  for(i = 0; i < NDIRECT; i++){
80101ee7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101eeb:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101eef:	7e b5                	jle    80101ea6 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101efa:	85 c0                	test   %eax,%eax
80101efc:	0f 84 aa 00 00 00    	je     80101fac <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	8b 00                	mov    (%eax),%eax
80101f10:	83 ec 08             	sub    $0x8,%esp
80101f13:	52                   	push   %edx
80101f14:	50                   	push   %eax
80101f15:	e8 bd e2 ff ff       	call   801001d7 <bread>
80101f1a:	83 c4 10             	add    $0x10,%esp
80101f1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f23:	83 c0 5c             	add    $0x5c,%eax
80101f26:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f29:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f30:	eb 3c                	jmp    80101f6e <itrunc+0xdb>
      if(a[j])
80101f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f3f:	01 d0                	add    %edx,%eax
80101f41:	8b 00                	mov    (%eax),%eax
80101f43:	85 c0                	test   %eax,%eax
80101f45:	74 23                	je     80101f6a <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f54:	01 d0                	add    %edx,%eax
80101f56:	8b 00                	mov    (%eax),%eax
80101f58:	8b 55 08             	mov    0x8(%ebp),%edx
80101f5b:	8b 12                	mov    (%edx),%edx
80101f5d:	83 ec 08             	sub    $0x8,%esp
80101f60:	50                   	push   %eax
80101f61:	52                   	push   %edx
80101f62:	e8 53 f7 ff ff       	call   801016ba <bfree>
80101f67:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f6a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f71:	83 f8 7f             	cmp    $0x7f,%eax
80101f74:	76 bc                	jbe    80101f32 <itrunc+0x9f>
    }
    brelse(bp);
80101f76:	83 ec 0c             	sub    $0xc,%esp
80101f79:	ff 75 ec             	pushl  -0x14(%ebp)
80101f7c:	e8 e0 e2 ff ff       	call   80100261 <brelse>
80101f81:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101f90:	8b 12                	mov    (%edx),%edx
80101f92:	83 ec 08             	sub    $0x8,%esp
80101f95:	50                   	push   %eax
80101f96:	52                   	push   %edx
80101f97:	e8 1e f7 ff ff       	call   801016ba <bfree>
80101f9c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fa9:	00 00 00 
  }

  ip->size = 0;
80101fac:	8b 45 08             	mov    0x8(%ebp),%eax
80101faf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101fb6:	83 ec 0c             	sub    $0xc,%esp
80101fb9:	ff 75 08             	pushl  0x8(%ebp)
80101fbc:	e8 5f f9 ff ff       	call   80101920 <iupdate>
80101fc1:	83 c4 10             	add    $0x10,%esp
}
80101fc4:	90                   	nop
80101fc5:	c9                   	leave  
80101fc6:	c3                   	ret    

80101fc7 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fc7:	f3 0f 1e fb          	endbr32 
80101fcb:	55                   	push   %ebp
80101fcc:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fce:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd1:	8b 00                	mov    (%eax),%eax
80101fd3:	89 c2                	mov    %eax,%edx
80101fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd8:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	8b 50 04             	mov    0x4(%eax),%edx
80101fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe4:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fea:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff7:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffe:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102002:	8b 45 08             	mov    0x8(%ebp),%eax
80102005:	8b 50 58             	mov    0x58(%eax),%edx
80102008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010200e:	90                   	nop
8010200f:	5d                   	pop    %ebp
80102010:	c3                   	ret    

80102011 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102011:	f3 0f 1e fb          	endbr32 
80102015:	55                   	push   %ebp
80102016:	89 e5                	mov    %esp,%ebp
80102018:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201b:	8b 45 08             	mov    0x8(%ebp),%eax
8010201e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102022:	66 83 f8 03          	cmp    $0x3,%ax
80102026:	75 5c                	jne    80102084 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102028:	8b 45 08             	mov    0x8(%ebp),%eax
8010202b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010202f:	66 85 c0             	test   %ax,%ax
80102032:	78 20                	js     80102054 <readi+0x43>
80102034:	8b 45 08             	mov    0x8(%ebp),%eax
80102037:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010203b:	66 83 f8 09          	cmp    $0x9,%ax
8010203f:	7f 13                	jg     80102054 <readi+0x43>
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102048:	98                   	cwtl   
80102049:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
80102050:	85 c0                	test   %eax,%eax
80102052:	75 0a                	jne    8010205e <readi+0x4d>
      return -1;
80102054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102059:	e9 0a 01 00 00       	jmp    80102168 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010205e:	8b 45 08             	mov    0x8(%ebp),%eax
80102061:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102065:	98                   	cwtl   
80102066:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
8010206d:	8b 55 14             	mov    0x14(%ebp),%edx
80102070:	83 ec 04             	sub    $0x4,%esp
80102073:	52                   	push   %edx
80102074:	ff 75 0c             	pushl  0xc(%ebp)
80102077:	ff 75 08             	pushl  0x8(%ebp)
8010207a:	ff d0                	call   *%eax
8010207c:	83 c4 10             	add    $0x10,%esp
8010207f:	e9 e4 00 00 00       	jmp    80102168 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	8b 40 58             	mov    0x58(%eax),%eax
8010208a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010208d:	77 0d                	ja     8010209c <readi+0x8b>
8010208f:	8b 55 10             	mov    0x10(%ebp),%edx
80102092:	8b 45 14             	mov    0x14(%ebp),%eax
80102095:	01 d0                	add    %edx,%eax
80102097:	39 45 10             	cmp    %eax,0x10(%ebp)
8010209a:	76 0a                	jbe    801020a6 <readi+0x95>
    return -1;
8010209c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a1:	e9 c2 00 00 00       	jmp    80102168 <readi+0x157>
  if(off + n > ip->size)
801020a6:	8b 55 10             	mov    0x10(%ebp),%edx
801020a9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ac:	01 c2                	add    %eax,%edx
801020ae:	8b 45 08             	mov    0x8(%ebp),%eax
801020b1:	8b 40 58             	mov    0x58(%eax),%eax
801020b4:	39 c2                	cmp    %eax,%edx
801020b6:	76 0c                	jbe    801020c4 <readi+0xb3>
    n = ip->size - off;
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8b 40 58             	mov    0x58(%eax),%eax
801020be:	2b 45 10             	sub    0x10(%ebp),%eax
801020c1:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020cb:	e9 89 00 00 00       	jmp    80102159 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d0:	8b 45 10             	mov    0x10(%ebp),%eax
801020d3:	c1 e8 09             	shr    $0x9,%eax
801020d6:	83 ec 08             	sub    $0x8,%esp
801020d9:	50                   	push   %eax
801020da:	ff 75 08             	pushl  0x8(%ebp)
801020dd:	e8 8d fc ff ff       	call   80101d6f <bmap>
801020e2:	83 c4 10             	add    $0x10,%esp
801020e5:	8b 55 08             	mov    0x8(%ebp),%edx
801020e8:	8b 12                	mov    (%edx),%edx
801020ea:	83 ec 08             	sub    $0x8,%esp
801020ed:	50                   	push   %eax
801020ee:	52                   	push   %edx
801020ef:	e8 e3 e0 ff ff       	call   801001d7 <bread>
801020f4:	83 c4 10             	add    $0x10,%esp
801020f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020fa:	8b 45 10             	mov    0x10(%ebp),%eax
801020fd:	25 ff 01 00 00       	and    $0x1ff,%eax
80102102:	ba 00 02 00 00       	mov    $0x200,%edx
80102107:	29 c2                	sub    %eax,%edx
80102109:	8b 45 14             	mov    0x14(%ebp),%eax
8010210c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010210f:	39 c2                	cmp    %eax,%edx
80102111:	0f 46 c2             	cmovbe %edx,%eax
80102114:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010211d:	8b 45 10             	mov    0x10(%ebp),%eax
80102120:	25 ff 01 00 00       	and    $0x1ff,%eax
80102125:	01 d0                	add    %edx,%eax
80102127:	83 ec 04             	sub    $0x4,%esp
8010212a:	ff 75 ec             	pushl  -0x14(%ebp)
8010212d:	50                   	push   %eax
8010212e:	ff 75 0c             	pushl  0xc(%ebp)
80102131:	e8 64 34 00 00       	call   8010559a <memmove>
80102136:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102139:	83 ec 0c             	sub    $0xc,%esp
8010213c:	ff 75 f0             	pushl  -0x10(%ebp)
8010213f:	e8 1d e1 ff ff       	call   80100261 <brelse>
80102144:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010214a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010214d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102150:	01 45 10             	add    %eax,0x10(%ebp)
80102153:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102156:	01 45 0c             	add    %eax,0xc(%ebp)
80102159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010215c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010215f:	0f 82 6b ff ff ff    	jb     801020d0 <readi+0xbf>
  }
  return n;
80102165:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102168:	c9                   	leave  
80102169:	c3                   	ret    

8010216a <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010216a:	f3 0f 1e fb          	endbr32 
8010216e:	55                   	push   %ebp
8010216f:	89 e5                	mov    %esp,%ebp
80102171:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102174:	8b 45 08             	mov    0x8(%ebp),%eax
80102177:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010217b:	66 83 f8 03          	cmp    $0x3,%ax
8010217f:	75 5c                	jne    801021dd <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102181:	8b 45 08             	mov    0x8(%ebp),%eax
80102184:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102188:	66 85 c0             	test   %ax,%ax
8010218b:	78 20                	js     801021ad <writei+0x43>
8010218d:	8b 45 08             	mov    0x8(%ebp),%eax
80102190:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102194:	66 83 f8 09          	cmp    $0x9,%ax
80102198:	7f 13                	jg     801021ad <writei+0x43>
8010219a:	8b 45 08             	mov    0x8(%ebp),%eax
8010219d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021a1:	98                   	cwtl   
801021a2:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021a9:	85 c0                	test   %eax,%eax
801021ab:	75 0a                	jne    801021b7 <writei+0x4d>
      return -1;
801021ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b2:	e9 3b 01 00 00       	jmp    801022f2 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021b7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ba:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021be:	98                   	cwtl   
801021bf:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021c6:	8b 55 14             	mov    0x14(%ebp),%edx
801021c9:	83 ec 04             	sub    $0x4,%esp
801021cc:	52                   	push   %edx
801021cd:	ff 75 0c             	pushl  0xc(%ebp)
801021d0:	ff 75 08             	pushl  0x8(%ebp)
801021d3:	ff d0                	call   *%eax
801021d5:	83 c4 10             	add    $0x10,%esp
801021d8:	e9 15 01 00 00       	jmp    801022f2 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021dd:	8b 45 08             	mov    0x8(%ebp),%eax
801021e0:	8b 40 58             	mov    0x58(%eax),%eax
801021e3:	39 45 10             	cmp    %eax,0x10(%ebp)
801021e6:	77 0d                	ja     801021f5 <writei+0x8b>
801021e8:	8b 55 10             	mov    0x10(%ebp),%edx
801021eb:	8b 45 14             	mov    0x14(%ebp),%eax
801021ee:	01 d0                	add    %edx,%eax
801021f0:	39 45 10             	cmp    %eax,0x10(%ebp)
801021f3:	76 0a                	jbe    801021ff <writei+0x95>
    return -1;
801021f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021fa:	e9 f3 00 00 00       	jmp    801022f2 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021ff:	8b 55 10             	mov    0x10(%ebp),%edx
80102202:	8b 45 14             	mov    0x14(%ebp),%eax
80102205:	01 d0                	add    %edx,%eax
80102207:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010220c:	76 0a                	jbe    80102218 <writei+0xae>
    return -1;
8010220e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102213:	e9 da 00 00 00       	jmp    801022f2 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010221f:	e9 97 00 00 00       	jmp    801022bb <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102224:	8b 45 10             	mov    0x10(%ebp),%eax
80102227:	c1 e8 09             	shr    $0x9,%eax
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	50                   	push   %eax
8010222e:	ff 75 08             	pushl  0x8(%ebp)
80102231:	e8 39 fb ff ff       	call   80101d6f <bmap>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	8b 55 08             	mov    0x8(%ebp),%edx
8010223c:	8b 12                	mov    (%edx),%edx
8010223e:	83 ec 08             	sub    $0x8,%esp
80102241:	50                   	push   %eax
80102242:	52                   	push   %edx
80102243:	e8 8f df ff ff       	call   801001d7 <bread>
80102248:	83 c4 10             	add    $0x10,%esp
8010224b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010224e:	8b 45 10             	mov    0x10(%ebp),%eax
80102251:	25 ff 01 00 00       	and    $0x1ff,%eax
80102256:	ba 00 02 00 00       	mov    $0x200,%edx
8010225b:	29 c2                	sub    %eax,%edx
8010225d:	8b 45 14             	mov    0x14(%ebp),%eax
80102260:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102263:	39 c2                	cmp    %eax,%edx
80102265:	0f 46 c2             	cmovbe %edx,%eax
80102268:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010226b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010226e:	8d 50 5c             	lea    0x5c(%eax),%edx
80102271:	8b 45 10             	mov    0x10(%ebp),%eax
80102274:	25 ff 01 00 00       	and    $0x1ff,%eax
80102279:	01 d0                	add    %edx,%eax
8010227b:	83 ec 04             	sub    $0x4,%esp
8010227e:	ff 75 ec             	pushl  -0x14(%ebp)
80102281:	ff 75 0c             	pushl  0xc(%ebp)
80102284:	50                   	push   %eax
80102285:	e8 10 33 00 00       	call   8010559a <memmove>
8010228a:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010228d:	83 ec 0c             	sub    $0xc,%esp
80102290:	ff 75 f0             	pushl  -0x10(%ebp)
80102293:	e8 89 16 00 00       	call   80103921 <log_write>
80102298:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010229b:	83 ec 0c             	sub    $0xc,%esp
8010229e:	ff 75 f0             	pushl  -0x10(%ebp)
801022a1:	e8 bb df ff ff       	call   80100261 <brelse>
801022a6:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022ac:	01 45 f4             	add    %eax,-0xc(%ebp)
801022af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b2:	01 45 10             	add    %eax,0x10(%ebp)
801022b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b8:	01 45 0c             	add    %eax,0xc(%ebp)
801022bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022be:	3b 45 14             	cmp    0x14(%ebp),%eax
801022c1:	0f 82 5d ff ff ff    	jb     80102224 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022c7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022cb:	74 22                	je     801022ef <writei+0x185>
801022cd:	8b 45 08             	mov    0x8(%ebp),%eax
801022d0:	8b 40 58             	mov    0x58(%eax),%eax
801022d3:	39 45 10             	cmp    %eax,0x10(%ebp)
801022d6:	76 17                	jbe    801022ef <writei+0x185>
    ip->size = off;
801022d8:	8b 45 08             	mov    0x8(%ebp),%eax
801022db:	8b 55 10             	mov    0x10(%ebp),%edx
801022de:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022e1:	83 ec 0c             	sub    $0xc,%esp
801022e4:	ff 75 08             	pushl  0x8(%ebp)
801022e7:	e8 34 f6 ff ff       	call   80101920 <iupdate>
801022ec:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022ef:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022f2:	c9                   	leave  
801022f3:	c3                   	ret    

801022f4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022f4:	f3 0f 1e fb          	endbr32 
801022f8:	55                   	push   %ebp
801022f9:	89 e5                	mov    %esp,%ebp
801022fb:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022fe:	83 ec 04             	sub    $0x4,%esp
80102301:	6a 0e                	push   $0xe
80102303:	ff 75 0c             	pushl  0xc(%ebp)
80102306:	ff 75 08             	pushl  0x8(%ebp)
80102309:	e8 2a 33 00 00       	call   80105638 <strncmp>
8010230e:	83 c4 10             	add    $0x10,%esp
}
80102311:	c9                   	leave  
80102312:	c3                   	ret    

80102313 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102313:	f3 0f 1e fb          	endbr32 
80102317:	55                   	push   %ebp
80102318:	89 e5                	mov    %esp,%ebp
8010231a:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010231d:	8b 45 08             	mov    0x8(%ebp),%eax
80102320:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102324:	66 83 f8 01          	cmp    $0x1,%ax
80102328:	74 0d                	je     80102337 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010232a:	83 ec 0c             	sub    $0xc,%esp
8010232d:	68 65 8e 10 80       	push   $0x80108e65
80102332:	e8 d1 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102337:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010233e:	eb 7b                	jmp    801023bb <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102340:	6a 10                	push   $0x10
80102342:	ff 75 f4             	pushl  -0xc(%ebp)
80102345:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102348:	50                   	push   %eax
80102349:	ff 75 08             	pushl  0x8(%ebp)
8010234c:	e8 c0 fc ff ff       	call   80102011 <readi>
80102351:	83 c4 10             	add    $0x10,%esp
80102354:	83 f8 10             	cmp    $0x10,%eax
80102357:	74 0d                	je     80102366 <dirlookup+0x53>
      panic("dirlookup read");
80102359:	83 ec 0c             	sub    $0xc,%esp
8010235c:	68 77 8e 10 80       	push   $0x80108e77
80102361:	e8 a2 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102366:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010236a:	66 85 c0             	test   %ax,%ax
8010236d:	74 47                	je     801023b6 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
8010236f:	83 ec 08             	sub    $0x8,%esp
80102372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102375:	83 c0 02             	add    $0x2,%eax
80102378:	50                   	push   %eax
80102379:	ff 75 0c             	pushl  0xc(%ebp)
8010237c:	e8 73 ff ff ff       	call   801022f4 <namecmp>
80102381:	83 c4 10             	add    $0x10,%esp
80102384:	85 c0                	test   %eax,%eax
80102386:	75 2f                	jne    801023b7 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102388:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010238c:	74 08                	je     80102396 <dirlookup+0x83>
        *poff = off;
8010238e:	8b 45 10             	mov    0x10(%ebp),%eax
80102391:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102394:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102396:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010239a:	0f b7 c0             	movzwl %ax,%eax
8010239d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023a0:	8b 45 08             	mov    0x8(%ebp),%eax
801023a3:	8b 00                	mov    (%eax),%eax
801023a5:	83 ec 08             	sub    $0x8,%esp
801023a8:	ff 75 f0             	pushl  -0x10(%ebp)
801023ab:	50                   	push   %eax
801023ac:	e8 34 f6 ff ff       	call   801019e5 <iget>
801023b1:	83 c4 10             	add    $0x10,%esp
801023b4:	eb 19                	jmp    801023cf <dirlookup+0xbc>
      continue;
801023b6:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023bb:	8b 45 08             	mov    0x8(%ebp),%eax
801023be:	8b 40 58             	mov    0x58(%eax),%eax
801023c1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023c4:	0f 82 76 ff ff ff    	jb     80102340 <dirlookup+0x2d>
    }
  }

  return 0;
801023ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023cf:	c9                   	leave  
801023d0:	c3                   	ret    

801023d1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023d1:	f3 0f 1e fb          	endbr32 
801023d5:	55                   	push   %ebp
801023d6:	89 e5                	mov    %esp,%ebp
801023d8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023db:	83 ec 04             	sub    $0x4,%esp
801023de:	6a 00                	push   $0x0
801023e0:	ff 75 0c             	pushl  0xc(%ebp)
801023e3:	ff 75 08             	pushl  0x8(%ebp)
801023e6:	e8 28 ff ff ff       	call   80102313 <dirlookup>
801023eb:	83 c4 10             	add    $0x10,%esp
801023ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023f5:	74 18                	je     8010240f <dirlink+0x3e>
    iput(ip);
801023f7:	83 ec 0c             	sub    $0xc,%esp
801023fa:	ff 75 f0             	pushl  -0x10(%ebp)
801023fd:	e8 70 f8 ff ff       	call   80101c72 <iput>
80102402:	83 c4 10             	add    $0x10,%esp
    return -1;
80102405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010240a:	e9 9c 00 00 00       	jmp    801024ab <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010240f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102416:	eb 39                	jmp    80102451 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241b:	6a 10                	push   $0x10
8010241d:	50                   	push   %eax
8010241e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102421:	50                   	push   %eax
80102422:	ff 75 08             	pushl  0x8(%ebp)
80102425:	e8 e7 fb ff ff       	call   80102011 <readi>
8010242a:	83 c4 10             	add    $0x10,%esp
8010242d:	83 f8 10             	cmp    $0x10,%eax
80102430:	74 0d                	je     8010243f <dirlink+0x6e>
      panic("dirlink read");
80102432:	83 ec 0c             	sub    $0xc,%esp
80102435:	68 86 8e 10 80       	push   $0x80108e86
8010243a:	e8 c9 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010243f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102443:	66 85 c0             	test   %ax,%ax
80102446:	74 18                	je     80102460 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244b:	83 c0 10             	add    $0x10,%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102451:	8b 45 08             	mov    0x8(%ebp),%eax
80102454:	8b 50 58             	mov    0x58(%eax),%edx
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	39 c2                	cmp    %eax,%edx
8010245c:	77 ba                	ja     80102418 <dirlink+0x47>
8010245e:	eb 01                	jmp    80102461 <dirlink+0x90>
      break;
80102460:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102461:	83 ec 04             	sub    $0x4,%esp
80102464:	6a 0e                	push   $0xe
80102466:	ff 75 0c             	pushl  0xc(%ebp)
80102469:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010246c:	83 c0 02             	add    $0x2,%eax
8010246f:	50                   	push   %eax
80102470:	e8 1d 32 00 00       	call   80105692 <strncpy>
80102475:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102478:	8b 45 10             	mov    0x10(%ebp),%eax
8010247b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010247f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102482:	6a 10                	push   $0x10
80102484:	50                   	push   %eax
80102485:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102488:	50                   	push   %eax
80102489:	ff 75 08             	pushl  0x8(%ebp)
8010248c:	e8 d9 fc ff ff       	call   8010216a <writei>
80102491:	83 c4 10             	add    $0x10,%esp
80102494:	83 f8 10             	cmp    $0x10,%eax
80102497:	74 0d                	je     801024a6 <dirlink+0xd5>
    panic("dirlink");
80102499:	83 ec 0c             	sub    $0xc,%esp
8010249c:	68 93 8e 10 80       	push   $0x80108e93
801024a1:	e8 62 e1 ff ff       	call   80100608 <panic>

  return 0;
801024a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024ab:	c9                   	leave  
801024ac:	c3                   	ret    

801024ad <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024ad:	f3 0f 1e fb          	endbr32 
801024b1:	55                   	push   %ebp
801024b2:	89 e5                	mov    %esp,%ebp
801024b4:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024b7:	eb 04                	jmp    801024bd <skipelem+0x10>
    path++;
801024b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024bd:	8b 45 08             	mov    0x8(%ebp),%eax
801024c0:	0f b6 00             	movzbl (%eax),%eax
801024c3:	3c 2f                	cmp    $0x2f,%al
801024c5:	74 f2                	je     801024b9 <skipelem+0xc>
  if(*path == 0)
801024c7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ca:	0f b6 00             	movzbl (%eax),%eax
801024cd:	84 c0                	test   %al,%al
801024cf:	75 07                	jne    801024d8 <skipelem+0x2b>
    return 0;
801024d1:	b8 00 00 00 00       	mov    $0x0,%eax
801024d6:	eb 77                	jmp    8010254f <skipelem+0xa2>
  s = path;
801024d8:	8b 45 08             	mov    0x8(%ebp),%eax
801024db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024de:	eb 04                	jmp    801024e4 <skipelem+0x37>
    path++;
801024e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024e4:	8b 45 08             	mov    0x8(%ebp),%eax
801024e7:	0f b6 00             	movzbl (%eax),%eax
801024ea:	3c 2f                	cmp    $0x2f,%al
801024ec:	74 0a                	je     801024f8 <skipelem+0x4b>
801024ee:	8b 45 08             	mov    0x8(%ebp),%eax
801024f1:	0f b6 00             	movzbl (%eax),%eax
801024f4:	84 c0                	test   %al,%al
801024f6:	75 e8                	jne    801024e0 <skipelem+0x33>
  len = path - s;
801024f8:	8b 45 08             	mov    0x8(%ebp),%eax
801024fb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102501:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102505:	7e 15                	jle    8010251c <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102507:	83 ec 04             	sub    $0x4,%esp
8010250a:	6a 0e                	push   $0xe
8010250c:	ff 75 f4             	pushl  -0xc(%ebp)
8010250f:	ff 75 0c             	pushl  0xc(%ebp)
80102512:	e8 83 30 00 00       	call   8010559a <memmove>
80102517:	83 c4 10             	add    $0x10,%esp
8010251a:	eb 26                	jmp    80102542 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010251c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010251f:	83 ec 04             	sub    $0x4,%esp
80102522:	50                   	push   %eax
80102523:	ff 75 f4             	pushl  -0xc(%ebp)
80102526:	ff 75 0c             	pushl  0xc(%ebp)
80102529:	e8 6c 30 00 00       	call   8010559a <memmove>
8010252e:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102531:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102534:	8b 45 0c             	mov    0xc(%ebp),%eax
80102537:	01 d0                	add    %edx,%eax
80102539:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010253c:	eb 04                	jmp    80102542 <skipelem+0x95>
    path++;
8010253e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102542:	8b 45 08             	mov    0x8(%ebp),%eax
80102545:	0f b6 00             	movzbl (%eax),%eax
80102548:	3c 2f                	cmp    $0x2f,%al
8010254a:	74 f2                	je     8010253e <skipelem+0x91>
  return path;
8010254c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010254f:	c9                   	leave  
80102550:	c3                   	ret    

80102551 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102551:	f3 0f 1e fb          	endbr32 
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
80102558:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010255b:	8b 45 08             	mov    0x8(%ebp),%eax
8010255e:	0f b6 00             	movzbl (%eax),%eax
80102561:	3c 2f                	cmp    $0x2f,%al
80102563:	75 17                	jne    8010257c <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102565:	83 ec 08             	sub    $0x8,%esp
80102568:	6a 01                	push   $0x1
8010256a:	6a 01                	push   $0x1
8010256c:	e8 74 f4 ff ff       	call   801019e5 <iget>
80102571:	83 c4 10             	add    $0x10,%esp
80102574:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102577:	e9 ba 00 00 00       	jmp    80102636 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010257c:	e8 16 1f 00 00       	call   80104497 <myproc>
80102581:	8b 40 68             	mov    0x68(%eax),%eax
80102584:	83 ec 0c             	sub    $0xc,%esp
80102587:	50                   	push   %eax
80102588:	e8 3e f5 ff ff       	call   80101acb <idup>
8010258d:	83 c4 10             	add    $0x10,%esp
80102590:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102593:	e9 9e 00 00 00       	jmp    80102636 <namex+0xe5>
    ilock(ip);
80102598:	83 ec 0c             	sub    $0xc,%esp
8010259b:	ff 75 f4             	pushl  -0xc(%ebp)
8010259e:	e8 66 f5 ff ff       	call   80101b09 <ilock>
801025a3:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025ad:	66 83 f8 01          	cmp    $0x1,%ax
801025b1:	74 18                	je     801025cb <namex+0x7a>
      iunlockput(ip);
801025b3:	83 ec 0c             	sub    $0xc,%esp
801025b6:	ff 75 f4             	pushl  -0xc(%ebp)
801025b9:	e8 88 f7 ff ff       	call   80101d46 <iunlockput>
801025be:	83 c4 10             	add    $0x10,%esp
      return 0;
801025c1:	b8 00 00 00 00       	mov    $0x0,%eax
801025c6:	e9 a7 00 00 00       	jmp    80102672 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cf:	74 20                	je     801025f1 <namex+0xa0>
801025d1:	8b 45 08             	mov    0x8(%ebp),%eax
801025d4:	0f b6 00             	movzbl (%eax),%eax
801025d7:	84 c0                	test   %al,%al
801025d9:	75 16                	jne    801025f1 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025db:	83 ec 0c             	sub    $0xc,%esp
801025de:	ff 75 f4             	pushl  -0xc(%ebp)
801025e1:	e8 3a f6 ff ff       	call   80101c20 <iunlock>
801025e6:	83 c4 10             	add    $0x10,%esp
      return ip;
801025e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ec:	e9 81 00 00 00       	jmp    80102672 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	6a 00                	push   $0x0
801025f6:	ff 75 10             	pushl  0x10(%ebp)
801025f9:	ff 75 f4             	pushl  -0xc(%ebp)
801025fc:	e8 12 fd ff ff       	call   80102313 <dirlookup>
80102601:	83 c4 10             	add    $0x10,%esp
80102604:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102607:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010260b:	75 15                	jne    80102622 <namex+0xd1>
      iunlockput(ip);
8010260d:	83 ec 0c             	sub    $0xc,%esp
80102610:	ff 75 f4             	pushl  -0xc(%ebp)
80102613:	e8 2e f7 ff ff       	call   80101d46 <iunlockput>
80102618:	83 c4 10             	add    $0x10,%esp
      return 0;
8010261b:	b8 00 00 00 00       	mov    $0x0,%eax
80102620:	eb 50                	jmp    80102672 <namex+0x121>
    }
    iunlockput(ip);
80102622:	83 ec 0c             	sub    $0xc,%esp
80102625:	ff 75 f4             	pushl  -0xc(%ebp)
80102628:	e8 19 f7 ff ff       	call   80101d46 <iunlockput>
8010262d:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102633:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102636:	83 ec 08             	sub    $0x8,%esp
80102639:	ff 75 10             	pushl  0x10(%ebp)
8010263c:	ff 75 08             	pushl  0x8(%ebp)
8010263f:	e8 69 fe ff ff       	call   801024ad <skipelem>
80102644:	83 c4 10             	add    $0x10,%esp
80102647:	89 45 08             	mov    %eax,0x8(%ebp)
8010264a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010264e:	0f 85 44 ff ff ff    	jne    80102598 <namex+0x47>
  }
  if(nameiparent){
80102654:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102658:	74 15                	je     8010266f <namex+0x11e>
    iput(ip);
8010265a:	83 ec 0c             	sub    $0xc,%esp
8010265d:	ff 75 f4             	pushl  -0xc(%ebp)
80102660:	e8 0d f6 ff ff       	call   80101c72 <iput>
80102665:	83 c4 10             	add    $0x10,%esp
    return 0;
80102668:	b8 00 00 00 00       	mov    $0x0,%eax
8010266d:	eb 03                	jmp    80102672 <namex+0x121>
  }
  return ip;
8010266f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102672:	c9                   	leave  
80102673:	c3                   	ret    

80102674 <namei>:

struct inode*
namei(char *path)
{
80102674:	f3 0f 1e fb          	endbr32 
80102678:	55                   	push   %ebp
80102679:	89 e5                	mov    %esp,%ebp
8010267b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010267e:	83 ec 04             	sub    $0x4,%esp
80102681:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102684:	50                   	push   %eax
80102685:	6a 00                	push   $0x0
80102687:	ff 75 08             	pushl  0x8(%ebp)
8010268a:	e8 c2 fe ff ff       	call   80102551 <namex>
8010268f:	83 c4 10             	add    $0x10,%esp
}
80102692:	c9                   	leave  
80102693:	c3                   	ret    

80102694 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102694:	f3 0f 1e fb          	endbr32 
80102698:	55                   	push   %ebp
80102699:	89 e5                	mov    %esp,%ebp
8010269b:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010269e:	83 ec 04             	sub    $0x4,%esp
801026a1:	ff 75 0c             	pushl  0xc(%ebp)
801026a4:	6a 01                	push   $0x1
801026a6:	ff 75 08             	pushl  0x8(%ebp)
801026a9:	e8 a3 fe ff ff       	call   80102551 <namex>
801026ae:	83 c4 10             	add    $0x10,%esp
}
801026b1:	c9                   	leave  
801026b2:	c3                   	ret    

801026b3 <inb>:
{
801026b3:	55                   	push   %ebp
801026b4:	89 e5                	mov    %esp,%ebp
801026b6:	83 ec 14             	sub    $0x14,%esp
801026b9:	8b 45 08             	mov    0x8(%ebp),%eax
801026bc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026c0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801026c4:	89 c2                	mov    %eax,%edx
801026c6:	ec                   	in     (%dx),%al
801026c7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026ca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801026ce:	c9                   	leave  
801026cf:	c3                   	ret    

801026d0 <insl>:
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	57                   	push   %edi
801026d4:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026d5:	8b 55 08             	mov    0x8(%ebp),%edx
801026d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026db:	8b 45 10             	mov    0x10(%ebp),%eax
801026de:	89 cb                	mov    %ecx,%ebx
801026e0:	89 df                	mov    %ebx,%edi
801026e2:	89 c1                	mov    %eax,%ecx
801026e4:	fc                   	cld    
801026e5:	f3 6d                	rep insl (%dx),%es:(%edi)
801026e7:	89 c8                	mov    %ecx,%eax
801026e9:	89 fb                	mov    %edi,%ebx
801026eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026ee:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026f1:	90                   	nop
801026f2:	5b                   	pop    %ebx
801026f3:	5f                   	pop    %edi
801026f4:	5d                   	pop    %ebp
801026f5:	c3                   	ret    

801026f6 <outb>:
{
801026f6:	55                   	push   %ebp
801026f7:	89 e5                	mov    %esp,%ebp
801026f9:	83 ec 08             	sub    $0x8,%esp
801026fc:	8b 45 08             	mov    0x8(%ebp),%eax
801026ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80102702:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102706:	89 d0                	mov    %edx,%eax
80102708:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010270b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010270f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102713:	ee                   	out    %al,(%dx)
}
80102714:	90                   	nop
80102715:	c9                   	leave  
80102716:	c3                   	ret    

80102717 <outsl>:
{
80102717:	55                   	push   %ebp
80102718:	89 e5                	mov    %esp,%ebp
8010271a:	56                   	push   %esi
8010271b:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010271c:	8b 55 08             	mov    0x8(%ebp),%edx
8010271f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102722:	8b 45 10             	mov    0x10(%ebp),%eax
80102725:	89 cb                	mov    %ecx,%ebx
80102727:	89 de                	mov    %ebx,%esi
80102729:	89 c1                	mov    %eax,%ecx
8010272b:	fc                   	cld    
8010272c:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010272e:	89 c8                	mov    %ecx,%eax
80102730:	89 f3                	mov    %esi,%ebx
80102732:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102735:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102738:	90                   	nop
80102739:	5b                   	pop    %ebx
8010273a:	5e                   	pop    %esi
8010273b:	5d                   	pop    %ebp
8010273c:	c3                   	ret    

8010273d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010273d:	f3 0f 1e fb          	endbr32 
80102741:	55                   	push   %ebp
80102742:	89 e5                	mov    %esp,%ebp
80102744:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102747:	90                   	nop
80102748:	68 f7 01 00 00       	push   $0x1f7
8010274d:	e8 61 ff ff ff       	call   801026b3 <inb>
80102752:	83 c4 04             	add    $0x4,%esp
80102755:	0f b6 c0             	movzbl %al,%eax
80102758:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010275b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010275e:	25 c0 00 00 00       	and    $0xc0,%eax
80102763:	83 f8 40             	cmp    $0x40,%eax
80102766:	75 e0                	jne    80102748 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102768:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010276c:	74 11                	je     8010277f <idewait+0x42>
8010276e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102771:	83 e0 21             	and    $0x21,%eax
80102774:	85 c0                	test   %eax,%eax
80102776:	74 07                	je     8010277f <idewait+0x42>
    return -1;
80102778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010277d:	eb 05                	jmp    80102784 <idewait+0x47>
  return 0;
8010277f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102784:	c9                   	leave  
80102785:	c3                   	ret    

80102786 <ideinit>:

void
ideinit(void)
{
80102786:	f3 0f 1e fb          	endbr32 
8010278a:	55                   	push   %ebp
8010278b:	89 e5                	mov    %esp,%ebp
8010278d:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102790:	83 ec 08             	sub    $0x8,%esp
80102793:	68 9b 8e 10 80       	push   $0x80108e9b
80102798:	68 00 c6 10 80       	push   $0x8010c600
8010279d:	e8 6c 2a 00 00       	call   8010520e <initlock>
801027a2:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027a5:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027aa:	83 e8 01             	sub    $0x1,%eax
801027ad:	83 ec 08             	sub    $0x8,%esp
801027b0:	50                   	push   %eax
801027b1:	6a 0e                	push   $0xe
801027b3:	e8 bb 04 00 00       	call   80102c73 <ioapicenable>
801027b8:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027bb:	83 ec 0c             	sub    $0xc,%esp
801027be:	6a 00                	push   $0x0
801027c0:	e8 78 ff ff ff       	call   8010273d <idewait>
801027c5:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027c8:	83 ec 08             	sub    $0x8,%esp
801027cb:	68 f0 00 00 00       	push   $0xf0
801027d0:	68 f6 01 00 00       	push   $0x1f6
801027d5:	e8 1c ff ff ff       	call   801026f6 <outb>
801027da:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801027dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027e4:	eb 24                	jmp    8010280a <ideinit+0x84>
    if(inb(0x1f7) != 0){
801027e6:	83 ec 0c             	sub    $0xc,%esp
801027e9:	68 f7 01 00 00       	push   $0x1f7
801027ee:	e8 c0 fe ff ff       	call   801026b3 <inb>
801027f3:	83 c4 10             	add    $0x10,%esp
801027f6:	84 c0                	test   %al,%al
801027f8:	74 0c                	je     80102806 <ideinit+0x80>
      havedisk1 = 1;
801027fa:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102801:	00 00 00 
      break;
80102804:	eb 0d                	jmp    80102813 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102806:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010280a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102811:	7e d3                	jle    801027e6 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102813:	83 ec 08             	sub    $0x8,%esp
80102816:	68 e0 00 00 00       	push   $0xe0
8010281b:	68 f6 01 00 00       	push   $0x1f6
80102820:	e8 d1 fe ff ff       	call   801026f6 <outb>
80102825:	83 c4 10             	add    $0x10,%esp
}
80102828:	90                   	nop
80102829:	c9                   	leave  
8010282a:	c3                   	ret    

8010282b <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010282b:	f3 0f 1e fb          	endbr32 
8010282f:	55                   	push   %ebp
80102830:	89 e5                	mov    %esp,%ebp
80102832:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102835:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102839:	75 0d                	jne    80102848 <idestart+0x1d>
    panic("idestart");
8010283b:	83 ec 0c             	sub    $0xc,%esp
8010283e:	68 9f 8e 10 80       	push   $0x80108e9f
80102843:	e8 c0 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102848:	8b 45 08             	mov    0x8(%ebp),%eax
8010284b:	8b 40 08             	mov    0x8(%eax),%eax
8010284e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102853:	76 0d                	jbe    80102862 <idestart+0x37>
    panic("incorrect blockno");
80102855:	83 ec 0c             	sub    $0xc,%esp
80102858:	68 a8 8e 10 80       	push   $0x80108ea8
8010285d:	e8 a6 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102862:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102869:	8b 45 08             	mov    0x8(%ebp),%eax
8010286c:	8b 50 08             	mov    0x8(%eax),%edx
8010286f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102872:	0f af c2             	imul   %edx,%eax
80102875:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102878:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010287c:	75 07                	jne    80102885 <idestart+0x5a>
8010287e:	b8 20 00 00 00       	mov    $0x20,%eax
80102883:	eb 05                	jmp    8010288a <idestart+0x5f>
80102885:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010288a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010288d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102891:	75 07                	jne    8010289a <idestart+0x6f>
80102893:	b8 30 00 00 00       	mov    $0x30,%eax
80102898:	eb 05                	jmp    8010289f <idestart+0x74>
8010289a:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010289f:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028a2:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028a6:	7e 0d                	jle    801028b5 <idestart+0x8a>
801028a8:	83 ec 0c             	sub    $0xc,%esp
801028ab:	68 9f 8e 10 80       	push   $0x80108e9f
801028b0:	e8 53 dd ff ff       	call   80100608 <panic>

  idewait(0);
801028b5:	83 ec 0c             	sub    $0xc,%esp
801028b8:	6a 00                	push   $0x0
801028ba:	e8 7e fe ff ff       	call   8010273d <idewait>
801028bf:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028c2:	83 ec 08             	sub    $0x8,%esp
801028c5:	6a 00                	push   $0x0
801028c7:	68 f6 03 00 00       	push   $0x3f6
801028cc:	e8 25 fe ff ff       	call   801026f6 <outb>
801028d1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801028d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d7:	0f b6 c0             	movzbl %al,%eax
801028da:	83 ec 08             	sub    $0x8,%esp
801028dd:	50                   	push   %eax
801028de:	68 f2 01 00 00       	push   $0x1f2
801028e3:	e8 0e fe ff ff       	call   801026f6 <outb>
801028e8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801028eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ee:	0f b6 c0             	movzbl %al,%eax
801028f1:	83 ec 08             	sub    $0x8,%esp
801028f4:	50                   	push   %eax
801028f5:	68 f3 01 00 00       	push   $0x1f3
801028fa:	e8 f7 fd ff ff       	call   801026f6 <outb>
801028ff:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102905:	c1 f8 08             	sar    $0x8,%eax
80102908:	0f b6 c0             	movzbl %al,%eax
8010290b:	83 ec 08             	sub    $0x8,%esp
8010290e:	50                   	push   %eax
8010290f:	68 f4 01 00 00       	push   $0x1f4
80102914:	e8 dd fd ff ff       	call   801026f6 <outb>
80102919:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010291c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010291f:	c1 f8 10             	sar    $0x10,%eax
80102922:	0f b6 c0             	movzbl %al,%eax
80102925:	83 ec 08             	sub    $0x8,%esp
80102928:	50                   	push   %eax
80102929:	68 f5 01 00 00       	push   $0x1f5
8010292e:	e8 c3 fd ff ff       	call   801026f6 <outb>
80102933:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102936:	8b 45 08             	mov    0x8(%ebp),%eax
80102939:	8b 40 04             	mov    0x4(%eax),%eax
8010293c:	c1 e0 04             	shl    $0x4,%eax
8010293f:	83 e0 10             	and    $0x10,%eax
80102942:	89 c2                	mov    %eax,%edx
80102944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102947:	c1 f8 18             	sar    $0x18,%eax
8010294a:	83 e0 0f             	and    $0xf,%eax
8010294d:	09 d0                	or     %edx,%eax
8010294f:	83 c8 e0             	or     $0xffffffe0,%eax
80102952:	0f b6 c0             	movzbl %al,%eax
80102955:	83 ec 08             	sub    $0x8,%esp
80102958:	50                   	push   %eax
80102959:	68 f6 01 00 00       	push   $0x1f6
8010295e:	e8 93 fd ff ff       	call   801026f6 <outb>
80102963:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102966:	8b 45 08             	mov    0x8(%ebp),%eax
80102969:	8b 00                	mov    (%eax),%eax
8010296b:	83 e0 04             	and    $0x4,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 35                	je     801029a7 <idestart+0x17c>
    outb(0x1f7, write_cmd);
80102972:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102975:	0f b6 c0             	movzbl %al,%eax
80102978:	83 ec 08             	sub    $0x8,%esp
8010297b:	50                   	push   %eax
8010297c:	68 f7 01 00 00       	push   $0x1f7
80102981:	e8 70 fd ff ff       	call   801026f6 <outb>
80102986:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102989:	8b 45 08             	mov    0x8(%ebp),%eax
8010298c:	83 c0 5c             	add    $0x5c,%eax
8010298f:	83 ec 04             	sub    $0x4,%esp
80102992:	68 80 00 00 00       	push   $0x80
80102997:	50                   	push   %eax
80102998:	68 f0 01 00 00       	push   $0x1f0
8010299d:	e8 75 fd ff ff       	call   80102717 <outsl>
801029a2:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029a5:	eb 17                	jmp    801029be <idestart+0x193>
    outb(0x1f7, read_cmd);
801029a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029aa:	0f b6 c0             	movzbl %al,%eax
801029ad:	83 ec 08             	sub    $0x8,%esp
801029b0:	50                   	push   %eax
801029b1:	68 f7 01 00 00       	push   $0x1f7
801029b6:	e8 3b fd ff ff       	call   801026f6 <outb>
801029bb:	83 c4 10             	add    $0x10,%esp
}
801029be:	90                   	nop
801029bf:	c9                   	leave  
801029c0:	c3                   	ret    

801029c1 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029c1:	f3 0f 1e fb          	endbr32 
801029c5:	55                   	push   %ebp
801029c6:	89 e5                	mov    %esp,%ebp
801029c8:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029cb:	83 ec 0c             	sub    $0xc,%esp
801029ce:	68 00 c6 10 80       	push   $0x8010c600
801029d3:	e8 5c 28 00 00       	call   80105234 <acquire>
801029d8:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801029db:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801029e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029e7:	75 15                	jne    801029fe <ideintr+0x3d>
    release(&idelock);
801029e9:	83 ec 0c             	sub    $0xc,%esp
801029ec:	68 00 c6 10 80       	push   $0x8010c600
801029f1:	e8 b0 28 00 00       	call   801052a6 <release>
801029f6:	83 c4 10             	add    $0x10,%esp
    return;
801029f9:	e9 9a 00 00 00       	jmp    80102a98 <ideintr+0xd7>
  }
  idequeue = b->qnext;
801029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a01:	8b 40 58             	mov    0x58(%eax),%eax
80102a04:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	8b 00                	mov    (%eax),%eax
80102a0e:	83 e0 04             	and    $0x4,%eax
80102a11:	85 c0                	test   %eax,%eax
80102a13:	75 2d                	jne    80102a42 <ideintr+0x81>
80102a15:	83 ec 0c             	sub    $0xc,%esp
80102a18:	6a 01                	push   $0x1
80102a1a:	e8 1e fd ff ff       	call   8010273d <idewait>
80102a1f:	83 c4 10             	add    $0x10,%esp
80102a22:	85 c0                	test   %eax,%eax
80102a24:	78 1c                	js     80102a42 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a29:	83 c0 5c             	add    $0x5c,%eax
80102a2c:	83 ec 04             	sub    $0x4,%esp
80102a2f:	68 80 00 00 00       	push   $0x80
80102a34:	50                   	push   %eax
80102a35:	68 f0 01 00 00       	push   $0x1f0
80102a3a:	e8 91 fc ff ff       	call   801026d0 <insl>
80102a3f:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a45:	8b 00                	mov    (%eax),%eax
80102a47:	83 c8 02             	or     $0x2,%eax
80102a4a:	89 c2                	mov    %eax,%edx
80102a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4f:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a54:	8b 00                	mov    (%eax),%eax
80102a56:	83 e0 fb             	and    $0xfffffffb,%eax
80102a59:	89 c2                	mov    %eax,%edx
80102a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5e:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a60:	83 ec 0c             	sub    $0xc,%esp
80102a63:	ff 75 f4             	pushl  -0xc(%ebp)
80102a66:	e8 4f 24 00 00       	call   80104eba <wakeup>
80102a6b:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a6e:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a73:	85 c0                	test   %eax,%eax
80102a75:	74 11                	je     80102a88 <ideintr+0xc7>
    idestart(idequeue);
80102a77:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a7c:	83 ec 0c             	sub    $0xc,%esp
80102a7f:	50                   	push   %eax
80102a80:	e8 a6 fd ff ff       	call   8010282b <idestart>
80102a85:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a88:	83 ec 0c             	sub    $0xc,%esp
80102a8b:	68 00 c6 10 80       	push   $0x8010c600
80102a90:	e8 11 28 00 00       	call   801052a6 <release>
80102a95:	83 c4 10             	add    $0x10,%esp
}
80102a98:	c9                   	leave  
80102a99:	c3                   	ret    

80102a9a <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a9a:	f3 0f 1e fb          	endbr32 
80102a9e:	55                   	push   %ebp
80102a9f:	89 e5                	mov    %esp,%ebp
80102aa1:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa7:	83 c0 0c             	add    $0xc,%eax
80102aaa:	83 ec 0c             	sub    $0xc,%esp
80102aad:	50                   	push   %eax
80102aae:	e8 c2 26 00 00       	call   80105175 <holdingsleep>
80102ab3:	83 c4 10             	add    $0x10,%esp
80102ab6:	85 c0                	test   %eax,%eax
80102ab8:	75 0d                	jne    80102ac7 <iderw+0x2d>
    panic("iderw: buf not locked");
80102aba:	83 ec 0c             	sub    $0xc,%esp
80102abd:	68 ba 8e 10 80       	push   $0x80108eba
80102ac2:	e8 41 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aca:	8b 00                	mov    (%eax),%eax
80102acc:	83 e0 06             	and    $0x6,%eax
80102acf:	83 f8 02             	cmp    $0x2,%eax
80102ad2:	75 0d                	jne    80102ae1 <iderw+0x47>
    panic("iderw: nothing to do");
80102ad4:	83 ec 0c             	sub    $0xc,%esp
80102ad7:	68 d0 8e 10 80       	push   $0x80108ed0
80102adc:	e8 27 db ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae4:	8b 40 04             	mov    0x4(%eax),%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	74 16                	je     80102b01 <iderw+0x67>
80102aeb:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102af0:	85 c0                	test   %eax,%eax
80102af2:	75 0d                	jne    80102b01 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102af4:	83 ec 0c             	sub    $0xc,%esp
80102af7:	68 e5 8e 10 80       	push   $0x80108ee5
80102afc:	e8 07 db ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b01:	83 ec 0c             	sub    $0xc,%esp
80102b04:	68 00 c6 10 80       	push   $0x8010c600
80102b09:	e8 26 27 00 00       	call   80105234 <acquire>
80102b0e:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b11:	8b 45 08             	mov    0x8(%ebp),%eax
80102b14:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b1b:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b22:	eb 0b                	jmp    80102b2f <iderw+0x95>
80102b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b27:	8b 00                	mov    (%eax),%eax
80102b29:	83 c0 58             	add    $0x58,%eax
80102b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b32:	8b 00                	mov    (%eax),%eax
80102b34:	85 c0                	test   %eax,%eax
80102b36:	75 ec                	jne    80102b24 <iderw+0x8a>
    ;
  *pp = b;
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b3e:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b40:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b45:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b48:	75 23                	jne    80102b6d <iderw+0xd3>
    idestart(b);
80102b4a:	83 ec 0c             	sub    $0xc,%esp
80102b4d:	ff 75 08             	pushl  0x8(%ebp)
80102b50:	e8 d6 fc ff ff       	call   8010282b <idestart>
80102b55:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b58:	eb 13                	jmp    80102b6d <iderw+0xd3>
    sleep(b, &idelock);
80102b5a:	83 ec 08             	sub    $0x8,%esp
80102b5d:	68 00 c6 10 80       	push   $0x8010c600
80102b62:	ff 75 08             	pushl  0x8(%ebp)
80102b65:	e8 61 22 00 00       	call   80104dcb <sleep>
80102b6a:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b70:	8b 00                	mov    (%eax),%eax
80102b72:	83 e0 06             	and    $0x6,%eax
80102b75:	83 f8 02             	cmp    $0x2,%eax
80102b78:	75 e0                	jne    80102b5a <iderw+0xc0>
  }


  release(&idelock);
80102b7a:	83 ec 0c             	sub    $0xc,%esp
80102b7d:	68 00 c6 10 80       	push   $0x8010c600
80102b82:	e8 1f 27 00 00       	call   801052a6 <release>
80102b87:	83 c4 10             	add    $0x10,%esp
}
80102b8a:	90                   	nop
80102b8b:	c9                   	leave  
80102b8c:	c3                   	ret    

80102b8d <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b8d:	f3 0f 1e fb          	endbr32 
80102b91:	55                   	push   %ebp
80102b92:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b94:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102b99:	8b 55 08             	mov    0x8(%ebp),%edx
80102b9c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b9e:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102ba3:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ba6:	5d                   	pop    %ebp
80102ba7:	c3                   	ret    

80102ba8 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ba8:	f3 0f 1e fb          	endbr32 
80102bac:	55                   	push   %ebp
80102bad:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102baf:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bb4:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb7:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bb9:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bc1:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bc4:	90                   	nop
80102bc5:	5d                   	pop    %ebp
80102bc6:	c3                   	ret    

80102bc7 <ioapicinit>:

void
ioapicinit(void)
{
80102bc7:	f3 0f 1e fb          	endbr32 
80102bcb:	55                   	push   %ebp
80102bcc:	89 e5                	mov    %esp,%ebp
80102bce:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bd1:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102bd8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bdb:	6a 01                	push   $0x1
80102bdd:	e8 ab ff ff ff       	call   80102b8d <ioapicread>
80102be2:	83 c4 04             	add    $0x4,%esp
80102be5:	c1 e8 10             	shr    $0x10,%eax
80102be8:	25 ff 00 00 00       	and    $0xff,%eax
80102bed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bf0:	6a 00                	push   $0x0
80102bf2:	e8 96 ff ff ff       	call   80102b8d <ioapicread>
80102bf7:	83 c4 04             	add    $0x4,%esp
80102bfa:	c1 e8 18             	shr    $0x18,%eax
80102bfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c00:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c07:	0f b6 c0             	movzbl %al,%eax
80102c0a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c0d:	74 10                	je     80102c1f <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c0f:	83 ec 0c             	sub    $0xc,%esp
80102c12:	68 04 8f 10 80       	push   $0x80108f04
80102c17:	e8 fc d7 ff ff       	call   80100418 <cprintf>
80102c1c:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c26:	eb 3f                	jmp    80102c67 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2b:	83 c0 20             	add    $0x20,%eax
80102c2e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c33:	89 c2                	mov    %eax,%edx
80102c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c38:	83 c0 08             	add    $0x8,%eax
80102c3b:	01 c0                	add    %eax,%eax
80102c3d:	83 ec 08             	sub    $0x8,%esp
80102c40:	52                   	push   %edx
80102c41:	50                   	push   %eax
80102c42:	e8 61 ff ff ff       	call   80102ba8 <ioapicwrite>
80102c47:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c4d:	83 c0 08             	add    $0x8,%eax
80102c50:	01 c0                	add    %eax,%eax
80102c52:	83 c0 01             	add    $0x1,%eax
80102c55:	83 ec 08             	sub    $0x8,%esp
80102c58:	6a 00                	push   $0x0
80102c5a:	50                   	push   %eax
80102c5b:	e8 48 ff ff ff       	call   80102ba8 <ioapicwrite>
80102c60:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c6d:	7e b9                	jle    80102c28 <ioapicinit+0x61>
  }
}
80102c6f:	90                   	nop
80102c70:	90                   	nop
80102c71:	c9                   	leave  
80102c72:	c3                   	ret    

80102c73 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c73:	f3 0f 1e fb          	endbr32 
80102c77:	55                   	push   %ebp
80102c78:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7d:	83 c0 20             	add    $0x20,%eax
80102c80:	89 c2                	mov    %eax,%edx
80102c82:	8b 45 08             	mov    0x8(%ebp),%eax
80102c85:	83 c0 08             	add    $0x8,%eax
80102c88:	01 c0                	add    %eax,%eax
80102c8a:	52                   	push   %edx
80102c8b:	50                   	push   %eax
80102c8c:	e8 17 ff ff ff       	call   80102ba8 <ioapicwrite>
80102c91:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c97:	c1 e0 18             	shl    $0x18,%eax
80102c9a:	89 c2                	mov    %eax,%edx
80102c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9f:	83 c0 08             	add    $0x8,%eax
80102ca2:	01 c0                	add    %eax,%eax
80102ca4:	83 c0 01             	add    $0x1,%eax
80102ca7:	52                   	push   %edx
80102ca8:	50                   	push   %eax
80102ca9:	e8 fa fe ff ff       	call   80102ba8 <ioapicwrite>
80102cae:	83 c4 08             	add    $0x8,%esp
}
80102cb1:	90                   	nop
80102cb2:	c9                   	leave  
80102cb3:	c3                   	ret    

80102cb4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cb4:	f3 0f 1e fb          	endbr32 
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cbe:	83 ec 08             	sub    $0x8,%esp
80102cc1:	68 36 8f 10 80       	push   $0x80108f36
80102cc6:	68 e0 46 11 80       	push   $0x801146e0
80102ccb:	e8 3e 25 00 00       	call   8010520e <initlock>
80102cd0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102cd3:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102cda:	00 00 00 
  freerange(vstart, vend);
80102cdd:	83 ec 08             	sub    $0x8,%esp
80102ce0:	ff 75 0c             	pushl  0xc(%ebp)
80102ce3:	ff 75 08             	pushl  0x8(%ebp)
80102ce6:	e8 2e 00 00 00       	call   80102d19 <freerange>
80102ceb:	83 c4 10             	add    $0x10,%esp
}
80102cee:	90                   	nop
80102cef:	c9                   	leave  
80102cf0:	c3                   	ret    

80102cf1 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102cf1:	f3 0f 1e fb          	endbr32 
80102cf5:	55                   	push   %ebp
80102cf6:	89 e5                	mov    %esp,%ebp
80102cf8:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102cfb:	83 ec 08             	sub    $0x8,%esp
80102cfe:	ff 75 0c             	pushl  0xc(%ebp)
80102d01:	ff 75 08             	pushl  0x8(%ebp)
80102d04:	e8 10 00 00 00       	call   80102d19 <freerange>
80102d09:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d0c:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d13:	00 00 00 
}
80102d16:	90                   	nop
80102d17:	c9                   	leave  
80102d18:	c3                   	ret    

80102d19 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d19:	f3 0f 1e fb          	endbr32 
80102d1d:	55                   	push   %ebp
80102d1e:	89 e5                	mov    %esp,%ebp
80102d20:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d23:	8b 45 08             	mov    0x8(%ebp),%eax
80102d26:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d33:	eb 15                	jmp    80102d4a <freerange+0x31>
    kfree(p);
80102d35:	83 ec 0c             	sub    $0xc,%esp
80102d38:	ff 75 f4             	pushl  -0xc(%ebp)
80102d3b:	e8 1b 00 00 00       	call   80102d5b <kfree>
80102d40:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d43:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d4d:	05 00 10 00 00       	add    $0x1000,%eax
80102d52:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d55:	73 de                	jae    80102d35 <freerange+0x1c>
}
80102d57:	90                   	nop
80102d58:	90                   	nop
80102d59:	c9                   	leave  
80102d5a:	c3                   	ret    

80102d5b <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d5b:	f3 0f 1e fb          	endbr32 
80102d5f:	55                   	push   %ebp
80102d60:	89 e5                	mov    %esp,%ebp
80102d62:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d65:	8b 45 08             	mov    0x8(%ebp),%eax
80102d68:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d6d:	85 c0                	test   %eax,%eax
80102d6f:	75 18                	jne    80102d89 <kfree+0x2e>
80102d71:	81 7d 08 48 75 11 80 	cmpl   $0x80117548,0x8(%ebp)
80102d78:	72 0f                	jb     80102d89 <kfree+0x2e>
80102d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7d:	05 00 00 00 80       	add    $0x80000000,%eax
80102d82:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d87:	76 0d                	jbe    80102d96 <kfree+0x3b>
    panic("kfree");
80102d89:	83 ec 0c             	sub    $0xc,%esp
80102d8c:	68 3b 8f 10 80       	push   $0x80108f3b
80102d91:	e8 72 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d96:	83 ec 04             	sub    $0x4,%esp
80102d99:	68 00 10 00 00       	push   $0x1000
80102d9e:	6a 01                	push   $0x1
80102da0:	ff 75 08             	pushl  0x8(%ebp)
80102da3:	e8 2b 27 00 00       	call   801054d3 <memset>
80102da8:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dab:	a1 14 47 11 80       	mov    0x80114714,%eax
80102db0:	85 c0                	test   %eax,%eax
80102db2:	74 10                	je     80102dc4 <kfree+0x69>
    acquire(&kmem.lock);
80102db4:	83 ec 0c             	sub    $0xc,%esp
80102db7:	68 e0 46 11 80       	push   $0x801146e0
80102dbc:	e8 73 24 00 00       	call   80105234 <acquire>
80102dc1:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102dca:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dd3:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dd8:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102ddd:	a1 14 47 11 80       	mov    0x80114714,%eax
80102de2:	85 c0                	test   %eax,%eax
80102de4:	74 10                	je     80102df6 <kfree+0x9b>
    release(&kmem.lock);
80102de6:	83 ec 0c             	sub    $0xc,%esp
80102de9:	68 e0 46 11 80       	push   $0x801146e0
80102dee:	e8 b3 24 00 00       	call   801052a6 <release>
80102df3:	83 c4 10             	add    $0x10,%esp
}
80102df6:	90                   	nop
80102df7:	c9                   	leave  
80102df8:	c3                   	ret    

80102df9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102df9:	f3 0f 1e fb          	endbr32 
80102dfd:	55                   	push   %ebp
80102dfe:	89 e5                	mov    %esp,%ebp
80102e00:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e03:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e08:	85 c0                	test   %eax,%eax
80102e0a:	74 10                	je     80102e1c <kalloc+0x23>
    acquire(&kmem.lock);
80102e0c:	83 ec 0c             	sub    $0xc,%esp
80102e0f:	68 e0 46 11 80       	push   $0x801146e0
80102e14:	e8 1b 24 00 00       	call   80105234 <acquire>
80102e19:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e1c:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e28:	74 0a                	je     80102e34 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e2d:	8b 00                	mov    (%eax),%eax
80102e2f:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e34:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e39:	85 c0                	test   %eax,%eax
80102e3b:	74 10                	je     80102e4d <kalloc+0x54>
    release(&kmem.lock);
80102e3d:	83 ec 0c             	sub    $0xc,%esp
80102e40:	68 e0 46 11 80       	push   $0x801146e0
80102e45:	e8 5c 24 00 00       	call   801052a6 <release>
80102e4a:	83 c4 10             	add    $0x10,%esp

  return (char*)r;
80102e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e50:	c9                   	leave  
80102e51:	c3                   	ret    

80102e52 <inb>:
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 14             	sub    $0x14,%esp
80102e58:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e5f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e63:	89 c2                	mov    %eax,%edx
80102e65:	ec                   	in     (%dx),%al
80102e66:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e69:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e6d:	c9                   	leave  
80102e6e:	c3                   	ret    

80102e6f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e6f:	f3 0f 1e fb          	endbr32 
80102e73:	55                   	push   %ebp
80102e74:	89 e5                	mov    %esp,%ebp
80102e76:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e79:	6a 64                	push   $0x64
80102e7b:	e8 d2 ff ff ff       	call   80102e52 <inb>
80102e80:	83 c4 04             	add    $0x4,%esp
80102e83:	0f b6 c0             	movzbl %al,%eax
80102e86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8c:	83 e0 01             	and    $0x1,%eax
80102e8f:	85 c0                	test   %eax,%eax
80102e91:	75 0a                	jne    80102e9d <kbdgetc+0x2e>
    return -1;
80102e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e98:	e9 23 01 00 00       	jmp    80102fc0 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e9d:	6a 60                	push   $0x60
80102e9f:	e8 ae ff ff ff       	call   80102e52 <inb>
80102ea4:	83 c4 04             	add    $0x4,%esp
80102ea7:	0f b6 c0             	movzbl %al,%eax
80102eaa:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ead:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102eb4:	75 17                	jne    80102ecd <kbdgetc+0x5e>
    shift |= E0ESC;
80102eb6:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ebb:	83 c8 40             	or     $0x40,%eax
80102ebe:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102ec3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ec8:	e9 f3 00 00 00       	jmp    80102fc0 <kbdgetc+0x151>
  } else if(data & 0x80){
80102ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed0:	25 80 00 00 00       	and    $0x80,%eax
80102ed5:	85 c0                	test   %eax,%eax
80102ed7:	74 45                	je     80102f1e <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ed9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ede:	83 e0 40             	and    $0x40,%eax
80102ee1:	85 c0                	test   %eax,%eax
80102ee3:	75 08                	jne    80102eed <kbdgetc+0x7e>
80102ee5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee8:	83 e0 7f             	and    $0x7f,%eax
80102eeb:	eb 03                	jmp    80102ef0 <kbdgetc+0x81>
80102eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ef3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef6:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102efb:	0f b6 00             	movzbl (%eax),%eax
80102efe:	83 c8 40             	or     $0x40,%eax
80102f01:	0f b6 c0             	movzbl %al,%eax
80102f04:	f7 d0                	not    %eax
80102f06:	89 c2                	mov    %eax,%edx
80102f08:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f0d:	21 d0                	and    %edx,%eax
80102f0f:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f14:	b8 00 00 00 00       	mov    $0x0,%eax
80102f19:	e9 a2 00 00 00       	jmp    80102fc0 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f1e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f23:	83 e0 40             	and    $0x40,%eax
80102f26:	85 c0                	test   %eax,%eax
80102f28:	74 14                	je     80102f3e <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f2a:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f31:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f36:	83 e0 bf             	and    $0xffffffbf,%eax
80102f39:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102f3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f41:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f46:	0f b6 00             	movzbl (%eax),%eax
80102f49:	0f b6 d0             	movzbl %al,%edx
80102f4c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f51:	09 d0                	or     %edx,%eax
80102f53:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102f58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5b:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f60:	0f b6 00             	movzbl (%eax),%eax
80102f63:	0f b6 d0             	movzbl %al,%edx
80102f66:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f6b:	31 d0                	xor    %edx,%eax
80102f6d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f72:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f77:	83 e0 03             	and    $0x3,%eax
80102f7a:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f84:	01 d0                	add    %edx,%eax
80102f86:	0f b6 00             	movzbl (%eax),%eax
80102f89:	0f b6 c0             	movzbl %al,%eax
80102f8c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f8f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f94:	83 e0 08             	and    $0x8,%eax
80102f97:	85 c0                	test   %eax,%eax
80102f99:	74 22                	je     80102fbd <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f9b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f9f:	76 0c                	jbe    80102fad <kbdgetc+0x13e>
80102fa1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fa5:	77 06                	ja     80102fad <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fa7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fab:	eb 10                	jmp    80102fbd <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fad:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fb1:	76 0a                	jbe    80102fbd <kbdgetc+0x14e>
80102fb3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fb7:	77 04                	ja     80102fbd <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fb9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fc0:	c9                   	leave  
80102fc1:	c3                   	ret    

80102fc2 <kbdintr>:

void
kbdintr(void)
{
80102fc2:	f3 0f 1e fb          	endbr32 
80102fc6:	55                   	push   %ebp
80102fc7:	89 e5                	mov    %esp,%ebp
80102fc9:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102fcc:	83 ec 0c             	sub    $0xc,%esp
80102fcf:	68 6f 2e 10 80       	push   $0x80102e6f
80102fd4:	e8 cf d8 ff ff       	call   801008a8 <consoleintr>
80102fd9:	83 c4 10             	add    $0x10,%esp
}
80102fdc:	90                   	nop
80102fdd:	c9                   	leave  
80102fde:	c3                   	ret    

80102fdf <inb>:
{
80102fdf:	55                   	push   %ebp
80102fe0:	89 e5                	mov    %esp,%ebp
80102fe2:	83 ec 14             	sub    $0x14,%esp
80102fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80102fe8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ff0:	89 c2                	mov    %eax,%edx
80102ff2:	ec                   	in     (%dx),%al
80102ff3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ff6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ffa:	c9                   	leave  
80102ffb:	c3                   	ret    

80102ffc <outb>:
{
80102ffc:	55                   	push   %ebp
80102ffd:	89 e5                	mov    %esp,%ebp
80102fff:	83 ec 08             	sub    $0x8,%esp
80103002:	8b 45 08             	mov    0x8(%ebp),%eax
80103005:	8b 55 0c             	mov    0xc(%ebp),%edx
80103008:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010300c:	89 d0                	mov    %edx,%eax
8010300e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103011:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103015:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103019:	ee                   	out    %al,(%dx)
}
8010301a:	90                   	nop
8010301b:	c9                   	leave  
8010301c:	c3                   	ret    

8010301d <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010301d:	f3 0f 1e fb          	endbr32 
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103024:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103029:	8b 55 08             	mov    0x8(%ebp),%edx
8010302c:	c1 e2 02             	shl    $0x2,%edx
8010302f:	01 c2                	add    %eax,%edx
80103031:	8b 45 0c             	mov    0xc(%ebp),%eax
80103034:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103036:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010303b:	83 c0 20             	add    $0x20,%eax
8010303e:	8b 00                	mov    (%eax),%eax
}
80103040:	90                   	nop
80103041:	5d                   	pop    %ebp
80103042:	c3                   	ret    

80103043 <lapicinit>:

void
lapicinit(void)
{
80103043:	f3 0f 1e fb          	endbr32 
80103047:	55                   	push   %ebp
80103048:	89 e5                	mov    %esp,%ebp
  if(!lapic)
8010304a:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010304f:	85 c0                	test   %eax,%eax
80103051:	0f 84 0c 01 00 00    	je     80103163 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103057:	68 3f 01 00 00       	push   $0x13f
8010305c:	6a 3c                	push   $0x3c
8010305e:	e8 ba ff ff ff       	call   8010301d <lapicw>
80103063:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103066:	6a 0b                	push   $0xb
80103068:	68 f8 00 00 00       	push   $0xf8
8010306d:	e8 ab ff ff ff       	call   8010301d <lapicw>
80103072:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103075:	68 20 00 02 00       	push   $0x20020
8010307a:	68 c8 00 00 00       	push   $0xc8
8010307f:	e8 99 ff ff ff       	call   8010301d <lapicw>
80103084:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103087:	68 80 96 98 00       	push   $0x989680
8010308c:	68 e0 00 00 00       	push   $0xe0
80103091:	e8 87 ff ff ff       	call   8010301d <lapicw>
80103096:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103099:	68 00 00 01 00       	push   $0x10000
8010309e:	68 d4 00 00 00       	push   $0xd4
801030a3:	e8 75 ff ff ff       	call   8010301d <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801030ab:	68 00 00 01 00       	push   $0x10000
801030b0:	68 d8 00 00 00       	push   $0xd8
801030b5:	e8 63 ff ff ff       	call   8010301d <lapicw>
801030ba:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030bd:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030c2:	83 c0 30             	add    $0x30,%eax
801030c5:	8b 00                	mov    (%eax),%eax
801030c7:	c1 e8 10             	shr    $0x10,%eax
801030ca:	25 fc 00 00 00       	and    $0xfc,%eax
801030cf:	85 c0                	test   %eax,%eax
801030d1:	74 12                	je     801030e5 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801030d3:	68 00 00 01 00       	push   $0x10000
801030d8:	68 d0 00 00 00       	push   $0xd0
801030dd:	e8 3b ff ff ff       	call   8010301d <lapicw>
801030e2:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030e5:	6a 33                	push   $0x33
801030e7:	68 dc 00 00 00       	push   $0xdc
801030ec:	e8 2c ff ff ff       	call   8010301d <lapicw>
801030f1:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030f4:	6a 00                	push   $0x0
801030f6:	68 a0 00 00 00       	push   $0xa0
801030fb:	e8 1d ff ff ff       	call   8010301d <lapicw>
80103100:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103103:	6a 00                	push   $0x0
80103105:	68 a0 00 00 00       	push   $0xa0
8010310a:	e8 0e ff ff ff       	call   8010301d <lapicw>
8010310f:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103112:	6a 00                	push   $0x0
80103114:	6a 2c                	push   $0x2c
80103116:	e8 02 ff ff ff       	call   8010301d <lapicw>
8010311b:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010311e:	6a 00                	push   $0x0
80103120:	68 c4 00 00 00       	push   $0xc4
80103125:	e8 f3 fe ff ff       	call   8010301d <lapicw>
8010312a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010312d:	68 00 85 08 00       	push   $0x88500
80103132:	68 c0 00 00 00       	push   $0xc0
80103137:	e8 e1 fe ff ff       	call   8010301d <lapicw>
8010313c:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010313f:	90                   	nop
80103140:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103145:	05 00 03 00 00       	add    $0x300,%eax
8010314a:	8b 00                	mov    (%eax),%eax
8010314c:	25 00 10 00 00       	and    $0x1000,%eax
80103151:	85 c0                	test   %eax,%eax
80103153:	75 eb                	jne    80103140 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103155:	6a 00                	push   $0x0
80103157:	6a 20                	push   $0x20
80103159:	e8 bf fe ff ff       	call   8010301d <lapicw>
8010315e:	83 c4 08             	add    $0x8,%esp
80103161:	eb 01                	jmp    80103164 <lapicinit+0x121>
    return;
80103163:	90                   	nop
}
80103164:	c9                   	leave  
80103165:	c3                   	ret    

80103166 <lapicid>:

int
lapicid(void)
{
80103166:	f3 0f 1e fb          	endbr32 
8010316a:	55                   	push   %ebp
8010316b:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010316d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103172:	85 c0                	test   %eax,%eax
80103174:	75 07                	jne    8010317d <lapicid+0x17>
    return 0;
80103176:	b8 00 00 00 00       	mov    $0x0,%eax
8010317b:	eb 0d                	jmp    8010318a <lapicid+0x24>
  return lapic[ID] >> 24;
8010317d:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103182:	83 c0 20             	add    $0x20,%eax
80103185:	8b 00                	mov    (%eax),%eax
80103187:	c1 e8 18             	shr    $0x18,%eax
}
8010318a:	5d                   	pop    %ebp
8010318b:	c3                   	ret    

8010318c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010318c:	f3 0f 1e fb          	endbr32 
80103190:	55                   	push   %ebp
80103191:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103193:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	74 0c                	je     801031a8 <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010319c:	6a 00                	push   $0x0
8010319e:	6a 2c                	push   $0x2c
801031a0:	e8 78 fe ff ff       	call   8010301d <lapicw>
801031a5:	83 c4 08             	add    $0x8,%esp
}
801031a8:	90                   	nop
801031a9:	c9                   	leave  
801031aa:	c3                   	ret    

801031ab <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031ab:	f3 0f 1e fb          	endbr32 
801031af:	55                   	push   %ebp
801031b0:	89 e5                	mov    %esp,%ebp
}
801031b2:	90                   	nop
801031b3:	5d                   	pop    %ebp
801031b4:	c3                   	ret    

801031b5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031b5:	f3 0f 1e fb          	endbr32 
801031b9:	55                   	push   %ebp
801031ba:	89 e5                	mov    %esp,%ebp
801031bc:	83 ec 14             	sub    $0x14,%esp
801031bf:	8b 45 08             	mov    0x8(%ebp),%eax
801031c2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031c5:	6a 0f                	push   $0xf
801031c7:	6a 70                	push   $0x70
801031c9:	e8 2e fe ff ff       	call   80102ffc <outb>
801031ce:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801031d1:	6a 0a                	push   $0xa
801031d3:	6a 71                	push   $0x71
801031d5:	e8 22 fe ff ff       	call   80102ffc <outb>
801031da:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031dd:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031e7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ef:	c1 e8 04             	shr    $0x4,%eax
801031f2:	89 c2                	mov    %eax,%edx
801031f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031f7:	83 c0 02             	add    $0x2,%eax
801031fa:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031fd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103201:	c1 e0 18             	shl    $0x18,%eax
80103204:	50                   	push   %eax
80103205:	68 c4 00 00 00       	push   $0xc4
8010320a:	e8 0e fe ff ff       	call   8010301d <lapicw>
8010320f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103212:	68 00 c5 00 00       	push   $0xc500
80103217:	68 c0 00 00 00       	push   $0xc0
8010321c:	e8 fc fd ff ff       	call   8010301d <lapicw>
80103221:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103224:	68 c8 00 00 00       	push   $0xc8
80103229:	e8 7d ff ff ff       	call   801031ab <microdelay>
8010322e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103231:	68 00 85 00 00       	push   $0x8500
80103236:	68 c0 00 00 00       	push   $0xc0
8010323b:	e8 dd fd ff ff       	call   8010301d <lapicw>
80103240:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103243:	6a 64                	push   $0x64
80103245:	e8 61 ff ff ff       	call   801031ab <microdelay>
8010324a:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010324d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103254:	eb 3d                	jmp    80103293 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80103256:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010325a:	c1 e0 18             	shl    $0x18,%eax
8010325d:	50                   	push   %eax
8010325e:	68 c4 00 00 00       	push   $0xc4
80103263:	e8 b5 fd ff ff       	call   8010301d <lapicw>
80103268:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010326b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010326e:	c1 e8 0c             	shr    $0xc,%eax
80103271:	80 cc 06             	or     $0x6,%ah
80103274:	50                   	push   %eax
80103275:	68 c0 00 00 00       	push   $0xc0
8010327a:	e8 9e fd ff ff       	call   8010301d <lapicw>
8010327f:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103282:	68 c8 00 00 00       	push   $0xc8
80103287:	e8 1f ff ff ff       	call   801031ab <microdelay>
8010328c:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010328f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103293:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103297:	7e bd                	jle    80103256 <lapicstartap+0xa1>
  }
}
80103299:	90                   	nop
8010329a:	90                   	nop
8010329b:	c9                   	leave  
8010329c:	c3                   	ret    

8010329d <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010329d:	f3 0f 1e fb          	endbr32 
801032a1:	55                   	push   %ebp
801032a2:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	0f b6 c0             	movzbl %al,%eax
801032aa:	50                   	push   %eax
801032ab:	6a 70                	push   $0x70
801032ad:	e8 4a fd ff ff       	call   80102ffc <outb>
801032b2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032b5:	68 c8 00 00 00       	push   $0xc8
801032ba:	e8 ec fe ff ff       	call   801031ab <microdelay>
801032bf:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801032c2:	6a 71                	push   $0x71
801032c4:	e8 16 fd ff ff       	call   80102fdf <inb>
801032c9:	83 c4 04             	add    $0x4,%esp
801032cc:	0f b6 c0             	movzbl %al,%eax
}
801032cf:	c9                   	leave  
801032d0:	c3                   	ret    

801032d1 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801032d1:	f3 0f 1e fb          	endbr32 
801032d5:	55                   	push   %ebp
801032d6:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801032d8:	6a 00                	push   $0x0
801032da:	e8 be ff ff ff       	call   8010329d <cmos_read>
801032df:	83 c4 04             	add    $0x4,%esp
801032e2:	8b 55 08             	mov    0x8(%ebp),%edx
801032e5:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032e7:	6a 02                	push   $0x2
801032e9:	e8 af ff ff ff       	call   8010329d <cmos_read>
801032ee:	83 c4 04             	add    $0x4,%esp
801032f1:	8b 55 08             	mov    0x8(%ebp),%edx
801032f4:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801032f7:	6a 04                	push   $0x4
801032f9:	e8 9f ff ff ff       	call   8010329d <cmos_read>
801032fe:	83 c4 04             	add    $0x4,%esp
80103301:	8b 55 08             	mov    0x8(%ebp),%edx
80103304:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103307:	6a 07                	push   $0x7
80103309:	e8 8f ff ff ff       	call   8010329d <cmos_read>
8010330e:	83 c4 04             	add    $0x4,%esp
80103311:	8b 55 08             	mov    0x8(%ebp),%edx
80103314:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103317:	6a 08                	push   $0x8
80103319:	e8 7f ff ff ff       	call   8010329d <cmos_read>
8010331e:	83 c4 04             	add    $0x4,%esp
80103321:	8b 55 08             	mov    0x8(%ebp),%edx
80103324:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103327:	6a 09                	push   $0x9
80103329:	e8 6f ff ff ff       	call   8010329d <cmos_read>
8010332e:	83 c4 04             	add    $0x4,%esp
80103331:	8b 55 08             	mov    0x8(%ebp),%edx
80103334:	89 42 14             	mov    %eax,0x14(%edx)
}
80103337:	90                   	nop
80103338:	c9                   	leave  
80103339:	c3                   	ret    

8010333a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010333a:	f3 0f 1e fb          	endbr32 
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
80103341:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103344:	6a 0b                	push   $0xb
80103346:	e8 52 ff ff ff       	call   8010329d <cmos_read>
8010334b:	83 c4 04             	add    $0x4,%esp
8010334e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103354:	83 e0 04             	and    $0x4,%eax
80103357:	85 c0                	test   %eax,%eax
80103359:	0f 94 c0             	sete   %al
8010335c:	0f b6 c0             	movzbl %al,%eax
8010335f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103362:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103365:	50                   	push   %eax
80103366:	e8 66 ff ff ff       	call   801032d1 <fill_rtcdate>
8010336b:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010336e:	6a 0a                	push   $0xa
80103370:	e8 28 ff ff ff       	call   8010329d <cmos_read>
80103375:	83 c4 04             	add    $0x4,%esp
80103378:	25 80 00 00 00       	and    $0x80,%eax
8010337d:	85 c0                	test   %eax,%eax
8010337f:	75 27                	jne    801033a8 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103381:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103384:	50                   	push   %eax
80103385:	e8 47 ff ff ff       	call   801032d1 <fill_rtcdate>
8010338a:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010338d:	83 ec 04             	sub    $0x4,%esp
80103390:	6a 18                	push   $0x18
80103392:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103395:	50                   	push   %eax
80103396:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103399:	50                   	push   %eax
8010339a:	e8 9f 21 00 00       	call   8010553e <memcmp>
8010339f:	83 c4 10             	add    $0x10,%esp
801033a2:	85 c0                	test   %eax,%eax
801033a4:	74 05                	je     801033ab <cmostime+0x71>
801033a6:	eb ba                	jmp    80103362 <cmostime+0x28>
        continue;
801033a8:	90                   	nop
    fill_rtcdate(&t1);
801033a9:	eb b7                	jmp    80103362 <cmostime+0x28>
      break;
801033ab:	90                   	nop
  }

  // convert
  if(bcd) {
801033ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801033b0:	0f 84 b4 00 00 00    	je     8010346a <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033b9:	c1 e8 04             	shr    $0x4,%eax
801033bc:	89 c2                	mov    %eax,%edx
801033be:	89 d0                	mov    %edx,%eax
801033c0:	c1 e0 02             	shl    $0x2,%eax
801033c3:	01 d0                	add    %edx,%eax
801033c5:	01 c0                	add    %eax,%eax
801033c7:	89 c2                	mov    %eax,%edx
801033c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033cc:	83 e0 0f             	and    $0xf,%eax
801033cf:	01 d0                	add    %edx,%eax
801033d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801033d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033d7:	c1 e8 04             	shr    $0x4,%eax
801033da:	89 c2                	mov    %eax,%edx
801033dc:	89 d0                	mov    %edx,%eax
801033de:	c1 e0 02             	shl    $0x2,%eax
801033e1:	01 d0                	add    %edx,%eax
801033e3:	01 c0                	add    %eax,%eax
801033e5:	89 c2                	mov    %eax,%edx
801033e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033ea:	83 e0 0f             	and    $0xf,%eax
801033ed:	01 d0                	add    %edx,%eax
801033ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801033f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801033f5:	c1 e8 04             	shr    $0x4,%eax
801033f8:	89 c2                	mov    %eax,%edx
801033fa:	89 d0                	mov    %edx,%eax
801033fc:	c1 e0 02             	shl    $0x2,%eax
801033ff:	01 d0                	add    %edx,%eax
80103401:	01 c0                	add    %eax,%eax
80103403:	89 c2                	mov    %eax,%edx
80103405:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103408:	83 e0 0f             	and    $0xf,%eax
8010340b:	01 d0                	add    %edx,%eax
8010340d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103413:	c1 e8 04             	shr    $0x4,%eax
80103416:	89 c2                	mov    %eax,%edx
80103418:	89 d0                	mov    %edx,%eax
8010341a:	c1 e0 02             	shl    $0x2,%eax
8010341d:	01 d0                	add    %edx,%eax
8010341f:	01 c0                	add    %eax,%eax
80103421:	89 c2                	mov    %eax,%edx
80103423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103426:	83 e0 0f             	and    $0xf,%eax
80103429:	01 d0                	add    %edx,%eax
8010342b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010342e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103431:	c1 e8 04             	shr    $0x4,%eax
80103434:	89 c2                	mov    %eax,%edx
80103436:	89 d0                	mov    %edx,%eax
80103438:	c1 e0 02             	shl    $0x2,%eax
8010343b:	01 d0                	add    %edx,%eax
8010343d:	01 c0                	add    %eax,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103444:	83 e0 0f             	and    $0xf,%eax
80103447:	01 d0                	add    %edx,%eax
80103449:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010344c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344f:	c1 e8 04             	shr    $0x4,%eax
80103452:	89 c2                	mov    %eax,%edx
80103454:	89 d0                	mov    %edx,%eax
80103456:	c1 e0 02             	shl    $0x2,%eax
80103459:	01 d0                	add    %edx,%eax
8010345b:	01 c0                	add    %eax,%eax
8010345d:	89 c2                	mov    %eax,%edx
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	83 e0 0f             	and    $0xf,%eax
80103465:	01 d0                	add    %edx,%eax
80103467:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010346a:	8b 45 08             	mov    0x8(%ebp),%eax
8010346d:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103470:	89 10                	mov    %edx,(%eax)
80103472:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103475:	89 50 04             	mov    %edx,0x4(%eax)
80103478:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010347b:	89 50 08             	mov    %edx,0x8(%eax)
8010347e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103481:	89 50 0c             	mov    %edx,0xc(%eax)
80103484:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103487:	89 50 10             	mov    %edx,0x10(%eax)
8010348a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010348d:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103490:	8b 45 08             	mov    0x8(%ebp),%eax
80103493:	8b 40 14             	mov    0x14(%eax),%eax
80103496:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010349c:	8b 45 08             	mov    0x8(%ebp),%eax
8010349f:	89 50 14             	mov    %edx,0x14(%eax)
}
801034a2:	90                   	nop
801034a3:	c9                   	leave  
801034a4:	c3                   	ret    

801034a5 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801034a5:	f3 0f 1e fb          	endbr32 
801034a9:	55                   	push   %ebp
801034aa:	89 e5                	mov    %esp,%ebp
801034ac:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034af:	83 ec 08             	sub    $0x8,%esp
801034b2:	68 41 8f 10 80       	push   $0x80108f41
801034b7:	68 20 47 11 80       	push   $0x80114720
801034bc:	e8 4d 1d 00 00       	call   8010520e <initlock>
801034c1:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801034c4:	83 ec 08             	sub    $0x8,%esp
801034c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034ca:	50                   	push   %eax
801034cb:	ff 75 08             	pushl  0x8(%ebp)
801034ce:	e8 f9 df ff ff       	call   801014cc <readsb>
801034d3:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801034d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d9:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
801034de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034e1:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
801034e6:	8b 45 08             	mov    0x8(%ebp),%eax
801034e9:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
801034ee:	e8 bf 01 00 00       	call   801036b2 <recover_from_log>
}
801034f3:	90                   	nop
801034f4:	c9                   	leave  
801034f5:	c3                   	ret    

801034f6 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034f6:	f3 0f 1e fb          	endbr32 
801034fa:	55                   	push   %ebp
801034fb:	89 e5                	mov    %esp,%ebp
801034fd:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103507:	e9 95 00 00 00       	jmp    801035a1 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010350c:	8b 15 54 47 11 80    	mov    0x80114754,%edx
80103512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103515:	01 d0                	add    %edx,%eax
80103517:	83 c0 01             	add    $0x1,%eax
8010351a:	89 c2                	mov    %eax,%edx
8010351c:	a1 64 47 11 80       	mov    0x80114764,%eax
80103521:	83 ec 08             	sub    $0x8,%esp
80103524:	52                   	push   %edx
80103525:	50                   	push   %eax
80103526:	e8 ac cc ff ff       	call   801001d7 <bread>
8010352b:	83 c4 10             	add    $0x10,%esp
8010352e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103534:	83 c0 10             	add    $0x10,%eax
80103537:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
8010353e:	89 c2                	mov    %eax,%edx
80103540:	a1 64 47 11 80       	mov    0x80114764,%eax
80103545:	83 ec 08             	sub    $0x8,%esp
80103548:	52                   	push   %edx
80103549:	50                   	push   %eax
8010354a:	e8 88 cc ff ff       	call   801001d7 <bread>
8010354f:	83 c4 10             	add    $0x10,%esp
80103552:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103558:	8d 50 5c             	lea    0x5c(%eax),%edx
8010355b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010355e:	83 c0 5c             	add    $0x5c,%eax
80103561:	83 ec 04             	sub    $0x4,%esp
80103564:	68 00 02 00 00       	push   $0x200
80103569:	52                   	push   %edx
8010356a:	50                   	push   %eax
8010356b:	e8 2a 20 00 00       	call   8010559a <memmove>
80103570:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103573:	83 ec 0c             	sub    $0xc,%esp
80103576:	ff 75 ec             	pushl  -0x14(%ebp)
80103579:	e8 96 cc ff ff       	call   80100214 <bwrite>
8010357e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103581:	83 ec 0c             	sub    $0xc,%esp
80103584:	ff 75 f0             	pushl  -0x10(%ebp)
80103587:	e8 d5 cc ff ff       	call   80100261 <brelse>
8010358c:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010358f:	83 ec 0c             	sub    $0xc,%esp
80103592:	ff 75 ec             	pushl  -0x14(%ebp)
80103595:	e8 c7 cc ff ff       	call   80100261 <brelse>
8010359a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010359d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a1:	a1 68 47 11 80       	mov    0x80114768,%eax
801035a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035a9:	0f 8c 5d ff ff ff    	jl     8010350c <install_trans+0x16>
  }
}
801035af:	90                   	nop
801035b0:	90                   	nop
801035b1:	c9                   	leave  
801035b2:	c3                   	ret    

801035b3 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035b3:	f3 0f 1e fb          	endbr32 
801035b7:	55                   	push   %ebp
801035b8:	89 e5                	mov    %esp,%ebp
801035ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035bd:	a1 54 47 11 80       	mov    0x80114754,%eax
801035c2:	89 c2                	mov    %eax,%edx
801035c4:	a1 64 47 11 80       	mov    0x80114764,%eax
801035c9:	83 ec 08             	sub    $0x8,%esp
801035cc:	52                   	push   %edx
801035cd:	50                   	push   %eax
801035ce:	e8 04 cc ff ff       	call   801001d7 <bread>
801035d3:	83 c4 10             	add    $0x10,%esp
801035d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035dc:	83 c0 5c             	add    $0x5c,%eax
801035df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e5:	8b 00                	mov    (%eax),%eax
801035e7:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
801035ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f3:	eb 1b                	jmp    80103610 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801035f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035fb:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801035ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103602:	83 c2 10             	add    $0x10,%edx
80103605:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010360c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103610:	a1 68 47 11 80       	mov    0x80114768,%eax
80103615:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103618:	7c db                	jl     801035f5 <read_head+0x42>
  }
  brelse(buf);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	ff 75 f0             	pushl  -0x10(%ebp)
80103620:	e8 3c cc ff ff       	call   80100261 <brelse>
80103625:	83 c4 10             	add    $0x10,%esp
}
80103628:	90                   	nop
80103629:	c9                   	leave  
8010362a:	c3                   	ret    

8010362b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010362b:	f3 0f 1e fb          	endbr32 
8010362f:	55                   	push   %ebp
80103630:	89 e5                	mov    %esp,%ebp
80103632:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103635:	a1 54 47 11 80       	mov    0x80114754,%eax
8010363a:	89 c2                	mov    %eax,%edx
8010363c:	a1 64 47 11 80       	mov    0x80114764,%eax
80103641:	83 ec 08             	sub    $0x8,%esp
80103644:	52                   	push   %edx
80103645:	50                   	push   %eax
80103646:	e8 8c cb ff ff       	call   801001d7 <bread>
8010364b:	83 c4 10             	add    $0x10,%esp
8010364e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103654:	83 c0 5c             	add    $0x5c,%eax
80103657:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010365a:	8b 15 68 47 11 80    	mov    0x80114768,%edx
80103660:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103663:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010366c:	eb 1b                	jmp    80103689 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
8010366e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103671:	83 c0 10             	add    $0x10,%eax
80103674:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
8010367b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010367e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103681:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103685:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103689:	a1 68 47 11 80       	mov    0x80114768,%eax
8010368e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103691:	7c db                	jl     8010366e <write_head+0x43>
  }
  bwrite(buf);
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	ff 75 f0             	pushl  -0x10(%ebp)
80103699:	e8 76 cb ff ff       	call   80100214 <bwrite>
8010369e:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801036a1:	83 ec 0c             	sub    $0xc,%esp
801036a4:	ff 75 f0             	pushl  -0x10(%ebp)
801036a7:	e8 b5 cb ff ff       	call   80100261 <brelse>
801036ac:	83 c4 10             	add    $0x10,%esp
}
801036af:	90                   	nop
801036b0:	c9                   	leave  
801036b1:	c3                   	ret    

801036b2 <recover_from_log>:

static void
recover_from_log(void)
{
801036b2:	f3 0f 1e fb          	endbr32 
801036b6:	55                   	push   %ebp
801036b7:	89 e5                	mov    %esp,%ebp
801036b9:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036bc:	e8 f2 fe ff ff       	call   801035b3 <read_head>
  install_trans(); // if committed, copy from log to disk
801036c1:	e8 30 fe ff ff       	call   801034f6 <install_trans>
  log.lh.n = 0;
801036c6:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
801036cd:	00 00 00 
  write_head(); // clear the log
801036d0:	e8 56 ff ff ff       	call   8010362b <write_head>
}
801036d5:	90                   	nop
801036d6:	c9                   	leave  
801036d7:	c3                   	ret    

801036d8 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801036d8:	f3 0f 1e fb          	endbr32 
801036dc:	55                   	push   %ebp
801036dd:	89 e5                	mov    %esp,%ebp
801036df:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801036e2:	83 ec 0c             	sub    $0xc,%esp
801036e5:	68 20 47 11 80       	push   $0x80114720
801036ea:	e8 45 1b 00 00       	call   80105234 <acquire>
801036ef:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801036f2:	a1 60 47 11 80       	mov    0x80114760,%eax
801036f7:	85 c0                	test   %eax,%eax
801036f9:	74 17                	je     80103712 <begin_op+0x3a>
      sleep(&log, &log.lock);
801036fb:	83 ec 08             	sub    $0x8,%esp
801036fe:	68 20 47 11 80       	push   $0x80114720
80103703:	68 20 47 11 80       	push   $0x80114720
80103708:	e8 be 16 00 00       	call   80104dcb <sleep>
8010370d:	83 c4 10             	add    $0x10,%esp
80103710:	eb e0                	jmp    801036f2 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103712:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103718:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010371d:	8d 50 01             	lea    0x1(%eax),%edx
80103720:	89 d0                	mov    %edx,%eax
80103722:	c1 e0 02             	shl    $0x2,%eax
80103725:	01 d0                	add    %edx,%eax
80103727:	01 c0                	add    %eax,%eax
80103729:	01 c8                	add    %ecx,%eax
8010372b:	83 f8 1e             	cmp    $0x1e,%eax
8010372e:	7e 17                	jle    80103747 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103730:	83 ec 08             	sub    $0x8,%esp
80103733:	68 20 47 11 80       	push   $0x80114720
80103738:	68 20 47 11 80       	push   $0x80114720
8010373d:	e8 89 16 00 00       	call   80104dcb <sleep>
80103742:	83 c4 10             	add    $0x10,%esp
80103745:	eb ab                	jmp    801036f2 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103747:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010374c:	83 c0 01             	add    $0x1,%eax
8010374f:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
80103754:	83 ec 0c             	sub    $0xc,%esp
80103757:	68 20 47 11 80       	push   $0x80114720
8010375c:	e8 45 1b 00 00       	call   801052a6 <release>
80103761:	83 c4 10             	add    $0x10,%esp
      break;
80103764:	90                   	nop
    }
  }
}
80103765:	90                   	nop
80103766:	c9                   	leave  
80103767:	c3                   	ret    

80103768 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103768:	f3 0f 1e fb          	endbr32 
8010376c:	55                   	push   %ebp
8010376d:	89 e5                	mov    %esp,%ebp
8010376f:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103779:	83 ec 0c             	sub    $0xc,%esp
8010377c:	68 20 47 11 80       	push   $0x80114720
80103781:	e8 ae 1a 00 00       	call   80105234 <acquire>
80103786:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103789:	a1 5c 47 11 80       	mov    0x8011475c,%eax
8010378e:	83 e8 01             	sub    $0x1,%eax
80103791:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
80103796:	a1 60 47 11 80       	mov    0x80114760,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	74 0d                	je     801037ac <end_op+0x44>
    panic("log.committing");
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	68 45 8f 10 80       	push   $0x80108f45
801037a7:	e8 5c ce ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
801037ac:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037b1:	85 c0                	test   %eax,%eax
801037b3:	75 13                	jne    801037c8 <end_op+0x60>
    do_commit = 1;
801037b5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037bc:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
801037c3:	00 00 00 
801037c6:	eb 10                	jmp    801037d8 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037c8:	83 ec 0c             	sub    $0xc,%esp
801037cb:	68 20 47 11 80       	push   $0x80114720
801037d0:	e8 e5 16 00 00       	call   80104eba <wakeup>
801037d5:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801037d8:	83 ec 0c             	sub    $0xc,%esp
801037db:	68 20 47 11 80       	push   $0x80114720
801037e0:	e8 c1 1a 00 00       	call   801052a6 <release>
801037e5:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801037e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037ec:	74 3f                	je     8010382d <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801037ee:	e8 fa 00 00 00       	call   801038ed <commit>
    acquire(&log.lock);
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	68 20 47 11 80       	push   $0x80114720
801037fb:	e8 34 1a 00 00       	call   80105234 <acquire>
80103800:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103803:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
8010380a:	00 00 00 
    wakeup(&log);
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	68 20 47 11 80       	push   $0x80114720
80103815:	e8 a0 16 00 00       	call   80104eba <wakeup>
8010381a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010381d:	83 ec 0c             	sub    $0xc,%esp
80103820:	68 20 47 11 80       	push   $0x80114720
80103825:	e8 7c 1a 00 00       	call   801052a6 <release>
8010382a:	83 c4 10             	add    $0x10,%esp
  }
}
8010382d:	90                   	nop
8010382e:	c9                   	leave  
8010382f:	c3                   	ret    

80103830 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103830:	f3 0f 1e fb          	endbr32 
80103834:	55                   	push   %ebp
80103835:	89 e5                	mov    %esp,%ebp
80103837:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010383a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103841:	e9 95 00 00 00       	jmp    801038db <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103846:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010384c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384f:	01 d0                	add    %edx,%eax
80103851:	83 c0 01             	add    $0x1,%eax
80103854:	89 c2                	mov    %eax,%edx
80103856:	a1 64 47 11 80       	mov    0x80114764,%eax
8010385b:	83 ec 08             	sub    $0x8,%esp
8010385e:	52                   	push   %edx
8010385f:	50                   	push   %eax
80103860:	e8 72 c9 ff ff       	call   801001d7 <bread>
80103865:	83 c4 10             	add    $0x10,%esp
80103868:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010386b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010386e:	83 c0 10             	add    $0x10,%eax
80103871:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103878:	89 c2                	mov    %eax,%edx
8010387a:	a1 64 47 11 80       	mov    0x80114764,%eax
8010387f:	83 ec 08             	sub    $0x8,%esp
80103882:	52                   	push   %edx
80103883:	50                   	push   %eax
80103884:	e8 4e c9 ff ff       	call   801001d7 <bread>
80103889:	83 c4 10             	add    $0x10,%esp
8010388c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010388f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103892:	8d 50 5c             	lea    0x5c(%eax),%edx
80103895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103898:	83 c0 5c             	add    $0x5c,%eax
8010389b:	83 ec 04             	sub    $0x4,%esp
8010389e:	68 00 02 00 00       	push   $0x200
801038a3:	52                   	push   %edx
801038a4:	50                   	push   %eax
801038a5:	e8 f0 1c 00 00       	call   8010559a <memmove>
801038aa:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801038ad:	83 ec 0c             	sub    $0xc,%esp
801038b0:	ff 75 f0             	pushl  -0x10(%ebp)
801038b3:	e8 5c c9 ff ff       	call   80100214 <bwrite>
801038b8:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801038bb:	83 ec 0c             	sub    $0xc,%esp
801038be:	ff 75 ec             	pushl  -0x14(%ebp)
801038c1:	e8 9b c9 ff ff       	call   80100261 <brelse>
801038c6:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801038c9:	83 ec 0c             	sub    $0xc,%esp
801038cc:	ff 75 f0             	pushl  -0x10(%ebp)
801038cf:	e8 8d c9 ff ff       	call   80100261 <brelse>
801038d4:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801038d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038db:	a1 68 47 11 80       	mov    0x80114768,%eax
801038e0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038e3:	0f 8c 5d ff ff ff    	jl     80103846 <write_log+0x16>
  }
}
801038e9:	90                   	nop
801038ea:	90                   	nop
801038eb:	c9                   	leave  
801038ec:	c3                   	ret    

801038ed <commit>:

static void
commit()
{
801038ed:	f3 0f 1e fb          	endbr32 
801038f1:	55                   	push   %ebp
801038f2:	89 e5                	mov    %esp,%ebp
801038f4:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801038f7:	a1 68 47 11 80       	mov    0x80114768,%eax
801038fc:	85 c0                	test   %eax,%eax
801038fe:	7e 1e                	jle    8010391e <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103900:	e8 2b ff ff ff       	call   80103830 <write_log>
    write_head();    // Write header to disk -- the real commit
80103905:	e8 21 fd ff ff       	call   8010362b <write_head>
    install_trans(); // Now install writes to home locations
8010390a:	e8 e7 fb ff ff       	call   801034f6 <install_trans>
    log.lh.n = 0;
8010390f:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103916:	00 00 00 
    write_head();    // Erase the transaction from the log
80103919:	e8 0d fd ff ff       	call   8010362b <write_head>
  }
}
8010391e:	90                   	nop
8010391f:	c9                   	leave  
80103920:	c3                   	ret    

80103921 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103921:	f3 0f 1e fb          	endbr32 
80103925:	55                   	push   %ebp
80103926:	89 e5                	mov    %esp,%ebp
80103928:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010392b:	a1 68 47 11 80       	mov    0x80114768,%eax
80103930:	83 f8 1d             	cmp    $0x1d,%eax
80103933:	7f 12                	jg     80103947 <log_write+0x26>
80103935:	a1 68 47 11 80       	mov    0x80114768,%eax
8010393a:	8b 15 58 47 11 80    	mov    0x80114758,%edx
80103940:	83 ea 01             	sub    $0x1,%edx
80103943:	39 d0                	cmp    %edx,%eax
80103945:	7c 0d                	jl     80103954 <log_write+0x33>
    panic("too big a transaction");
80103947:	83 ec 0c             	sub    $0xc,%esp
8010394a:	68 54 8f 10 80       	push   $0x80108f54
8010394f:	e8 b4 cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
80103954:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103959:	85 c0                	test   %eax,%eax
8010395b:	7f 0d                	jg     8010396a <log_write+0x49>
    panic("log_write outside of trans");
8010395d:	83 ec 0c             	sub    $0xc,%esp
80103960:	68 6a 8f 10 80       	push   $0x80108f6a
80103965:	e8 9e cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
8010396a:	83 ec 0c             	sub    $0xc,%esp
8010396d:	68 20 47 11 80       	push   $0x80114720
80103972:	e8 bd 18 00 00       	call   80105234 <acquire>
80103977:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010397a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103981:	eb 1d                	jmp    801039a0 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103986:	83 c0 10             	add    $0x10,%eax
80103989:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103990:	89 c2                	mov    %eax,%edx
80103992:	8b 45 08             	mov    0x8(%ebp),%eax
80103995:	8b 40 08             	mov    0x8(%eax),%eax
80103998:	39 c2                	cmp    %eax,%edx
8010399a:	74 10                	je     801039ac <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010399c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a0:	a1 68 47 11 80       	mov    0x80114768,%eax
801039a5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039a8:	7c d9                	jl     80103983 <log_write+0x62>
801039aa:	eb 01                	jmp    801039ad <log_write+0x8c>
      break;
801039ac:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801039ad:	8b 45 08             	mov    0x8(%ebp),%eax
801039b0:	8b 40 08             	mov    0x8(%eax),%eax
801039b3:	89 c2                	mov    %eax,%edx
801039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b8:	83 c0 10             	add    $0x10,%eax
801039bb:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
801039c2:	a1 68 47 11 80       	mov    0x80114768,%eax
801039c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ca:	75 0d                	jne    801039d9 <log_write+0xb8>
    log.lh.n++;
801039cc:	a1 68 47 11 80       	mov    0x80114768,%eax
801039d1:	83 c0 01             	add    $0x1,%eax
801039d4:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
801039d9:	8b 45 08             	mov    0x8(%ebp),%eax
801039dc:	8b 00                	mov    (%eax),%eax
801039de:	83 c8 04             	or     $0x4,%eax
801039e1:	89 c2                	mov    %eax,%edx
801039e3:	8b 45 08             	mov    0x8(%ebp),%eax
801039e6:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801039e8:	83 ec 0c             	sub    $0xc,%esp
801039eb:	68 20 47 11 80       	push   $0x80114720
801039f0:	e8 b1 18 00 00       	call   801052a6 <release>
801039f5:	83 c4 10             	add    $0x10,%esp
}
801039f8:	90                   	nop
801039f9:	c9                   	leave  
801039fa:	c3                   	ret    

801039fb <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801039fb:	55                   	push   %ebp
801039fc:	89 e5                	mov    %esp,%ebp
801039fe:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a01:	8b 55 08             	mov    0x8(%ebp),%edx
80103a04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a0a:	f0 87 02             	lock xchg %eax,(%edx)
80103a0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a13:	c9                   	leave  
80103a14:	c3                   	ret    

80103a15 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a15:	f3 0f 1e fb          	endbr32 
80103a19:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a1d:	83 e4 f0             	and    $0xfffffff0,%esp
80103a20:	ff 71 fc             	pushl  -0x4(%ecx)
80103a23:	55                   	push   %ebp
80103a24:	89 e5                	mov    %esp,%ebp
80103a26:	51                   	push   %ecx
80103a27:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a2a:	83 ec 08             	sub    $0x8,%esp
80103a2d:	68 00 00 40 80       	push   $0x80400000
80103a32:	68 48 75 11 80       	push   $0x80117548
80103a37:	e8 78 f2 ff ff       	call   80102cb4 <kinit1>
80103a3c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103a3f:	e8 64 46 00 00       	call   801080a8 <kvmalloc>
  mpinit();        // detect other processors
80103a44:	e8 d9 03 00 00       	call   80103e22 <mpinit>
  lapicinit();     // interrupt controller
80103a49:	e8 f5 f5 ff ff       	call   80103043 <lapicinit>
  seginit();       // segment descriptors
80103a4e:	e8 08 41 00 00       	call   80107b5b <seginit>
  picinit();       // disable pic
80103a53:	e8 35 05 00 00       	call   80103f8d <picinit>
  ioapicinit();    // another interrupt controller
80103a58:	e8 6a f1 ff ff       	call   80102bc7 <ioapicinit>
  consoleinit();   // console hardware
80103a5d:	e8 7f d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103a62:	e8 7d 34 00 00       	call   80106ee4 <uartinit>
  pinit();         // process table
80103a67:	e8 6e 09 00 00       	call   801043da <pinit>
  tvinit();        // trap vectors
80103a6c:	e8 25 30 00 00       	call   80106a96 <tvinit>
  binit();         // buffer cache
80103a71:	e8 be c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a76:	e8 26 d6 ff ff       	call   801010a1 <fileinit>
  ideinit();       // disk 
80103a7b:	e8 06 ed ff ff       	call   80102786 <ideinit>
  startothers();   // start other processors
80103a80:	e8 88 00 00 00       	call   80103b0d <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a85:	83 ec 08             	sub    $0x8,%esp
80103a88:	68 00 00 00 8e       	push   $0x8e000000
80103a8d:	68 00 00 40 80       	push   $0x80400000
80103a92:	e8 5a f2 ff ff       	call   80102cf1 <kinit2>
80103a97:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103a9a:	e8 31 0b 00 00       	call   801045d0 <userinit>
  mpmain();        // finish this processor's setup
80103a9f:	e8 1e 00 00 00       	call   80103ac2 <mpmain>

80103aa4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103aa4:	f3 0f 1e fb          	endbr32 
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103aae:	e8 11 46 00 00       	call   801080c4 <switchkvm>
  seginit();
80103ab3:	e8 a3 40 00 00       	call   80107b5b <seginit>
  lapicinit();
80103ab8:	e8 86 f5 ff ff       	call   80103043 <lapicinit>
  mpmain();
80103abd:	e8 00 00 00 00       	call   80103ac2 <mpmain>

80103ac2 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103ac2:	f3 0f 1e fb          	endbr32 
80103ac6:	55                   	push   %ebp
80103ac7:	89 e5                	mov    %esp,%ebp
80103ac9:	53                   	push   %ebx
80103aca:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103acd:	e8 2a 09 00 00       	call   801043fc <cpuid>
80103ad2:	89 c3                	mov    %eax,%ebx
80103ad4:	e8 23 09 00 00       	call   801043fc <cpuid>
80103ad9:	83 ec 04             	sub    $0x4,%esp
80103adc:	53                   	push   %ebx
80103add:	50                   	push   %eax
80103ade:	68 85 8f 10 80       	push   $0x80108f85
80103ae3:	e8 30 c9 ff ff       	call   80100418 <cprintf>
80103ae8:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103aeb:	e8 20 31 00 00       	call   80106c10 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103af0:	e8 26 09 00 00       	call   8010441b <mycpu>
80103af5:	05 a0 00 00 00       	add    $0xa0,%eax
80103afa:	83 ec 08             	sub    $0x8,%esp
80103afd:	6a 01                	push   $0x1
80103aff:	50                   	push   %eax
80103b00:	e8 f6 fe ff ff       	call   801039fb <xchg>
80103b05:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b08:	e8 bd 10 00 00       	call   80104bca <scheduler>

80103b0d <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b0d:	f3 0f 1e fb          	endbr32 
80103b11:	55                   	push   %ebp
80103b12:	89 e5                	mov    %esp,%ebp
80103b14:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b17:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b1e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b23:	83 ec 04             	sub    $0x4,%esp
80103b26:	50                   	push   %eax
80103b27:	68 0c c5 10 80       	push   $0x8010c50c
80103b2c:	ff 75 f0             	pushl  -0x10(%ebp)
80103b2f:	e8 66 1a 00 00       	call   8010559a <memmove>
80103b34:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b37:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103b3e:	eb 79                	jmp    80103bb9 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103b40:	e8 d6 08 00 00       	call   8010441b <mycpu>
80103b45:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b48:	74 67                	je     80103bb1 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b4a:	e8 aa f2 ff ff       	call   80102df9 <kalloc>
80103b4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b55:	83 e8 04             	sub    $0x4,%eax
80103b58:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b5b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b61:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b66:	83 e8 08             	sub    $0x8,%eax
80103b69:	c7 00 a4 3a 10 80    	movl   $0x80103aa4,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b6f:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b74:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7d:	83 e8 0c             	sub    $0xc,%eax
80103b80:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b85:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	0f b6 00             	movzbl (%eax),%eax
80103b91:	0f b6 c0             	movzbl %al,%eax
80103b94:	83 ec 08             	sub    $0x8,%esp
80103b97:	52                   	push   %edx
80103b98:	50                   	push   %eax
80103b99:	e8 17 f6 ff ff       	call   801031b5 <lapicstartap>
80103b9e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103ba1:	90                   	nop
80103ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103bab:	85 c0                	test   %eax,%eax
80103bad:	74 f3                	je     80103ba2 <startothers+0x95>
80103baf:	eb 01                	jmp    80103bb2 <startothers+0xa5>
      continue;
80103bb1:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103bb2:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103bb9:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103bbe:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bc4:	05 20 48 11 80       	add    $0x80114820,%eax
80103bc9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bcc:	0f 82 6e ff ff ff    	jb     80103b40 <startothers+0x33>
      ;
  }
}
80103bd2:	90                   	nop
80103bd3:	90                   	nop
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <inb>:
{
80103bd6:	55                   	push   %ebp
80103bd7:	89 e5                	mov    %esp,%ebp
80103bd9:	83 ec 14             	sub    $0x14,%esp
80103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103be3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103be7:	89 c2                	mov    %eax,%edx
80103be9:	ec                   	in     (%dx),%al
80103bea:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bed:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103bf1:	c9                   	leave  
80103bf2:	c3                   	ret    

80103bf3 <outb>:
{
80103bf3:	55                   	push   %ebp
80103bf4:	89 e5                	mov    %esp,%ebp
80103bf6:	83 ec 08             	sub    $0x8,%esp
80103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c03:	89 d0                	mov    %edx,%eax
80103c05:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c08:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c0c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c10:	ee                   	out    %al,(%dx)
}
80103c11:	90                   	nop
80103c12:	c9                   	leave  
80103c13:	c3                   	ret    

80103c14 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c14:	f3 0f 1e fb          	endbr32 
80103c18:	55                   	push   %ebp
80103c19:	89 e5                	mov    %esp,%ebp
80103c1b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c1e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c25:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c2c:	eb 15                	jmp    80103c43 <sum+0x2f>
    sum += addr[i];
80103c2e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c31:	8b 45 08             	mov    0x8(%ebp),%eax
80103c34:	01 d0                	add    %edx,%eax
80103c36:	0f b6 00             	movzbl (%eax),%eax
80103c39:	0f b6 c0             	movzbl %al,%eax
80103c3c:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103c46:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103c49:	7c e3                	jl     80103c2e <sum+0x1a>
  return sum;
80103c4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c4e:	c9                   	leave  
80103c4f:	c3                   	ret    

80103c50 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c50:	f3 0f 1e fb          	endbr32 
80103c54:	55                   	push   %ebp
80103c55:	89 e5                	mov    %esp,%ebp
80103c57:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5d:	05 00 00 00 80       	add    $0x80000000,%eax
80103c62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c65:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6b:	01 d0                	add    %edx,%eax
80103c6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c76:	eb 36                	jmp    80103cae <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c78:	83 ec 04             	sub    $0x4,%esp
80103c7b:	6a 04                	push   $0x4
80103c7d:	68 9c 8f 10 80       	push   $0x80108f9c
80103c82:	ff 75 f4             	pushl  -0xc(%ebp)
80103c85:	e8 b4 18 00 00       	call   8010553e <memcmp>
80103c8a:	83 c4 10             	add    $0x10,%esp
80103c8d:	85 c0                	test   %eax,%eax
80103c8f:	75 19                	jne    80103caa <mpsearch1+0x5a>
80103c91:	83 ec 08             	sub    $0x8,%esp
80103c94:	6a 10                	push   $0x10
80103c96:	ff 75 f4             	pushl  -0xc(%ebp)
80103c99:	e8 76 ff ff ff       	call   80103c14 <sum>
80103c9e:	83 c4 10             	add    $0x10,%esp
80103ca1:	84 c0                	test   %al,%al
80103ca3:	75 05                	jne    80103caa <mpsearch1+0x5a>
      return (struct mp*)p;
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	eb 11                	jmp    80103cbb <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103caa:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cb4:	72 c2                	jb     80103c78 <mpsearch1+0x28>
  return 0;
80103cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cbb:	c9                   	leave  
80103cbc:	c3                   	ret    

80103cbd <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103cbd:	f3 0f 1e fb          	endbr32 
80103cc1:	55                   	push   %ebp
80103cc2:	89 e5                	mov    %esp,%ebp
80103cc4:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103cc7:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd1:	83 c0 0f             	add    $0xf,%eax
80103cd4:	0f b6 00             	movzbl (%eax),%eax
80103cd7:	0f b6 c0             	movzbl %al,%eax
80103cda:	c1 e0 08             	shl    $0x8,%eax
80103cdd:	89 c2                	mov    %eax,%edx
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	83 c0 0e             	add    $0xe,%eax
80103ce5:	0f b6 00             	movzbl (%eax),%eax
80103ce8:	0f b6 c0             	movzbl %al,%eax
80103ceb:	09 d0                	or     %edx,%eax
80103ced:	c1 e0 04             	shl    $0x4,%eax
80103cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103cf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cf7:	74 21                	je     80103d1a <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103cf9:	83 ec 08             	sub    $0x8,%esp
80103cfc:	68 00 04 00 00       	push   $0x400
80103d01:	ff 75 f0             	pushl  -0x10(%ebp)
80103d04:	e8 47 ff ff ff       	call   80103c50 <mpsearch1>
80103d09:	83 c4 10             	add    $0x10,%esp
80103d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d13:	74 51                	je     80103d66 <mpsearch+0xa9>
      return mp;
80103d15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d18:	eb 61                	jmp    80103d7b <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1d:	83 c0 14             	add    $0x14,%eax
80103d20:	0f b6 00             	movzbl (%eax),%eax
80103d23:	0f b6 c0             	movzbl %al,%eax
80103d26:	c1 e0 08             	shl    $0x8,%eax
80103d29:	89 c2                	mov    %eax,%edx
80103d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2e:	83 c0 13             	add    $0x13,%eax
80103d31:	0f b6 00             	movzbl (%eax),%eax
80103d34:	0f b6 c0             	movzbl %al,%eax
80103d37:	09 d0                	or     %edx,%eax
80103d39:	c1 e0 0a             	shl    $0xa,%eax
80103d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d42:	2d 00 04 00 00       	sub    $0x400,%eax
80103d47:	83 ec 08             	sub    $0x8,%esp
80103d4a:	68 00 04 00 00       	push   $0x400
80103d4f:	50                   	push   %eax
80103d50:	e8 fb fe ff ff       	call   80103c50 <mpsearch1>
80103d55:	83 c4 10             	add    $0x10,%esp
80103d58:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d5f:	74 05                	je     80103d66 <mpsearch+0xa9>
      return mp;
80103d61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d64:	eb 15                	jmp    80103d7b <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d66:	83 ec 08             	sub    $0x8,%esp
80103d69:	68 00 00 01 00       	push   $0x10000
80103d6e:	68 00 00 0f 00       	push   $0xf0000
80103d73:	e8 d8 fe ff ff       	call   80103c50 <mpsearch1>
80103d78:	83 c4 10             	add    $0x10,%esp
}
80103d7b:	c9                   	leave  
80103d7c:	c3                   	ret    

80103d7d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d7d:	f3 0f 1e fb          	endbr32 
80103d81:	55                   	push   %ebp
80103d82:	89 e5                	mov    %esp,%ebp
80103d84:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d87:	e8 31 ff ff ff       	call   80103cbd <mpsearch>
80103d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d93:	74 0a                	je     80103d9f <mpconfig+0x22>
80103d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d98:	8b 40 04             	mov    0x4(%eax),%eax
80103d9b:	85 c0                	test   %eax,%eax
80103d9d:	75 07                	jne    80103da6 <mpconfig+0x29>
    return 0;
80103d9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103da4:	eb 7a                	jmp    80103e20 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da9:	8b 40 04             	mov    0x4(%eax),%eax
80103dac:	05 00 00 00 80       	add    $0x80000000,%eax
80103db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103db4:	83 ec 04             	sub    $0x4,%esp
80103db7:	6a 04                	push   $0x4
80103db9:	68 a1 8f 10 80       	push   $0x80108fa1
80103dbe:	ff 75 f0             	pushl  -0x10(%ebp)
80103dc1:	e8 78 17 00 00       	call   8010553e <memcmp>
80103dc6:	83 c4 10             	add    $0x10,%esp
80103dc9:	85 c0                	test   %eax,%eax
80103dcb:	74 07                	je     80103dd4 <mpconfig+0x57>
    return 0;
80103dcd:	b8 00 00 00 00       	mov    $0x0,%eax
80103dd2:	eb 4c                	jmp    80103e20 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ddb:	3c 01                	cmp    $0x1,%al
80103ddd:	74 12                	je     80103df1 <mpconfig+0x74>
80103ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103de6:	3c 04                	cmp    $0x4,%al
80103de8:	74 07                	je     80103df1 <mpconfig+0x74>
    return 0;
80103dea:	b8 00 00 00 00       	mov    $0x0,%eax
80103def:	eb 2f                	jmp    80103e20 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103df8:	0f b7 c0             	movzwl %ax,%eax
80103dfb:	83 ec 08             	sub    $0x8,%esp
80103dfe:	50                   	push   %eax
80103dff:	ff 75 f0             	pushl  -0x10(%ebp)
80103e02:	e8 0d fe ff ff       	call   80103c14 <sum>
80103e07:	83 c4 10             	add    $0x10,%esp
80103e0a:	84 c0                	test   %al,%al
80103e0c:	74 07                	je     80103e15 <mpconfig+0x98>
    return 0;
80103e0e:	b8 00 00 00 00       	mov    $0x0,%eax
80103e13:	eb 0b                	jmp    80103e20 <mpconfig+0xa3>
  *pmp = mp;
80103e15:	8b 45 08             	mov    0x8(%ebp),%eax
80103e18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e1b:	89 10                	mov    %edx,(%eax)
  return conf;
80103e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e20:	c9                   	leave  
80103e21:	c3                   	ret    

80103e22 <mpinit>:

void
mpinit(void)
{
80103e22:	f3 0f 1e fb          	endbr32 
80103e26:	55                   	push   %ebp
80103e27:	89 e5                	mov    %esp,%ebp
80103e29:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e2c:	83 ec 0c             	sub    $0xc,%esp
80103e2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e32:	50                   	push   %eax
80103e33:	e8 45 ff ff ff       	call   80103d7d <mpconfig>
80103e38:	83 c4 10             	add    $0x10,%esp
80103e3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e42:	75 0d                	jne    80103e51 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103e44:	83 ec 0c             	sub    $0xc,%esp
80103e47:	68 a6 8f 10 80       	push   $0x80108fa6
80103e4c:	e8 b7 c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103e51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e5b:	8b 40 24             	mov    0x24(%eax),%eax
80103e5e:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e66:	83 c0 2c             	add    $0x2c,%eax
80103e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e6f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e73:	0f b7 d0             	movzwl %ax,%edx
80103e76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e79:	01 d0                	add    %edx,%eax
80103e7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e7e:	e9 8c 00 00 00       	jmp    80103f0f <mpinit+0xed>
    switch(*p){
80103e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e86:	0f b6 00             	movzbl (%eax),%eax
80103e89:	0f b6 c0             	movzbl %al,%eax
80103e8c:	83 f8 04             	cmp    $0x4,%eax
80103e8f:	7f 76                	jg     80103f07 <mpinit+0xe5>
80103e91:	83 f8 03             	cmp    $0x3,%eax
80103e94:	7d 6b                	jge    80103f01 <mpinit+0xdf>
80103e96:	83 f8 02             	cmp    $0x2,%eax
80103e99:	74 4e                	je     80103ee9 <mpinit+0xc7>
80103e9b:	83 f8 02             	cmp    $0x2,%eax
80103e9e:	7f 67                	jg     80103f07 <mpinit+0xe5>
80103ea0:	85 c0                	test   %eax,%eax
80103ea2:	74 07                	je     80103eab <mpinit+0x89>
80103ea4:	83 f8 01             	cmp    $0x1,%eax
80103ea7:	74 58                	je     80103f01 <mpinit+0xdf>
80103ea9:	eb 5c                	jmp    80103f07 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eae:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103eb1:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103eb6:	83 f8 07             	cmp    $0x7,%eax
80103eb9:	7f 28                	jg     80103ee3 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103ebb:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103ec1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ec8:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ece:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103ed4:	88 02                	mov    %al,(%edx)
        ncpu++;
80103ed6:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103edb:	83 c0 01             	add    $0x1,%eax
80103ede:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103ee3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ee7:	eb 26                	jmp    80103f0f <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ef2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ef6:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103efb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103eff:	eb 0e                	jmp    80103f0f <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f01:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f05:	eb 08                	jmp    80103f0f <mpinit+0xed>
    default:
      ismp = 0;
80103f07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f0e:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f12:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f15:	0f 82 68 ff ff ff    	jb     80103e83 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f1f:	75 0d                	jne    80103f2e <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f21:	83 ec 0c             	sub    $0xc,%esp
80103f24:	68 c0 8f 10 80       	push   $0x80108fc0
80103f29:	e8 da c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f31:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f35:	84 c0                	test   %al,%al
80103f37:	74 30                	je     80103f69 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f39:	83 ec 08             	sub    $0x8,%esp
80103f3c:	6a 70                	push   $0x70
80103f3e:	6a 22                	push   $0x22
80103f40:	e8 ae fc ff ff       	call   80103bf3 <outb>
80103f45:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f48:	83 ec 0c             	sub    $0xc,%esp
80103f4b:	6a 23                	push   $0x23
80103f4d:	e8 84 fc ff ff       	call   80103bd6 <inb>
80103f52:	83 c4 10             	add    $0x10,%esp
80103f55:	83 c8 01             	or     $0x1,%eax
80103f58:	0f b6 c0             	movzbl %al,%eax
80103f5b:	83 ec 08             	sub    $0x8,%esp
80103f5e:	50                   	push   %eax
80103f5f:	6a 23                	push   $0x23
80103f61:	e8 8d fc ff ff       	call   80103bf3 <outb>
80103f66:	83 c4 10             	add    $0x10,%esp
  }
}
80103f69:	90                   	nop
80103f6a:	c9                   	leave  
80103f6b:	c3                   	ret    

80103f6c <outb>:
{
80103f6c:	55                   	push   %ebp
80103f6d:	89 e5                	mov    %esp,%ebp
80103f6f:	83 ec 08             	sub    $0x8,%esp
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f78:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f7c:	89 d0                	mov    %edx,%eax
80103f7e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f81:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f85:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f89:	ee                   	out    %al,(%dx)
}
80103f8a:	90                   	nop
80103f8b:	c9                   	leave  
80103f8c:	c3                   	ret    

80103f8d <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f8d:	f3 0f 1e fb          	endbr32 
80103f91:	55                   	push   %ebp
80103f92:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f94:	68 ff 00 00 00       	push   $0xff
80103f99:	6a 21                	push   $0x21
80103f9b:	e8 cc ff ff ff       	call   80103f6c <outb>
80103fa0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fa3:	68 ff 00 00 00       	push   $0xff
80103fa8:	68 a1 00 00 00       	push   $0xa1
80103fad:	e8 ba ff ff ff       	call   80103f6c <outb>
80103fb2:	83 c4 08             	add    $0x8,%esp
}
80103fb5:	90                   	nop
80103fb6:	c9                   	leave  
80103fb7:	c3                   	ret    

80103fb8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fb8:	f3 0f 1e fb          	endbr32 
80103fbc:	55                   	push   %ebp
80103fbd:	89 e5                	mov    %esp,%ebp
80103fbf:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd5:	8b 10                	mov    (%eax),%edx
80103fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fda:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fdc:	e8 e2 d0 ff ff       	call   801010c3 <filealloc>
80103fe1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe4:	89 02                	mov    %eax,(%edx)
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	85 c0                	test   %eax,%eax
80103fed:	0f 84 c8 00 00 00    	je     801040bb <pipealloc+0x103>
80103ff3:	e8 cb d0 ff ff       	call   801010c3 <filealloc>
80103ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ffb:	89 02                	mov    %eax,(%edx)
80103ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104000:	8b 00                	mov    (%eax),%eax
80104002:	85 c0                	test   %eax,%eax
80104004:	0f 84 b1 00 00 00    	je     801040bb <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010400a:	e8 ea ed ff ff       	call   80102df9 <kalloc>
8010400f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104012:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104016:	0f 84 a2 00 00 00    	je     801040be <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010401c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104026:	00 00 00 
  p->writeopen = 1;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104033:	00 00 00 
  p->nwrite = 0;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104040:	00 00 00 
  p->nread = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010404d:	00 00 00 
  initlock(&p->lock, "pipe");
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	83 ec 08             	sub    $0x8,%esp
80104056:	68 df 8f 10 80       	push   $0x80108fdf
8010405b:	50                   	push   %eax
8010405c:	e8 ad 11 00 00       	call   8010520e <initlock>
80104061:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	8b 00                	mov    (%eax),%eax
80104069:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010406f:	8b 45 08             	mov    0x8(%ebp),%eax
80104072:	8b 00                	mov    (%eax),%eax
80104074:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	8b 00                	mov    (%eax),%eax
8010407d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104081:	8b 45 08             	mov    0x8(%ebp),%eax
80104084:	8b 00                	mov    (%eax),%eax
80104086:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104089:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010408c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408f:	8b 00                	mov    (%eax),%eax
80104091:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409a:	8b 00                	mov    (%eax),%eax
8010409c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a3:	8b 00                	mov    (%eax),%eax
801040a5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ac:	8b 00                	mov    (%eax),%eax
801040ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b1:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040b4:	b8 00 00 00 00       	mov    $0x0,%eax
801040b9:	eb 51                	jmp    8010410c <pipealloc+0x154>
    goto bad;
801040bb:	90                   	nop
801040bc:	eb 01                	jmp    801040bf <pipealloc+0x107>
    goto bad;
801040be:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801040bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040c3:	74 0e                	je     801040d3 <pipealloc+0x11b>
    kfree((char*)p);
801040c5:	83 ec 0c             	sub    $0xc,%esp
801040c8:	ff 75 f4             	pushl  -0xc(%ebp)
801040cb:	e8 8b ec ff ff       	call   80102d5b <kfree>
801040d0:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040d3:	8b 45 08             	mov    0x8(%ebp),%eax
801040d6:	8b 00                	mov    (%eax),%eax
801040d8:	85 c0                	test   %eax,%eax
801040da:	74 11                	je     801040ed <pipealloc+0x135>
    fileclose(*f0);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 00                	mov    (%eax),%eax
801040e1:	83 ec 0c             	sub    $0xc,%esp
801040e4:	50                   	push   %eax
801040e5:	e8 9f d0 ff ff       	call   80101189 <fileclose>
801040ea:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f0:	8b 00                	mov    (%eax),%eax
801040f2:	85 c0                	test   %eax,%eax
801040f4:	74 11                	je     80104107 <pipealloc+0x14f>
    fileclose(*f1);
801040f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f9:	8b 00                	mov    (%eax),%eax
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	50                   	push   %eax
801040ff:	e8 85 d0 ff ff       	call   80101189 <fileclose>
80104104:	83 c4 10             	add    $0x10,%esp
  return -1;
80104107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010410c:	c9                   	leave  
8010410d:	c3                   	ret    

8010410e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410e:	f3 0f 1e fb          	endbr32 
80104112:	55                   	push   %ebp
80104113:	89 e5                	mov    %esp,%ebp
80104115:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104118:	8b 45 08             	mov    0x8(%ebp),%eax
8010411b:	83 ec 0c             	sub    $0xc,%esp
8010411e:	50                   	push   %eax
8010411f:	e8 10 11 00 00       	call   80105234 <acquire>
80104124:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104127:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010412b:	74 23                	je     80104150 <pipeclose+0x42>
    p->writeopen = 0;
8010412d:	8b 45 08             	mov    0x8(%ebp),%eax
80104130:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104137:	00 00 00 
    wakeup(&p->nread);
8010413a:	8b 45 08             	mov    0x8(%ebp),%eax
8010413d:	05 34 02 00 00       	add    $0x234,%eax
80104142:	83 ec 0c             	sub    $0xc,%esp
80104145:	50                   	push   %eax
80104146:	e8 6f 0d 00 00       	call   80104eba <wakeup>
8010414b:	83 c4 10             	add    $0x10,%esp
8010414e:	eb 21                	jmp    80104171 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010415a:	00 00 00 
    wakeup(&p->nwrite);
8010415d:	8b 45 08             	mov    0x8(%ebp),%eax
80104160:	05 38 02 00 00       	add    $0x238,%eax
80104165:	83 ec 0c             	sub    $0xc,%esp
80104168:	50                   	push   %eax
80104169:	e8 4c 0d 00 00       	call   80104eba <wakeup>
8010416e:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104171:	8b 45 08             	mov    0x8(%ebp),%eax
80104174:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010417a:	85 c0                	test   %eax,%eax
8010417c:	75 2c                	jne    801041aa <pipeclose+0x9c>
8010417e:	8b 45 08             	mov    0x8(%ebp),%eax
80104181:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104187:	85 c0                	test   %eax,%eax
80104189:	75 1f                	jne    801041aa <pipeclose+0x9c>
    release(&p->lock);
8010418b:	8b 45 08             	mov    0x8(%ebp),%eax
8010418e:	83 ec 0c             	sub    $0xc,%esp
80104191:	50                   	push   %eax
80104192:	e8 0f 11 00 00       	call   801052a6 <release>
80104197:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010419a:	83 ec 0c             	sub    $0xc,%esp
8010419d:	ff 75 08             	pushl  0x8(%ebp)
801041a0:	e8 b6 eb ff ff       	call   80102d5b <kfree>
801041a5:	83 c4 10             	add    $0x10,%esp
801041a8:	eb 10                	jmp    801041ba <pipeclose+0xac>
  } else
    release(&p->lock);
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	83 ec 0c             	sub    $0xc,%esp
801041b0:	50                   	push   %eax
801041b1:	e8 f0 10 00 00       	call   801052a6 <release>
801041b6:	83 c4 10             	add    $0x10,%esp
}
801041b9:	90                   	nop
801041ba:	90                   	nop
801041bb:	c9                   	leave  
801041bc:	c3                   	ret    

801041bd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041bd:	f3 0f 1e fb          	endbr32 
801041c1:	55                   	push   %ebp
801041c2:	89 e5                	mov    %esp,%ebp
801041c4:	53                   	push   %ebx
801041c5:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	83 ec 0c             	sub    $0xc,%esp
801041ce:	50                   	push   %eax
801041cf:	e8 60 10 00 00       	call   80105234 <acquire>
801041d4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041de:	e9 ad 00 00 00       	jmp    80104290 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
801041e6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041ec:	85 c0                	test   %eax,%eax
801041ee:	74 0c                	je     801041fc <pipewrite+0x3f>
801041f0:	e8 a2 02 00 00       	call   80104497 <myproc>
801041f5:	8b 40 24             	mov    0x24(%eax),%eax
801041f8:	85 c0                	test   %eax,%eax
801041fa:	74 19                	je     80104215 <pipewrite+0x58>
        release(&p->lock);
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
801041ff:	83 ec 0c             	sub    $0xc,%esp
80104202:	50                   	push   %eax
80104203:	e8 9e 10 00 00       	call   801052a6 <release>
80104208:	83 c4 10             	add    $0x10,%esp
        return -1;
8010420b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104210:	e9 a9 00 00 00       	jmp    801042be <pipewrite+0x101>
      }
      wakeup(&p->nread);
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	05 34 02 00 00       	add    $0x234,%eax
8010421d:	83 ec 0c             	sub    $0xc,%esp
80104220:	50                   	push   %eax
80104221:	e8 94 0c 00 00       	call   80104eba <wakeup>
80104226:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	8b 55 08             	mov    0x8(%ebp),%edx
8010422f:	81 c2 38 02 00 00    	add    $0x238,%edx
80104235:	83 ec 08             	sub    $0x8,%esp
80104238:	50                   	push   %eax
80104239:	52                   	push   %edx
8010423a:	e8 8c 0b 00 00       	call   80104dcb <sleep>
8010423f:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104242:	8b 45 08             	mov    0x8(%ebp),%eax
80104245:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010424b:	8b 45 08             	mov    0x8(%ebp),%eax
8010424e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104254:	05 00 02 00 00       	add    $0x200,%eax
80104259:	39 c2                	cmp    %eax,%edx
8010425b:	74 86                	je     801041e3 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010425d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104260:	8b 45 0c             	mov    0xc(%ebp),%eax
80104263:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010426f:	8d 48 01             	lea    0x1(%eax),%ecx
80104272:	8b 55 08             	mov    0x8(%ebp),%edx
80104275:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010427b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104280:	89 c1                	mov    %eax,%ecx
80104282:	0f b6 13             	movzbl (%ebx),%edx
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010428c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104293:	3b 45 10             	cmp    0x10(%ebp),%eax
80104296:	7c aa                	jl     80104242 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104298:	8b 45 08             	mov    0x8(%ebp),%eax
8010429b:	05 34 02 00 00       	add    $0x234,%eax
801042a0:	83 ec 0c             	sub    $0xc,%esp
801042a3:	50                   	push   %eax
801042a4:	e8 11 0c 00 00       	call   80104eba <wakeup>
801042a9:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801042ac:	8b 45 08             	mov    0x8(%ebp),%eax
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	50                   	push   %eax
801042b3:	e8 ee 0f 00 00       	call   801052a6 <release>
801042b8:	83 c4 10             	add    $0x10,%esp
  return n;
801042bb:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042c1:	c9                   	leave  
801042c2:	c3                   	ret    

801042c3 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042c3:	f3 0f 1e fb          	endbr32 
801042c7:	55                   	push   %ebp
801042c8:	89 e5                	mov    %esp,%ebp
801042ca:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042cd:	8b 45 08             	mov    0x8(%ebp),%eax
801042d0:	83 ec 0c             	sub    $0xc,%esp
801042d3:	50                   	push   %eax
801042d4:	e8 5b 0f 00 00       	call   80105234 <acquire>
801042d9:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042dc:	eb 3e                	jmp    8010431c <piperead+0x59>
    if(myproc()->killed){
801042de:	e8 b4 01 00 00       	call   80104497 <myproc>
801042e3:	8b 40 24             	mov    0x24(%eax),%eax
801042e6:	85 c0                	test   %eax,%eax
801042e8:	74 19                	je     80104303 <piperead+0x40>
      release(&p->lock);
801042ea:	8b 45 08             	mov    0x8(%ebp),%eax
801042ed:	83 ec 0c             	sub    $0xc,%esp
801042f0:	50                   	push   %eax
801042f1:	e8 b0 0f 00 00       	call   801052a6 <release>
801042f6:	83 c4 10             	add    $0x10,%esp
      return -1;
801042f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fe:	e9 be 00 00 00       	jmp    801043c1 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	8b 55 08             	mov    0x8(%ebp),%edx
80104309:	81 c2 34 02 00 00    	add    $0x234,%edx
8010430f:	83 ec 08             	sub    $0x8,%esp
80104312:	50                   	push   %eax
80104313:	52                   	push   %edx
80104314:	e8 b2 0a 00 00       	call   80104dcb <sleep>
80104319:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010431c:	8b 45 08             	mov    0x8(%ebp),%eax
8010431f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104325:	8b 45 08             	mov    0x8(%ebp),%eax
80104328:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432e:	39 c2                	cmp    %eax,%edx
80104330:	75 0d                	jne    8010433f <piperead+0x7c>
80104332:	8b 45 08             	mov    0x8(%ebp),%eax
80104335:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010433b:	85 c0                	test   %eax,%eax
8010433d:	75 9f                	jne    801042de <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010433f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104346:	eb 48                	jmp    80104390 <piperead+0xcd>
    if(p->nread == p->nwrite)
80104348:	8b 45 08             	mov    0x8(%ebp),%eax
8010434b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104351:	8b 45 08             	mov    0x8(%ebp),%eax
80104354:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010435a:	39 c2                	cmp    %eax,%edx
8010435c:	74 3c                	je     8010439a <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010435e:	8b 45 08             	mov    0x8(%ebp),%eax
80104361:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104367:	8d 48 01             	lea    0x1(%eax),%ecx
8010436a:	8b 55 08             	mov    0x8(%ebp),%edx
8010436d:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104373:	25 ff 01 00 00       	and    $0x1ff,%eax
80104378:	89 c1                	mov    %eax,%ecx
8010437a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010437d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104380:	01 c2                	add    %eax,%edx
80104382:	8b 45 08             	mov    0x8(%ebp),%eax
80104385:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010438a:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010438c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104393:	3b 45 10             	cmp    0x10(%ebp),%eax
80104396:	7c b0                	jl     80104348 <piperead+0x85>
80104398:	eb 01                	jmp    8010439b <piperead+0xd8>
      break;
8010439a:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010439b:	8b 45 08             	mov    0x8(%ebp),%eax
8010439e:	05 38 02 00 00       	add    $0x238,%eax
801043a3:	83 ec 0c             	sub    $0xc,%esp
801043a6:	50                   	push   %eax
801043a7:	e8 0e 0b 00 00       	call   80104eba <wakeup>
801043ac:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043af:	8b 45 08             	mov    0x8(%ebp),%eax
801043b2:	83 ec 0c             	sub    $0xc,%esp
801043b5:	50                   	push   %eax
801043b6:	e8 eb 0e 00 00       	call   801052a6 <release>
801043bb:	83 c4 10             	add    $0x10,%esp
  return i;
801043be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043c1:	c9                   	leave  
801043c2:	c3                   	ret    

801043c3 <readeflags>:
{
801043c3:	55                   	push   %ebp
801043c4:	89 e5                	mov    %esp,%ebp
801043c6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043c9:	9c                   	pushf  
801043ca:	58                   	pop    %eax
801043cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043d1:	c9                   	leave  
801043d2:	c3                   	ret    

801043d3 <sti>:
{
801043d3:	55                   	push   %ebp
801043d4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043d6:	fb                   	sti    
}
801043d7:	90                   	nop
801043d8:	5d                   	pop    %ebp
801043d9:	c3                   	ret    

801043da <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043da:	f3 0f 1e fb          	endbr32 
801043de:	55                   	push   %ebp
801043df:	89 e5                	mov    %esp,%ebp
801043e1:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043e4:	83 ec 08             	sub    $0x8,%esp
801043e7:	68 e4 8f 10 80       	push   $0x80108fe4
801043ec:	68 c0 4d 11 80       	push   $0x80114dc0
801043f1:	e8 18 0e 00 00       	call   8010520e <initlock>
801043f6:	83 c4 10             	add    $0x10,%esp
}
801043f9:	90                   	nop
801043fa:	c9                   	leave  
801043fb:	c3                   	ret    

801043fc <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801043fc:	f3 0f 1e fb          	endbr32 
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104406:	e8 10 00 00 00       	call   8010441b <mycpu>
8010440b:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104410:	c1 f8 04             	sar    $0x4,%eax
80104413:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104419:	c9                   	leave  
8010441a:	c3                   	ret    

8010441b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010441b:	f3 0f 1e fb          	endbr32 
8010441f:	55                   	push   %ebp
80104420:	89 e5                	mov    %esp,%ebp
80104422:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104425:	e8 99 ff ff ff       	call   801043c3 <readeflags>
8010442a:	25 00 02 00 00       	and    $0x200,%eax
8010442f:	85 c0                	test   %eax,%eax
80104431:	74 0d                	je     80104440 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80104433:	83 ec 0c             	sub    $0xc,%esp
80104436:	68 ec 8f 10 80       	push   $0x80108fec
8010443b:	e8 c8 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
80104440:	e8 21 ed ff ff       	call   80103166 <lapicid>
80104445:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104448:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010444f:	eb 2d                	jmp    8010447e <mycpu+0x63>
    if (cpus[i].apicid == apicid)
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010445a:	05 20 48 11 80       	add    $0x80114820,%eax
8010445f:	0f b6 00             	movzbl (%eax),%eax
80104462:	0f b6 c0             	movzbl %al,%eax
80104465:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104468:	75 10                	jne    8010447a <mycpu+0x5f>
      return &cpus[i];
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104473:	05 20 48 11 80       	add    $0x80114820,%eax
80104478:	eb 1b                	jmp    80104495 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
8010447a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010447e:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80104483:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104486:	7c c9                	jl     80104451 <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104488:	83 ec 0c             	sub    $0xc,%esp
8010448b:	68 12 90 10 80       	push   $0x80109012
80104490:	e8 73 c1 ff ff       	call   80100608 <panic>
}
80104495:	c9                   	leave  
80104496:	c3                   	ret    

80104497 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104497:	f3 0f 1e fb          	endbr32 
8010449b:	55                   	push   %ebp
8010449c:	89 e5                	mov    %esp,%ebp
8010449e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044a1:	e8 1a 0f 00 00       	call   801053c0 <pushcli>
  c = mycpu();
801044a6:	e8 70 ff ff ff       	call   8010441b <mycpu>
801044ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044ba:	e8 52 0f 00 00       	call   80105411 <popcli>
  return p;
801044bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801044c2:	c9                   	leave  
801044c3:	c3                   	ret    

801044c4 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044c4:	f3 0f 1e fb          	endbr32 
801044c8:	55                   	push   %ebp
801044c9:	89 e5                	mov    %esp,%ebp
801044cb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044ce:	83 ec 0c             	sub    $0xc,%esp
801044d1:	68 c0 4d 11 80       	push   $0x80114dc0
801044d6:	e8 59 0d 00 00       	call   80105234 <acquire>
801044db:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044de:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
801044e5:	eb 0e                	jmp    801044f5 <allocproc+0x31>
    if(p->state == UNUSED)
801044e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ea:	8b 40 0c             	mov    0xc(%eax),%eax
801044ed:	85 c0                	test   %eax,%eax
801044ef:	74 27                	je     80104518 <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044f1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044f5:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
801044fc:	72 e9                	jb     801044e7 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
801044fe:	83 ec 0c             	sub    $0xc,%esp
80104501:	68 c0 4d 11 80       	push   $0x80114dc0
80104506:	e8 9b 0d 00 00       	call   801052a6 <release>
8010450b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010450e:	b8 00 00 00 00       	mov    $0x0,%eax
80104513:	e9 b6 00 00 00       	jmp    801045ce <allocproc+0x10a>
      goto found;
80104518:	90                   	nop
80104519:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
8010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104520:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104527:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010452c:	8d 50 01             	lea    0x1(%eax),%edx
8010452f:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104538:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010453b:	83 ec 0c             	sub    $0xc,%esp
8010453e:	68 c0 4d 11 80       	push   $0x80114dc0
80104543:	e8 5e 0d 00 00       	call   801052a6 <release>
80104548:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010454b:	e8 a9 e8 ff ff       	call   80102df9 <kalloc>
80104550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104553:	89 42 08             	mov    %eax,0x8(%edx)
80104556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104559:	8b 40 08             	mov    0x8(%eax),%eax
8010455c:	85 c0                	test   %eax,%eax
8010455e:	75 11                	jne    80104571 <allocproc+0xad>
    p->state = UNUSED;
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010456a:	b8 00 00 00 00       	mov    $0x0,%eax
8010456f:	eb 5d                	jmp    801045ce <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104574:	8b 40 08             	mov    0x8(%eax),%eax
80104577:	05 00 10 00 00       	add    $0x1000,%eax
8010457c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010457f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104586:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104589:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010458c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104590:	ba 50 6a 10 80       	mov    $0x80106a50,%edx
80104595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104598:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010459a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010459e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a4:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045aa:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ad:	83 ec 04             	sub    $0x4,%esp
801045b0:	6a 14                	push   $0x14
801045b2:	6a 00                	push   $0x0
801045b4:	50                   	push   %eax
801045b5:	e8 19 0f 00 00       	call   801054d3 <memset>
801045ba:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	8b 40 1c             	mov    0x1c(%eax),%eax
801045c3:	ba 81 4d 10 80       	mov    $0x80104d81,%edx
801045c8:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045ce:	c9                   	leave  
801045cf:	c3                   	ret    

801045d0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045d0:	f3 0f 1e fb          	endbr32 
801045d4:	55                   	push   %ebp
801045d5:	89 e5                	mov    %esp,%ebp
801045d7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045da:	e8 e5 fe ff ff       	call   801044c4 <allocproc>
801045df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e5:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
801045ea:	e8 1c 3a 00 00       	call   8010800b <setupkvm>
801045ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f2:	89 42 04             	mov    %eax,0x4(%edx)
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	8b 40 04             	mov    0x4(%eax),%eax
801045fb:	85 c0                	test   %eax,%eax
801045fd:	75 0d                	jne    8010460c <userinit+0x3c>
    panic("userinit: out of memory?");
801045ff:	83 ec 0c             	sub    $0xc,%esp
80104602:	68 22 90 10 80       	push   $0x80109022
80104607:	e8 fc bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010460c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104614:	8b 40 04             	mov    0x4(%eax),%eax
80104617:	83 ec 04             	sub    $0x4,%esp
8010461a:	52                   	push   %edx
8010461b:	68 e0 c4 10 80       	push   $0x8010c4e0
80104620:	50                   	push   %eax
80104621:	e8 5e 3c 00 00       	call   80108284 <inituvm>
80104626:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	8b 40 18             	mov    0x18(%eax),%eax
80104638:	83 ec 04             	sub    $0x4,%esp
8010463b:	6a 4c                	push   $0x4c
8010463d:	6a 00                	push   $0x0
8010463f:	50                   	push   %eax
80104640:	e8 8e 0e 00 00       	call   801054d3 <memset>
80104645:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464b:	8b 40 18             	mov    0x18(%eax),%eax
8010464e:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104657:	8b 40 18             	mov    0x18(%eax),%eax
8010465a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104663:	8b 50 18             	mov    0x18(%eax),%edx
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	8b 40 18             	mov    0x18(%eax),%eax
8010466c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104670:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104677:	8b 50 18             	mov    0x18(%eax),%edx
8010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467d:	8b 40 18             	mov    0x18(%eax),%eax
80104680:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104684:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468b:	8b 40 18             	mov    0x18(%eax),%eax
8010468e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104698:	8b 40 18             	mov    0x18(%eax),%eax
8010469b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	8b 40 18             	mov    0x18(%eax),%eax
801046a8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b2:	83 c0 6c             	add    $0x6c,%eax
801046b5:	83 ec 04             	sub    $0x4,%esp
801046b8:	6a 10                	push   $0x10
801046ba:	68 3b 90 10 80       	push   $0x8010903b
801046bf:	50                   	push   %eax
801046c0:	e8 29 10 00 00       	call   801056ee <safestrcpy>
801046c5:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046c8:	83 ec 0c             	sub    $0xc,%esp
801046cb:	68 44 90 10 80       	push   $0x80109044
801046d0:	e8 9f df ff ff       	call   80102674 <namei>
801046d5:	83 c4 10             	add    $0x10,%esp
801046d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046db:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801046de:	83 ec 0c             	sub    $0xc,%esp
801046e1:	68 c0 4d 11 80       	push   $0x80114dc0
801046e6:	e8 49 0b 00 00       	call   80105234 <acquire>
801046eb:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801046f8:	83 ec 0c             	sub    $0xc,%esp
801046fb:	68 c0 4d 11 80       	push   $0x80114dc0
80104700:	e8 a1 0b 00 00       	call   801052a6 <release>
80104705:	83 c4 10             	add    $0x10,%esp
}
80104708:	90                   	nop
80104709:	c9                   	leave  
8010470a:	c3                   	ret    

8010470b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010470b:	f3 0f 1e fb          	endbr32 
8010470f:	55                   	push   %ebp
80104710:	89 e5                	mov    %esp,%ebp
80104712:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104715:	e8 7d fd ff ff       	call   80104497 <myproc>
8010471a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
8010471d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104720:	8b 00                	mov    (%eax),%eax
80104722:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104725:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104729:	7e 31                	jle    8010475c <growproc+0x51>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010472b:	8b 55 08             	mov    0x8(%ebp),%edx
8010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104731:	01 c2                	add    %eax,%edx
80104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104736:	8b 40 04             	mov    0x4(%eax),%eax
80104739:	83 ec 04             	sub    $0x4,%esp
8010473c:	52                   	push   %edx
8010473d:	ff 75 f4             	pushl  -0xc(%ebp)
80104740:	50                   	push   %eax
80104741:	e8 83 3c 00 00       	call   801083c9 <allocuvm>
80104746:	83 c4 10             	add    $0x10,%esp
80104749:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010474c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104750:	75 3e                	jne    80104790 <growproc+0x85>
      return -1;
80104752:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104757:	e9 a7 00 00 00       	jmp    80104803 <growproc+0xf8>
  } else if(n < 0){
8010475c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104760:	79 2e                	jns    80104790 <growproc+0x85>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104762:	8b 55 08             	mov    0x8(%ebp),%edx
80104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104768:	01 c2                	add    %eax,%edx
8010476a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010476d:	8b 40 04             	mov    0x4(%eax),%eax
80104770:	83 ec 04             	sub    $0x4,%esp
80104773:	52                   	push   %edx
80104774:	ff 75 f4             	pushl  -0xc(%ebp)
80104777:	50                   	push   %eax
80104778:	e8 55 3d 00 00       	call   801084d2 <deallocuvm>
8010477d:	83 c4 10             	add    $0x10,%esp
80104780:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104783:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104787:	75 07                	jne    80104790 <growproc+0x85>
      return -1;
80104789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010478e:	eb 73                	jmp    80104803 <growproc+0xf8>
  }
  curproc->sz = sz;
80104790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104793:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104796:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104798:	83 ec 0c             	sub    $0xc,%esp
8010479b:	ff 75 f0             	pushl  -0x10(%ebp)
8010479e:	e8 3e 39 00 00       	call   801080e1 <switchuvm>
801047a3:	83 c4 10             	add    $0x10,%esp
  //p5 melody changes
  uint page_num=n/PGSIZE;
801047a6:	8b 45 08             	mov    0x8(%ebp),%eax
801047a9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801047af:	85 c0                	test   %eax,%eax
801047b1:	0f 48 c2             	cmovs  %edx,%eax
801047b4:	c1 f8 0c             	sar    $0xc,%eax
801047b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  cprintf("growproc-page_num:%d\n",page_num);
801047ba:	83 ec 08             	sub    $0x8,%esp
801047bd:	ff 75 ec             	pushl  -0x14(%ebp)
801047c0:	68 46 90 10 80       	push   $0x80109046
801047c5:	e8 4e bc ff ff       	call   80100418 <cprintf>
801047ca:	83 c4 10             	add    $0x10,%esp
  if(mencrypt((char*)PGROUNDUP(sz-n),page_num)!=0) return -1;
801047cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d0:	8b 55 08             	mov    0x8(%ebp),%edx
801047d3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047d6:	29 d1                	sub    %edx,%ecx
801047d8:	89 ca                	mov    %ecx,%edx
801047da:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
801047e0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801047e6:	83 ec 08             	sub    $0x8,%esp
801047e9:	50                   	push   %eax
801047ea:	52                   	push   %edx
801047eb:	e8 4d 41 00 00       	call   8010893d <mencrypt>
801047f0:	83 c4 10             	add    $0x10,%esp
801047f3:	85 c0                	test   %eax,%eax
801047f5:	74 07                	je     801047fe <growproc+0xf3>
801047f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047fc:	eb 05                	jmp    80104803 <growproc+0xf8>
  //ends
  return 0;
801047fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104803:	c9                   	leave  
80104804:	c3                   	ret    

80104805 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104805:	f3 0f 1e fb          	endbr32 
80104809:	55                   	push   %ebp
8010480a:	89 e5                	mov    %esp,%ebp
8010480c:	57                   	push   %edi
8010480d:	56                   	push   %esi
8010480e:	53                   	push   %ebx
8010480f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104812:	e8 80 fc ff ff       	call   80104497 <myproc>
80104817:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010481a:	e8 a5 fc ff ff       	call   801044c4 <allocproc>
8010481f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104822:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104826:	75 0a                	jne    80104832 <fork+0x2d>
    return -1;
80104828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482d:	e9 48 01 00 00       	jmp    8010497a <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104832:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104835:	8b 10                	mov    (%eax),%edx
80104837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483a:	8b 40 04             	mov    0x4(%eax),%eax
8010483d:	83 ec 08             	sub    $0x8,%esp
80104840:	52                   	push   %edx
80104841:	50                   	push   %eax
80104842:	e8 37 3e 00 00       	call   8010867e <copyuvm>
80104847:	83 c4 10             	add    $0x10,%esp
8010484a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010484d:	89 42 04             	mov    %eax,0x4(%edx)
80104850:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104853:	8b 40 04             	mov    0x4(%eax),%eax
80104856:	85 c0                	test   %eax,%eax
80104858:	75 30                	jne    8010488a <fork+0x85>
    kfree(np->kstack);
8010485a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010485d:	8b 40 08             	mov    0x8(%eax),%eax
80104860:	83 ec 0c             	sub    $0xc,%esp
80104863:	50                   	push   %eax
80104864:	e8 f2 e4 ff ff       	call   80102d5b <kfree>
80104869:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010486c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010486f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104876:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104879:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104885:	e9 f0 00 00 00       	jmp    8010497a <fork+0x175>
  }
  np->sz = curproc->sz;
8010488a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488d:	8b 10                	mov    (%eax),%edx
8010488f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104892:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104894:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104897:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010489a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010489d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a0:	8b 48 18             	mov    0x18(%eax),%ecx
801048a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a6:	8b 40 18             	mov    0x18(%eax),%eax
801048a9:	89 c2                	mov    %eax,%edx
801048ab:	89 cb                	mov    %ecx,%ebx
801048ad:	b8 13 00 00 00       	mov    $0x13,%eax
801048b2:	89 d7                	mov    %edx,%edi
801048b4:	89 de                	mov    %ebx,%esi
801048b6:	89 c1                	mov    %eax,%ecx
801048b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bd:	8b 40 18             	mov    0x18(%eax),%eax
801048c0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048ce:	eb 3b                	jmp    8010490b <fork+0x106>
    if(curproc->ofile[i])
801048d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048d6:	83 c2 08             	add    $0x8,%edx
801048d9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048dd:	85 c0                	test   %eax,%eax
801048df:	74 26                	je     80104907 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048e7:	83 c2 08             	add    $0x8,%edx
801048ea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	50                   	push   %eax
801048f2:	e8 3d c8 ff ff       	call   80101134 <filedup>
801048f7:	83 c4 10             	add    $0x10,%esp
801048fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048fd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104900:	83 c1 08             	add    $0x8,%ecx
80104903:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104907:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010490b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010490f:	7e bf                	jle    801048d0 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104911:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104914:	8b 40 68             	mov    0x68(%eax),%eax
80104917:	83 ec 0c             	sub    $0xc,%esp
8010491a:	50                   	push   %eax
8010491b:	e8 ab d1 ff ff       	call   80101acb <idup>
80104920:	83 c4 10             	add    $0x10,%esp
80104923:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104926:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104929:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010492f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104932:	83 c0 6c             	add    $0x6c,%eax
80104935:	83 ec 04             	sub    $0x4,%esp
80104938:	6a 10                	push   $0x10
8010493a:	52                   	push   %edx
8010493b:	50                   	push   %eax
8010493c:	e8 ad 0d 00 00       	call   801056ee <safestrcpy>
80104941:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104944:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104947:	8b 40 10             	mov    0x10(%eax),%eax
8010494a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010494d:	83 ec 0c             	sub    $0xc,%esp
80104950:	68 c0 4d 11 80       	push   $0x80114dc0
80104955:	e8 da 08 00 00       	call   80105234 <acquire>
8010495a:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010495d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104960:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104967:	83 ec 0c             	sub    $0xc,%esp
8010496a:	68 c0 4d 11 80       	push   $0x80114dc0
8010496f:	e8 32 09 00 00       	call   801052a6 <release>
80104974:	83 c4 10             	add    $0x10,%esp

  return pid;
80104977:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010497a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010497d:	5b                   	pop    %ebx
8010497e:	5e                   	pop    %esi
8010497f:	5f                   	pop    %edi
80104980:	5d                   	pop    %ebp
80104981:	c3                   	ret    

80104982 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104982:	f3 0f 1e fb          	endbr32 
80104986:	55                   	push   %ebp
80104987:	89 e5                	mov    %esp,%ebp
80104989:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010498c:	e8 06 fb ff ff       	call   80104497 <myproc>
80104991:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104994:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104999:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010499c:	75 0d                	jne    801049ab <exit+0x29>
    panic("init exiting");
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	68 5c 90 10 80       	push   $0x8010905c
801049a6:	e8 5d bc ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049b2:	eb 3f                	jmp    801049f3 <exit+0x71>
    if(curproc->ofile[fd]){
801049b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049ba:	83 c2 08             	add    $0x8,%edx
801049bd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049c1:	85 c0                	test   %eax,%eax
801049c3:	74 2a                	je     801049ef <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801049c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049cb:	83 c2 08             	add    $0x8,%edx
801049ce:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049d2:	83 ec 0c             	sub    $0xc,%esp
801049d5:	50                   	push   %eax
801049d6:	e8 ae c7 ff ff       	call   80101189 <fileclose>
801049db:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801049de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049e4:	83 c2 08             	add    $0x8,%edx
801049e7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049ee:	00 
  for(fd = 0; fd < NOFILE; fd++){
801049ef:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049f3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049f7:	7e bb                	jle    801049b4 <exit+0x32>
    }
  }

  begin_op();
801049f9:	e8 da ec ff ff       	call   801036d8 <begin_op>
  iput(curproc->cwd);
801049fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a01:	8b 40 68             	mov    0x68(%eax),%eax
80104a04:	83 ec 0c             	sub    $0xc,%esp
80104a07:	50                   	push   %eax
80104a08:	e8 65 d2 ff ff       	call   80101c72 <iput>
80104a0d:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a10:	e8 53 ed ff ff       	call   80103768 <end_op>
  curproc->cwd = 0;
80104a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a18:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a1f:	83 ec 0c             	sub    $0xc,%esp
80104a22:	68 c0 4d 11 80       	push   $0x80114dc0
80104a27:	e8 08 08 00 00       	call   80105234 <acquire>
80104a2c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a32:	8b 40 14             	mov    0x14(%eax),%eax
80104a35:	83 ec 0c             	sub    $0xc,%esp
80104a38:	50                   	push   %eax
80104a39:	e8 38 04 00 00       	call   80104e76 <wakeup1>
80104a3e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a41:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104a48:	eb 37                	jmp    80104a81 <exit+0xff>
    if(p->parent == curproc){
80104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4d:	8b 40 14             	mov    0x14(%eax),%eax
80104a50:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a53:	75 28                	jne    80104a7d <exit+0xfb>
      p->parent = initproc;
80104a55:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a64:	8b 40 0c             	mov    0xc(%eax),%eax
80104a67:	83 f8 05             	cmp    $0x5,%eax
80104a6a:	75 11                	jne    80104a7d <exit+0xfb>
        wakeup1(initproc);
80104a6c:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	50                   	push   %eax
80104a75:	e8 fc 03 00 00       	call   80104e76 <wakeup1>
80104a7a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a7d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a81:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104a88:	72 c0                	jb     80104a4a <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a94:	e8 ed 01 00 00       	call   80104c86 <sched>
  panic("zombie exit");
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	68 69 90 10 80       	push   $0x80109069
80104aa1:	e8 62 bb ff ff       	call   80100608 <panic>

80104aa6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104aa6:	f3 0f 1e fb          	endbr32 
80104aaa:	55                   	push   %ebp
80104aab:	89 e5                	mov    %esp,%ebp
80104aad:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104ab0:	e8 e2 f9 ff ff       	call   80104497 <myproc>
80104ab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104ab8:	83 ec 0c             	sub    $0xc,%esp
80104abb:	68 c0 4d 11 80       	push   $0x80114dc0
80104ac0:	e8 6f 07 00 00       	call   80105234 <acquire>
80104ac5:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104ac8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104acf:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ad6:	e9 a1 00 00 00       	jmp    80104b7c <wait+0xd6>
      if(p->parent != curproc)
80104adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ade:	8b 40 14             	mov    0x14(%eax),%eax
80104ae1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ae4:	0f 85 8d 00 00 00    	jne    80104b77 <wait+0xd1>
        continue;
      havekids = 1;
80104aea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	8b 40 0c             	mov    0xc(%eax),%eax
80104af7:	83 f8 05             	cmp    $0x5,%eax
80104afa:	75 7c                	jne    80104b78 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aff:	8b 40 10             	mov    0x10(%eax),%eax
80104b02:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b08:	8b 40 08             	mov    0x8(%eax),%eax
80104b0b:	83 ec 0c             	sub    $0xc,%esp
80104b0e:	50                   	push   %eax
80104b0f:	e8 47 e2 ff ff       	call   80102d5b <kfree>
80104b14:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b24:	8b 40 04             	mov    0x4(%eax),%eax
80104b27:	83 ec 0c             	sub    $0xc,%esp
80104b2a:	50                   	push   %eax
80104b2b:	e8 6c 3a 00 00       	call   8010859c <freevm>
80104b30:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b40:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b51:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104b62:	83 ec 0c             	sub    $0xc,%esp
80104b65:	68 c0 4d 11 80       	push   $0x80114dc0
80104b6a:	e8 37 07 00 00       	call   801052a6 <release>
80104b6f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b75:	eb 51                	jmp    80104bc8 <wait+0x122>
        continue;
80104b77:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b78:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b7c:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104b83:	0f 82 52 ff ff ff    	jb     80104adb <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b8d:	74 0a                	je     80104b99 <wait+0xf3>
80104b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b92:	8b 40 24             	mov    0x24(%eax),%eax
80104b95:	85 c0                	test   %eax,%eax
80104b97:	74 17                	je     80104bb0 <wait+0x10a>
      release(&ptable.lock);
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	68 c0 4d 11 80       	push   $0x80114dc0
80104ba1:	e8 00 07 00 00       	call   801052a6 <release>
80104ba6:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bae:	eb 18                	jmp    80104bc8 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104bb0:	83 ec 08             	sub    $0x8,%esp
80104bb3:	68 c0 4d 11 80       	push   $0x80114dc0
80104bb8:	ff 75 ec             	pushl  -0x14(%ebp)
80104bbb:	e8 0b 02 00 00       	call   80104dcb <sleep>
80104bc0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104bc3:	e9 00 ff ff ff       	jmp    80104ac8 <wait+0x22>
  }
}
80104bc8:	c9                   	leave  
80104bc9:	c3                   	ret    

80104bca <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bca:	f3 0f 1e fb          	endbr32 
80104bce:	55                   	push   %ebp
80104bcf:	89 e5                	mov    %esp,%ebp
80104bd1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104bd4:	e8 42 f8 ff ff       	call   8010441b <mycpu>
80104bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bdf:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104be6:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104be9:	e8 e5 f7 ff ff       	call   801043d3 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104bee:	83 ec 0c             	sub    $0xc,%esp
80104bf1:	68 c0 4d 11 80       	push   $0x80114dc0
80104bf6:	e8 39 06 00 00       	call   80105234 <acquire>
80104bfb:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bfe:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c05:	eb 61                	jmp    80104c68 <scheduler+0x9e>
      if(p->state != RUNNABLE)
80104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c0d:	83 f8 03             	cmp    $0x3,%eax
80104c10:	75 51                	jne    80104c63 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c18:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c1e:	83 ec 0c             	sub    $0xc,%esp
80104c21:	ff 75 f4             	pushl  -0xc(%ebp)
80104c24:	e8 b8 34 00 00       	call   801080e1 <switchuvm>
80104c29:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c39:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c3f:	83 c2 04             	add    $0x4,%edx
80104c42:	83 ec 08             	sub    $0x8,%esp
80104c45:	50                   	push   %eax
80104c46:	52                   	push   %edx
80104c47:	e8 1b 0b 00 00       	call   80105767 <swtch>
80104c4c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c4f:	e8 70 34 00 00       	call   801080c4 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c57:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c5e:	00 00 00 
80104c61:	eb 01                	jmp    80104c64 <scheduler+0x9a>
        continue;
80104c63:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c64:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c68:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104c6f:	72 96                	jb     80104c07 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104c71:	83 ec 0c             	sub    $0xc,%esp
80104c74:	68 c0 4d 11 80       	push   $0x80114dc0
80104c79:	e8 28 06 00 00       	call   801052a6 <release>
80104c7e:	83 c4 10             	add    $0x10,%esp
    sti();
80104c81:	e9 63 ff ff ff       	jmp    80104be9 <scheduler+0x1f>

80104c86 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104c86:	f3 0f 1e fb          	endbr32 
80104c8a:	55                   	push   %ebp
80104c8b:	89 e5                	mov    %esp,%ebp
80104c8d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104c90:	e8 02 f8 ff ff       	call   80104497 <myproc>
80104c95:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104c98:	83 ec 0c             	sub    $0xc,%esp
80104c9b:	68 c0 4d 11 80       	push   $0x80114dc0
80104ca0:	e8 d6 06 00 00       	call   8010537b <holding>
80104ca5:	83 c4 10             	add    $0x10,%esp
80104ca8:	85 c0                	test   %eax,%eax
80104caa:	75 0d                	jne    80104cb9 <sched+0x33>
    panic("sched ptable.lock");
80104cac:	83 ec 0c             	sub    $0xc,%esp
80104caf:	68 75 90 10 80       	push   $0x80109075
80104cb4:	e8 4f b9 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104cb9:	e8 5d f7 ff ff       	call   8010441b <mycpu>
80104cbe:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cc4:	83 f8 01             	cmp    $0x1,%eax
80104cc7:	74 0d                	je     80104cd6 <sched+0x50>
    panic("sched locks");
80104cc9:	83 ec 0c             	sub    $0xc,%esp
80104ccc:	68 87 90 10 80       	push   $0x80109087
80104cd1:	e8 32 b9 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd9:	8b 40 0c             	mov    0xc(%eax),%eax
80104cdc:	83 f8 04             	cmp    $0x4,%eax
80104cdf:	75 0d                	jne    80104cee <sched+0x68>
    panic("sched running");
80104ce1:	83 ec 0c             	sub    $0xc,%esp
80104ce4:	68 93 90 10 80       	push   $0x80109093
80104ce9:	e8 1a b9 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104cee:	e8 d0 f6 ff ff       	call   801043c3 <readeflags>
80104cf3:	25 00 02 00 00       	and    $0x200,%eax
80104cf8:	85 c0                	test   %eax,%eax
80104cfa:	74 0d                	je     80104d09 <sched+0x83>
    panic("sched interruptible");
80104cfc:	83 ec 0c             	sub    $0xc,%esp
80104cff:	68 a1 90 10 80       	push   $0x801090a1
80104d04:	e8 ff b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d09:	e8 0d f7 ff ff       	call   8010441b <mycpu>
80104d0e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d17:	e8 ff f6 ff ff       	call   8010441b <mycpu>
80104d1c:	8b 40 04             	mov    0x4(%eax),%eax
80104d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d22:	83 c2 1c             	add    $0x1c,%edx
80104d25:	83 ec 08             	sub    $0x8,%esp
80104d28:	50                   	push   %eax
80104d29:	52                   	push   %edx
80104d2a:	e8 38 0a 00 00       	call   80105767 <swtch>
80104d2f:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104d32:	e8 e4 f6 ff ff       	call   8010441b <mycpu>
80104d37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d3a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d40:	90                   	nop
80104d41:	c9                   	leave  
80104d42:	c3                   	ret    

80104d43 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d43:	f3 0f 1e fb          	endbr32 
80104d47:	55                   	push   %ebp
80104d48:	89 e5                	mov    %esp,%ebp
80104d4a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d4d:	83 ec 0c             	sub    $0xc,%esp
80104d50:	68 c0 4d 11 80       	push   $0x80114dc0
80104d55:	e8 da 04 00 00       	call   80105234 <acquire>
80104d5a:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104d5d:	e8 35 f7 ff ff       	call   80104497 <myproc>
80104d62:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d69:	e8 18 ff ff ff       	call   80104c86 <sched>
  release(&ptable.lock);
80104d6e:	83 ec 0c             	sub    $0xc,%esp
80104d71:	68 c0 4d 11 80       	push   $0x80114dc0
80104d76:	e8 2b 05 00 00       	call   801052a6 <release>
80104d7b:	83 c4 10             	add    $0x10,%esp
}
80104d7e:	90                   	nop
80104d7f:	c9                   	leave  
80104d80:	c3                   	ret    

80104d81 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d81:	f3 0f 1e fb          	endbr32 
80104d85:	55                   	push   %ebp
80104d86:	89 e5                	mov    %esp,%ebp
80104d88:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d8b:	83 ec 0c             	sub    $0xc,%esp
80104d8e:	68 c0 4d 11 80       	push   $0x80114dc0
80104d93:	e8 0e 05 00 00       	call   801052a6 <release>
80104d98:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d9b:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104da0:	85 c0                	test   %eax,%eax
80104da2:	74 24                	je     80104dc8 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104da4:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104dab:	00 00 00 
    iinit(ROOTDEV);
80104dae:	83 ec 0c             	sub    $0xc,%esp
80104db1:	6a 01                	push   $0x1
80104db3:	e8 cb c9 ff ff       	call   80101783 <iinit>
80104db8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104dbb:	83 ec 0c             	sub    $0xc,%esp
80104dbe:	6a 01                	push   $0x1
80104dc0:	e8 e0 e6 ff ff       	call   801034a5 <initlog>
80104dc5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104dc8:	90                   	nop
80104dc9:	c9                   	leave  
80104dca:	c3                   	ret    

80104dcb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104dcb:	f3 0f 1e fb          	endbr32 
80104dcf:	55                   	push   %ebp
80104dd0:	89 e5                	mov    %esp,%ebp
80104dd2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104dd5:	e8 bd f6 ff ff       	call   80104497 <myproc>
80104dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104ddd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104de1:	75 0d                	jne    80104df0 <sleep+0x25>
    panic("sleep");
80104de3:	83 ec 0c             	sub    $0xc,%esp
80104de6:	68 b5 90 10 80       	push   $0x801090b5
80104deb:	e8 18 b8 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104df0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104df4:	75 0d                	jne    80104e03 <sleep+0x38>
    panic("sleep without lk");
80104df6:	83 ec 0c             	sub    $0xc,%esp
80104df9:	68 bb 90 10 80       	push   $0x801090bb
80104dfe:	e8 05 b8 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e03:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e0a:	74 1e                	je     80104e2a <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e0c:	83 ec 0c             	sub    $0xc,%esp
80104e0f:	68 c0 4d 11 80       	push   $0x80114dc0
80104e14:	e8 1b 04 00 00       	call   80105234 <acquire>
80104e19:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e1c:	83 ec 0c             	sub    $0xc,%esp
80104e1f:	ff 75 0c             	pushl  0xc(%ebp)
80104e22:	e8 7f 04 00 00       	call   801052a6 <release>
80104e27:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2d:	8b 55 08             	mov    0x8(%ebp),%edx
80104e30:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e36:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104e3d:	e8 44 fe ff ff       	call   80104c86 <sched>

  // Tidy up.
  p->chan = 0;
80104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e45:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e4c:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e53:	74 1e                	je     80104e73 <sleep+0xa8>
    release(&ptable.lock);
80104e55:	83 ec 0c             	sub    $0xc,%esp
80104e58:	68 c0 4d 11 80       	push   $0x80114dc0
80104e5d:	e8 44 04 00 00       	call   801052a6 <release>
80104e62:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	ff 75 0c             	pushl  0xc(%ebp)
80104e6b:	e8 c4 03 00 00       	call   80105234 <acquire>
80104e70:	83 c4 10             	add    $0x10,%esp
  }
}
80104e73:	90                   	nop
80104e74:	c9                   	leave  
80104e75:	c3                   	ret    

80104e76 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e76:	f3 0f 1e fb          	endbr32 
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
80104e7d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e80:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104e87:	eb 24                	jmp    80104ead <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8f:	83 f8 02             	cmp    $0x2,%eax
80104e92:	75 15                	jne    80104ea9 <wakeup1+0x33>
80104e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e97:	8b 40 20             	mov    0x20(%eax),%eax
80104e9a:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e9d:	75 0a                	jne    80104ea9 <wakeup1+0x33>
      p->state = RUNNABLE;
80104e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea9:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104ead:	81 7d fc f4 6c 11 80 	cmpl   $0x80116cf4,-0x4(%ebp)
80104eb4:	72 d3                	jb     80104e89 <wakeup1+0x13>
}
80104eb6:	90                   	nop
80104eb7:	90                   	nop
80104eb8:	c9                   	leave  
80104eb9:	c3                   	ret    

80104eba <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104eba:	f3 0f 1e fb          	endbr32 
80104ebe:	55                   	push   %ebp
80104ebf:	89 e5                	mov    %esp,%ebp
80104ec1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ec4:	83 ec 0c             	sub    $0xc,%esp
80104ec7:	68 c0 4d 11 80       	push   $0x80114dc0
80104ecc:	e8 63 03 00 00       	call   80105234 <acquire>
80104ed1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104ed4:	83 ec 0c             	sub    $0xc,%esp
80104ed7:	ff 75 08             	pushl  0x8(%ebp)
80104eda:	e8 97 ff ff ff       	call   80104e76 <wakeup1>
80104edf:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104ee2:	83 ec 0c             	sub    $0xc,%esp
80104ee5:	68 c0 4d 11 80       	push   $0x80114dc0
80104eea:	e8 b7 03 00 00       	call   801052a6 <release>
80104eef:	83 c4 10             	add    $0x10,%esp
}
80104ef2:	90                   	nop
80104ef3:	c9                   	leave  
80104ef4:	c3                   	ret    

80104ef5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ef5:	f3 0f 1e fb          	endbr32 
80104ef9:	55                   	push   %ebp
80104efa:	89 e5                	mov    %esp,%ebp
80104efc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104eff:	83 ec 0c             	sub    $0xc,%esp
80104f02:	68 c0 4d 11 80       	push   $0x80114dc0
80104f07:	e8 28 03 00 00       	call   80105234 <acquire>
80104f0c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f0f:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f16:	eb 45                	jmp    80104f5d <kill+0x68>
    if(p->pid == pid){
80104f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1b:	8b 40 10             	mov    0x10(%eax),%eax
80104f1e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f21:	75 36                	jne    80104f59 <kill+0x64>
      p->killed = 1;
80104f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f26:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f30:	8b 40 0c             	mov    0xc(%eax),%eax
80104f33:	83 f8 02             	cmp    $0x2,%eax
80104f36:	75 0a                	jne    80104f42 <kill+0x4d>
        p->state = RUNNABLE;
80104f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f42:	83 ec 0c             	sub    $0xc,%esp
80104f45:	68 c0 4d 11 80       	push   $0x80114dc0
80104f4a:	e8 57 03 00 00       	call   801052a6 <release>
80104f4f:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f52:	b8 00 00 00 00       	mov    $0x0,%eax
80104f57:	eb 22                	jmp    80104f7b <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f59:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f5d:	81 7d f4 f4 6c 11 80 	cmpl   $0x80116cf4,-0xc(%ebp)
80104f64:	72 b2                	jb     80104f18 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104f66:	83 ec 0c             	sub    $0xc,%esp
80104f69:	68 c0 4d 11 80       	push   $0x80114dc0
80104f6e:	e8 33 03 00 00       	call   801052a6 <release>
80104f73:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f7b:	c9                   	leave  
80104f7c:	c3                   	ret    

80104f7d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f7d:	f3 0f 1e fb          	endbr32 
80104f81:	55                   	push   %ebp
80104f82:	89 e5                	mov    %esp,%ebp
80104f84:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f87:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80104f8e:	e9 d7 00 00 00       	jmp    8010506a <procdump+0xed>
    if(p->state == UNUSED)
80104f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f96:	8b 40 0c             	mov    0xc(%eax),%eax
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	0f 84 c4 00 00 00    	je     80105065 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa4:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa7:	83 f8 05             	cmp    $0x5,%eax
80104faa:	77 23                	ja     80104fcf <procdump+0x52>
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb2:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104fb9:	85 c0                	test   %eax,%eax
80104fbb:	74 12                	je     80104fcf <procdump+0x52>
      state = states[p->state];
80104fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc0:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104fca:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fcd:	eb 07                	jmp    80104fd6 <procdump+0x59>
    else
      state = "???";
80104fcf:	c7 45 ec cc 90 10 80 	movl   $0x801090cc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd9:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdf:	8b 40 10             	mov    0x10(%eax),%eax
80104fe2:	52                   	push   %edx
80104fe3:	ff 75 ec             	pushl  -0x14(%ebp)
80104fe6:	50                   	push   %eax
80104fe7:	68 d0 90 10 80       	push   $0x801090d0
80104fec:	e8 27 b4 ff ff       	call   80100418 <cprintf>
80104ff1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff7:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffa:	83 f8 02             	cmp    $0x2,%eax
80104ffd:	75 54                	jne    80105053 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105002:	8b 40 1c             	mov    0x1c(%eax),%eax
80105005:	8b 40 0c             	mov    0xc(%eax),%eax
80105008:	83 c0 08             	add    $0x8,%eax
8010500b:	89 c2                	mov    %eax,%edx
8010500d:	83 ec 08             	sub    $0x8,%esp
80105010:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105013:	50                   	push   %eax
80105014:	52                   	push   %edx
80105015:	e8 e2 02 00 00       	call   801052fc <getcallerpcs>
8010501a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010501d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105024:	eb 1c                	jmp    80105042 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80105026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105029:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010502d:	83 ec 08             	sub    $0x8,%esp
80105030:	50                   	push   %eax
80105031:	68 d9 90 10 80       	push   $0x801090d9
80105036:	e8 dd b3 ff ff       	call   80100418 <cprintf>
8010503b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010503e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105042:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105046:	7f 0b                	jg     80105053 <procdump+0xd6>
80105048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010504f:	85 c0                	test   %eax,%eax
80105051:	75 d3                	jne    80105026 <procdump+0xa9>
    }
    cprintf("\n");
80105053:	83 ec 0c             	sub    $0xc,%esp
80105056:	68 dd 90 10 80       	push   $0x801090dd
8010505b:	e8 b8 b3 ff ff       	call   80100418 <cprintf>
80105060:	83 c4 10             	add    $0x10,%esp
80105063:	eb 01                	jmp    80105066 <procdump+0xe9>
      continue;
80105065:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105066:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010506a:	81 7d f0 f4 6c 11 80 	cmpl   $0x80116cf4,-0x10(%ebp)
80105071:	0f 82 1c ff ff ff    	jb     80104f93 <procdump+0x16>
  }
}
80105077:	90                   	nop
80105078:	90                   	nop
80105079:	c9                   	leave  
8010507a:	c3                   	ret    

8010507b <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010507b:	f3 0f 1e fb          	endbr32 
8010507f:	55                   	push   %ebp
80105080:	89 e5                	mov    %esp,%ebp
80105082:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105085:	8b 45 08             	mov    0x8(%ebp),%eax
80105088:	83 c0 04             	add    $0x4,%eax
8010508b:	83 ec 08             	sub    $0x8,%esp
8010508e:	68 09 91 10 80       	push   $0x80109109
80105093:	50                   	push   %eax
80105094:	e8 75 01 00 00       	call   8010520e <initlock>
80105099:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010509c:	8b 45 08             	mov    0x8(%ebp),%eax
8010509f:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a2:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801050a5:	8b 45 08             	mov    0x8(%ebp),%eax
801050a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801050b8:	90                   	nop
801050b9:	c9                   	leave  
801050ba:	c3                   	ret    

801050bb <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801050bb:	f3 0f 1e fb          	endbr32 
801050bf:	55                   	push   %ebp
801050c0:	89 e5                	mov    %esp,%ebp
801050c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801050c5:	8b 45 08             	mov    0x8(%ebp),%eax
801050c8:	83 c0 04             	add    $0x4,%eax
801050cb:	83 ec 0c             	sub    $0xc,%esp
801050ce:	50                   	push   %eax
801050cf:	e8 60 01 00 00       	call   80105234 <acquire>
801050d4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050d7:	eb 15                	jmp    801050ee <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801050d9:	8b 45 08             	mov    0x8(%ebp),%eax
801050dc:	83 c0 04             	add    $0x4,%eax
801050df:	83 ec 08             	sub    $0x8,%esp
801050e2:	50                   	push   %eax
801050e3:	ff 75 08             	pushl  0x8(%ebp)
801050e6:	e8 e0 fc ff ff       	call   80104dcb <sleep>
801050eb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050ee:	8b 45 08             	mov    0x8(%ebp),%eax
801050f1:	8b 00                	mov    (%eax),%eax
801050f3:	85 c0                	test   %eax,%eax
801050f5:	75 e2                	jne    801050d9 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801050f7:	8b 45 08             	mov    0x8(%ebp),%eax
801050fa:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105100:	e8 92 f3 ff ff       	call   80104497 <myproc>
80105105:	8b 50 10             	mov    0x10(%eax),%edx
80105108:	8b 45 08             	mov    0x8(%ebp),%eax
8010510b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010510e:	8b 45 08             	mov    0x8(%ebp),%eax
80105111:	83 c0 04             	add    $0x4,%eax
80105114:	83 ec 0c             	sub    $0xc,%esp
80105117:	50                   	push   %eax
80105118:	e8 89 01 00 00       	call   801052a6 <release>
8010511d:	83 c4 10             	add    $0x10,%esp
}
80105120:	90                   	nop
80105121:	c9                   	leave  
80105122:	c3                   	ret    

80105123 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105123:	f3 0f 1e fb          	endbr32 
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
8010512a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010512d:	8b 45 08             	mov    0x8(%ebp),%eax
80105130:	83 c0 04             	add    $0x4,%eax
80105133:	83 ec 0c             	sub    $0xc,%esp
80105136:	50                   	push   %eax
80105137:	e8 f8 00 00 00       	call   80105234 <acquire>
8010513c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010513f:	8b 45 08             	mov    0x8(%ebp),%eax
80105142:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105148:	8b 45 08             	mov    0x8(%ebp),%eax
8010514b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105152:	83 ec 0c             	sub    $0xc,%esp
80105155:	ff 75 08             	pushl  0x8(%ebp)
80105158:	e8 5d fd ff ff       	call   80104eba <wakeup>
8010515d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105160:	8b 45 08             	mov    0x8(%ebp),%eax
80105163:	83 c0 04             	add    $0x4,%eax
80105166:	83 ec 0c             	sub    $0xc,%esp
80105169:	50                   	push   %eax
8010516a:	e8 37 01 00 00       	call   801052a6 <release>
8010516f:	83 c4 10             	add    $0x10,%esp
}
80105172:	90                   	nop
80105173:	c9                   	leave  
80105174:	c3                   	ret    

80105175 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105175:	f3 0f 1e fb          	endbr32 
80105179:	55                   	push   %ebp
8010517a:	89 e5                	mov    %esp,%ebp
8010517c:	53                   	push   %ebx
8010517d:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105180:	8b 45 08             	mov    0x8(%ebp),%eax
80105183:	83 c0 04             	add    $0x4,%eax
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	50                   	push   %eax
8010518a:	e8 a5 00 00 00       	call   80105234 <acquire>
8010518f:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
80105195:	8b 00                	mov    (%eax),%eax
80105197:	85 c0                	test   %eax,%eax
80105199:	74 19                	je     801051b4 <holdingsleep+0x3f>
8010519b:	8b 45 08             	mov    0x8(%ebp),%eax
8010519e:	8b 58 3c             	mov    0x3c(%eax),%ebx
801051a1:	e8 f1 f2 ff ff       	call   80104497 <myproc>
801051a6:	8b 40 10             	mov    0x10(%eax),%eax
801051a9:	39 c3                	cmp    %eax,%ebx
801051ab:	75 07                	jne    801051b4 <holdingsleep+0x3f>
801051ad:	b8 01 00 00 00       	mov    $0x1,%eax
801051b2:	eb 05                	jmp    801051b9 <holdingsleep+0x44>
801051b4:	b8 00 00 00 00       	mov    $0x0,%eax
801051b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801051bc:	8b 45 08             	mov    0x8(%ebp),%eax
801051bf:	83 c0 04             	add    $0x4,%eax
801051c2:	83 ec 0c             	sub    $0xc,%esp
801051c5:	50                   	push   %eax
801051c6:	e8 db 00 00 00       	call   801052a6 <release>
801051cb:	83 c4 10             	add    $0x10,%esp
  return r;
801051ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801051d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051d4:	c9                   	leave  
801051d5:	c3                   	ret    

801051d6 <readeflags>:
{
801051d6:	55                   	push   %ebp
801051d7:	89 e5                	mov    %esp,%ebp
801051d9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801051dc:	9c                   	pushf  
801051dd:	58                   	pop    %eax
801051de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801051e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051e4:	c9                   	leave  
801051e5:	c3                   	ret    

801051e6 <cli>:
{
801051e6:	55                   	push   %ebp
801051e7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801051e9:	fa                   	cli    
}
801051ea:	90                   	nop
801051eb:	5d                   	pop    %ebp
801051ec:	c3                   	ret    

801051ed <sti>:
{
801051ed:	55                   	push   %ebp
801051ee:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801051f0:	fb                   	sti    
}
801051f1:	90                   	nop
801051f2:	5d                   	pop    %ebp
801051f3:	c3                   	ret    

801051f4 <xchg>:
{
801051f4:	55                   	push   %ebp
801051f5:	89 e5                	mov    %esp,%ebp
801051f7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801051fa:	8b 55 08             	mov    0x8(%ebp),%edx
801051fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105200:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105203:	f0 87 02             	lock xchg %eax,(%edx)
80105206:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105209:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010520c:	c9                   	leave  
8010520d:	c3                   	ret    

8010520e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010520e:	f3 0f 1e fb          	endbr32 
80105212:	55                   	push   %ebp
80105213:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	8b 55 0c             	mov    0xc(%ebp),%edx
8010521b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010521e:	8b 45 08             	mov    0x8(%ebp),%eax
80105221:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105227:	8b 45 08             	mov    0x8(%ebp),%eax
8010522a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105231:	90                   	nop
80105232:	5d                   	pop    %ebp
80105233:	c3                   	ret    

80105234 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105234:	f3 0f 1e fb          	endbr32 
80105238:	55                   	push   %ebp
80105239:	89 e5                	mov    %esp,%ebp
8010523b:	53                   	push   %ebx
8010523c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010523f:	e8 7c 01 00 00       	call   801053c0 <pushcli>
  if(holding(lk))
80105244:	8b 45 08             	mov    0x8(%ebp),%eax
80105247:	83 ec 0c             	sub    $0xc,%esp
8010524a:	50                   	push   %eax
8010524b:	e8 2b 01 00 00       	call   8010537b <holding>
80105250:	83 c4 10             	add    $0x10,%esp
80105253:	85 c0                	test   %eax,%eax
80105255:	74 0d                	je     80105264 <acquire+0x30>
    panic("acquire");
80105257:	83 ec 0c             	sub    $0xc,%esp
8010525a:	68 14 91 10 80       	push   $0x80109114
8010525f:	e8 a4 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105264:	90                   	nop
80105265:	8b 45 08             	mov    0x8(%ebp),%eax
80105268:	83 ec 08             	sub    $0x8,%esp
8010526b:	6a 01                	push   $0x1
8010526d:	50                   	push   %eax
8010526e:	e8 81 ff ff ff       	call   801051f4 <xchg>
80105273:	83 c4 10             	add    $0x10,%esp
80105276:	85 c0                	test   %eax,%eax
80105278:	75 eb                	jne    80105265 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010527a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010527f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105282:	e8 94 f1 ff ff       	call   8010441b <mycpu>
80105287:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010528a:	8b 45 08             	mov    0x8(%ebp),%eax
8010528d:	83 c0 0c             	add    $0xc,%eax
80105290:	83 ec 08             	sub    $0x8,%esp
80105293:	50                   	push   %eax
80105294:	8d 45 08             	lea    0x8(%ebp),%eax
80105297:	50                   	push   %eax
80105298:	e8 5f 00 00 00       	call   801052fc <getcallerpcs>
8010529d:	83 c4 10             	add    $0x10,%esp
}
801052a0:	90                   	nop
801052a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052a4:	c9                   	leave  
801052a5:	c3                   	ret    

801052a6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801052a6:	f3 0f 1e fb          	endbr32 
801052aa:	55                   	push   %ebp
801052ab:	89 e5                	mov    %esp,%ebp
801052ad:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801052b0:	83 ec 0c             	sub    $0xc,%esp
801052b3:	ff 75 08             	pushl  0x8(%ebp)
801052b6:	e8 c0 00 00 00       	call   8010537b <holding>
801052bb:	83 c4 10             	add    $0x10,%esp
801052be:	85 c0                	test   %eax,%eax
801052c0:	75 0d                	jne    801052cf <release+0x29>
    panic("release");
801052c2:	83 ec 0c             	sub    $0xc,%esp
801052c5:	68 1c 91 10 80       	push   $0x8010911c
801052ca:	e8 39 b3 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
801052cf:	8b 45 08             	mov    0x8(%ebp),%eax
801052d2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801052d9:	8b 45 08             	mov    0x8(%ebp),%eax
801052dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801052e3:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801052e8:	8b 45 08             	mov    0x8(%ebp),%eax
801052eb:	8b 55 08             	mov    0x8(%ebp),%edx
801052ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801052f4:	e8 18 01 00 00       	call   80105411 <popcli>
}
801052f9:	90                   	nop
801052fa:	c9                   	leave  
801052fb:	c3                   	ret    

801052fc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801052fc:	f3 0f 1e fb          	endbr32 
80105300:	55                   	push   %ebp
80105301:	89 e5                	mov    %esp,%ebp
80105303:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105306:	8b 45 08             	mov    0x8(%ebp),%eax
80105309:	83 e8 08             	sub    $0x8,%eax
8010530c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010530f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105316:	eb 38                	jmp    80105350 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105318:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010531c:	74 53                	je     80105371 <getcallerpcs+0x75>
8010531e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105325:	76 4a                	jbe    80105371 <getcallerpcs+0x75>
80105327:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010532b:	74 44                	je     80105371 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010532d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105330:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	01 c2                	add    %eax,%edx
8010533c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533f:	8b 40 04             	mov    0x4(%eax),%eax
80105342:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105344:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105347:	8b 00                	mov    (%eax),%eax
80105349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010534c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105350:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105354:	7e c2                	jle    80105318 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105356:	eb 19                	jmp    80105371 <getcallerpcs+0x75>
    pcs[i] = 0;
80105358:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105362:	8b 45 0c             	mov    0xc(%ebp),%eax
80105365:	01 d0                	add    %edx,%eax
80105367:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010536d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105371:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105375:	7e e1                	jle    80105358 <getcallerpcs+0x5c>
}
80105377:	90                   	nop
80105378:	90                   	nop
80105379:	c9                   	leave  
8010537a:	c3                   	ret    

8010537b <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010537b:	f3 0f 1e fb          	endbr32 
8010537f:	55                   	push   %ebp
80105380:	89 e5                	mov    %esp,%ebp
80105382:	53                   	push   %ebx
80105383:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105386:	e8 35 00 00 00       	call   801053c0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010538b:	8b 45 08             	mov    0x8(%ebp),%eax
8010538e:	8b 00                	mov    (%eax),%eax
80105390:	85 c0                	test   %eax,%eax
80105392:	74 16                	je     801053aa <holding+0x2f>
80105394:	8b 45 08             	mov    0x8(%ebp),%eax
80105397:	8b 58 08             	mov    0x8(%eax),%ebx
8010539a:	e8 7c f0 ff ff       	call   8010441b <mycpu>
8010539f:	39 c3                	cmp    %eax,%ebx
801053a1:	75 07                	jne    801053aa <holding+0x2f>
801053a3:	b8 01 00 00 00       	mov    $0x1,%eax
801053a8:	eb 05                	jmp    801053af <holding+0x34>
801053aa:	b8 00 00 00 00       	mov    $0x0,%eax
801053af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801053b2:	e8 5a 00 00 00       	call   80105411 <popcli>
  return r;
801053b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053ba:	83 c4 14             	add    $0x14,%esp
801053bd:	5b                   	pop    %ebx
801053be:	5d                   	pop    %ebp
801053bf:	c3                   	ret    

801053c0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801053c0:	f3 0f 1e fb          	endbr32 
801053c4:	55                   	push   %ebp
801053c5:	89 e5                	mov    %esp,%ebp
801053c7:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801053ca:	e8 07 fe ff ff       	call   801051d6 <readeflags>
801053cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801053d2:	e8 0f fe ff ff       	call   801051e6 <cli>
  if(mycpu()->ncli == 0)
801053d7:	e8 3f f0 ff ff       	call   8010441b <mycpu>
801053dc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053e2:	85 c0                	test   %eax,%eax
801053e4:	75 14                	jne    801053fa <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801053e6:	e8 30 f0 ff ff       	call   8010441b <mycpu>
801053eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053ee:	81 e2 00 02 00 00    	and    $0x200,%edx
801053f4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801053fa:	e8 1c f0 ff ff       	call   8010441b <mycpu>
801053ff:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105405:	83 c2 01             	add    $0x1,%edx
80105408:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010540e:	90                   	nop
8010540f:	c9                   	leave  
80105410:	c3                   	ret    

80105411 <popcli>:

void
popcli(void)
{
80105411:	f3 0f 1e fb          	endbr32 
80105415:	55                   	push   %ebp
80105416:	89 e5                	mov    %esp,%ebp
80105418:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010541b:	e8 b6 fd ff ff       	call   801051d6 <readeflags>
80105420:	25 00 02 00 00       	and    $0x200,%eax
80105425:	85 c0                	test   %eax,%eax
80105427:	74 0d                	je     80105436 <popcli+0x25>
    panic("popcli - interruptible");
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	68 24 91 10 80       	push   $0x80109124
80105431:	e8 d2 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
80105436:	e8 e0 ef ff ff       	call   8010441b <mycpu>
8010543b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105441:	83 ea 01             	sub    $0x1,%edx
80105444:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010544a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105450:	85 c0                	test   %eax,%eax
80105452:	79 0d                	jns    80105461 <popcli+0x50>
    panic("popcli");
80105454:	83 ec 0c             	sub    $0xc,%esp
80105457:	68 3b 91 10 80       	push   $0x8010913b
8010545c:	e8 a7 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105461:	e8 b5 ef ff ff       	call   8010441b <mycpu>
80105466:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010546c:	85 c0                	test   %eax,%eax
8010546e:	75 14                	jne    80105484 <popcli+0x73>
80105470:	e8 a6 ef ff ff       	call   8010441b <mycpu>
80105475:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010547b:	85 c0                	test   %eax,%eax
8010547d:	74 05                	je     80105484 <popcli+0x73>
    sti();
8010547f:	e8 69 fd ff ff       	call   801051ed <sti>
}
80105484:	90                   	nop
80105485:	c9                   	leave  
80105486:	c3                   	ret    

80105487 <stosb>:
{
80105487:	55                   	push   %ebp
80105488:	89 e5                	mov    %esp,%ebp
8010548a:	57                   	push   %edi
8010548b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010548c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010548f:	8b 55 10             	mov    0x10(%ebp),%edx
80105492:	8b 45 0c             	mov    0xc(%ebp),%eax
80105495:	89 cb                	mov    %ecx,%ebx
80105497:	89 df                	mov    %ebx,%edi
80105499:	89 d1                	mov    %edx,%ecx
8010549b:	fc                   	cld    
8010549c:	f3 aa                	rep stos %al,%es:(%edi)
8010549e:	89 ca                	mov    %ecx,%edx
801054a0:	89 fb                	mov    %edi,%ebx
801054a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054a5:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054a8:	90                   	nop
801054a9:	5b                   	pop    %ebx
801054aa:	5f                   	pop    %edi
801054ab:	5d                   	pop    %ebp
801054ac:	c3                   	ret    

801054ad <stosl>:
{
801054ad:	55                   	push   %ebp
801054ae:	89 e5                	mov    %esp,%ebp
801054b0:	57                   	push   %edi
801054b1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054b5:	8b 55 10             	mov    0x10(%ebp),%edx
801054b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bb:	89 cb                	mov    %ecx,%ebx
801054bd:	89 df                	mov    %ebx,%edi
801054bf:	89 d1                	mov    %edx,%ecx
801054c1:	fc                   	cld    
801054c2:	f3 ab                	rep stos %eax,%es:(%edi)
801054c4:	89 ca                	mov    %ecx,%edx
801054c6:	89 fb                	mov    %edi,%ebx
801054c8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054cb:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054ce:	90                   	nop
801054cf:	5b                   	pop    %ebx
801054d0:	5f                   	pop    %edi
801054d1:	5d                   	pop    %ebp
801054d2:	c3                   	ret    

801054d3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054d3:	f3 0f 1e fb          	endbr32 
801054d7:	55                   	push   %ebp
801054d8:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801054da:	8b 45 08             	mov    0x8(%ebp),%eax
801054dd:	83 e0 03             	and    $0x3,%eax
801054e0:	85 c0                	test   %eax,%eax
801054e2:	75 43                	jne    80105527 <memset+0x54>
801054e4:	8b 45 10             	mov    0x10(%ebp),%eax
801054e7:	83 e0 03             	and    $0x3,%eax
801054ea:	85 c0                	test   %eax,%eax
801054ec:	75 39                	jne    80105527 <memset+0x54>
    c &= 0xFF;
801054ee:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801054f5:	8b 45 10             	mov    0x10(%ebp),%eax
801054f8:	c1 e8 02             	shr    $0x2,%eax
801054fb:	89 c1                	mov    %eax,%ecx
801054fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105500:	c1 e0 18             	shl    $0x18,%eax
80105503:	89 c2                	mov    %eax,%edx
80105505:	8b 45 0c             	mov    0xc(%ebp),%eax
80105508:	c1 e0 10             	shl    $0x10,%eax
8010550b:	09 c2                	or     %eax,%edx
8010550d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105510:	c1 e0 08             	shl    $0x8,%eax
80105513:	09 d0                	or     %edx,%eax
80105515:	0b 45 0c             	or     0xc(%ebp),%eax
80105518:	51                   	push   %ecx
80105519:	50                   	push   %eax
8010551a:	ff 75 08             	pushl  0x8(%ebp)
8010551d:	e8 8b ff ff ff       	call   801054ad <stosl>
80105522:	83 c4 0c             	add    $0xc,%esp
80105525:	eb 12                	jmp    80105539 <memset+0x66>
  } else
    stosb(dst, c, n);
80105527:	8b 45 10             	mov    0x10(%ebp),%eax
8010552a:	50                   	push   %eax
8010552b:	ff 75 0c             	pushl  0xc(%ebp)
8010552e:	ff 75 08             	pushl  0x8(%ebp)
80105531:	e8 51 ff ff ff       	call   80105487 <stosb>
80105536:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105539:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010553c:	c9                   	leave  
8010553d:	c3                   	ret    

8010553e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010553e:	f3 0f 1e fb          	endbr32 
80105542:	55                   	push   %ebp
80105543:	89 e5                	mov    %esp,%ebp
80105545:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105548:	8b 45 08             	mov    0x8(%ebp),%eax
8010554b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010554e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105551:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105554:	eb 30                	jmp    80105586 <memcmp+0x48>
    if(*s1 != *s2)
80105556:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105559:	0f b6 10             	movzbl (%eax),%edx
8010555c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010555f:	0f b6 00             	movzbl (%eax),%eax
80105562:	38 c2                	cmp    %al,%dl
80105564:	74 18                	je     8010557e <memcmp+0x40>
      return *s1 - *s2;
80105566:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105569:	0f b6 00             	movzbl (%eax),%eax
8010556c:	0f b6 d0             	movzbl %al,%edx
8010556f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105572:	0f b6 00             	movzbl (%eax),%eax
80105575:	0f b6 c0             	movzbl %al,%eax
80105578:	29 c2                	sub    %eax,%edx
8010557a:	89 d0                	mov    %edx,%eax
8010557c:	eb 1a                	jmp    80105598 <memcmp+0x5a>
    s1++, s2++;
8010557e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105582:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105586:	8b 45 10             	mov    0x10(%ebp),%eax
80105589:	8d 50 ff             	lea    -0x1(%eax),%edx
8010558c:	89 55 10             	mov    %edx,0x10(%ebp)
8010558f:	85 c0                	test   %eax,%eax
80105591:	75 c3                	jne    80105556 <memcmp+0x18>
  }

  return 0;
80105593:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105598:	c9                   	leave  
80105599:	c3                   	ret    

8010559a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010559a:	f3 0f 1e fb          	endbr32 
8010559e:	55                   	push   %ebp
8010559f:	89 e5                	mov    %esp,%ebp
801055a1:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055aa:	8b 45 08             	mov    0x8(%ebp),%eax
801055ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055b6:	73 54                	jae    8010560c <memmove+0x72>
801055b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055bb:	8b 45 10             	mov    0x10(%ebp),%eax
801055be:	01 d0                	add    %edx,%eax
801055c0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801055c3:	73 47                	jae    8010560c <memmove+0x72>
    s += n;
801055c5:	8b 45 10             	mov    0x10(%ebp),%eax
801055c8:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801055cb:	8b 45 10             	mov    0x10(%ebp),%eax
801055ce:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801055d1:	eb 13                	jmp    801055e6 <memmove+0x4c>
      *--d = *--s;
801055d3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801055d7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801055db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055de:	0f b6 10             	movzbl (%eax),%edx
801055e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055e4:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801055e6:	8b 45 10             	mov    0x10(%ebp),%eax
801055e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ec:	89 55 10             	mov    %edx,0x10(%ebp)
801055ef:	85 c0                	test   %eax,%eax
801055f1:	75 e0                	jne    801055d3 <memmove+0x39>
  if(s < d && s + n > d){
801055f3:	eb 24                	jmp    80105619 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801055f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055f8:	8d 42 01             	lea    0x1(%edx),%eax
801055fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105601:	8d 48 01             	lea    0x1(%eax),%ecx
80105604:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105607:	0f b6 12             	movzbl (%edx),%edx
8010560a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010560c:	8b 45 10             	mov    0x10(%ebp),%eax
8010560f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105612:	89 55 10             	mov    %edx,0x10(%ebp)
80105615:	85 c0                	test   %eax,%eax
80105617:	75 dc                	jne    801055f5 <memmove+0x5b>

  return dst;
80105619:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010561c:	c9                   	leave  
8010561d:	c3                   	ret    

8010561e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010561e:	f3 0f 1e fb          	endbr32 
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105625:	ff 75 10             	pushl  0x10(%ebp)
80105628:	ff 75 0c             	pushl  0xc(%ebp)
8010562b:	ff 75 08             	pushl  0x8(%ebp)
8010562e:	e8 67 ff ff ff       	call   8010559a <memmove>
80105633:	83 c4 0c             	add    $0xc,%esp
}
80105636:	c9                   	leave  
80105637:	c3                   	ret    

80105638 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105638:	f3 0f 1e fb          	endbr32 
8010563c:	55                   	push   %ebp
8010563d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010563f:	eb 0c                	jmp    8010564d <strncmp+0x15>
    n--, p++, q++;
80105641:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105645:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105649:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010564d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105651:	74 1a                	je     8010566d <strncmp+0x35>
80105653:	8b 45 08             	mov    0x8(%ebp),%eax
80105656:	0f b6 00             	movzbl (%eax),%eax
80105659:	84 c0                	test   %al,%al
8010565b:	74 10                	je     8010566d <strncmp+0x35>
8010565d:	8b 45 08             	mov    0x8(%ebp),%eax
80105660:	0f b6 10             	movzbl (%eax),%edx
80105663:	8b 45 0c             	mov    0xc(%ebp),%eax
80105666:	0f b6 00             	movzbl (%eax),%eax
80105669:	38 c2                	cmp    %al,%dl
8010566b:	74 d4                	je     80105641 <strncmp+0x9>
  if(n == 0)
8010566d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105671:	75 07                	jne    8010567a <strncmp+0x42>
    return 0;
80105673:	b8 00 00 00 00       	mov    $0x0,%eax
80105678:	eb 16                	jmp    80105690 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010567a:	8b 45 08             	mov    0x8(%ebp),%eax
8010567d:	0f b6 00             	movzbl (%eax),%eax
80105680:	0f b6 d0             	movzbl %al,%edx
80105683:	8b 45 0c             	mov    0xc(%ebp),%eax
80105686:	0f b6 00             	movzbl (%eax),%eax
80105689:	0f b6 c0             	movzbl %al,%eax
8010568c:	29 c2                	sub    %eax,%edx
8010568e:	89 d0                	mov    %edx,%eax
}
80105690:	5d                   	pop    %ebp
80105691:	c3                   	ret    

80105692 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105692:	f3 0f 1e fb          	endbr32 
80105696:	55                   	push   %ebp
80105697:	89 e5                	mov    %esp,%ebp
80105699:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010569c:	8b 45 08             	mov    0x8(%ebp),%eax
8010569f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056a2:	90                   	nop
801056a3:	8b 45 10             	mov    0x10(%ebp),%eax
801056a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801056a9:	89 55 10             	mov    %edx,0x10(%ebp)
801056ac:	85 c0                	test   %eax,%eax
801056ae:	7e 2c                	jle    801056dc <strncpy+0x4a>
801056b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801056b3:	8d 42 01             	lea    0x1(%edx),%eax
801056b6:	89 45 0c             	mov    %eax,0xc(%ebp)
801056b9:	8b 45 08             	mov    0x8(%ebp),%eax
801056bc:	8d 48 01             	lea    0x1(%eax),%ecx
801056bf:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056c2:	0f b6 12             	movzbl (%edx),%edx
801056c5:	88 10                	mov    %dl,(%eax)
801056c7:	0f b6 00             	movzbl (%eax),%eax
801056ca:	84 c0                	test   %al,%al
801056cc:	75 d5                	jne    801056a3 <strncpy+0x11>
    ;
  while(n-- > 0)
801056ce:	eb 0c                	jmp    801056dc <strncpy+0x4a>
    *s++ = 0;
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	8d 50 01             	lea    0x1(%eax),%edx
801056d6:	89 55 08             	mov    %edx,0x8(%ebp)
801056d9:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801056dc:	8b 45 10             	mov    0x10(%ebp),%eax
801056df:	8d 50 ff             	lea    -0x1(%eax),%edx
801056e2:	89 55 10             	mov    %edx,0x10(%ebp)
801056e5:	85 c0                	test   %eax,%eax
801056e7:	7f e7                	jg     801056d0 <strncpy+0x3e>
  return os;
801056e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056ec:	c9                   	leave  
801056ed:	c3                   	ret    

801056ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801056ee:	f3 0f 1e fb          	endbr32 
801056f2:	55                   	push   %ebp
801056f3:	89 e5                	mov    %esp,%ebp
801056f5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056f8:	8b 45 08             	mov    0x8(%ebp),%eax
801056fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801056fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105702:	7f 05                	jg     80105709 <safestrcpy+0x1b>
    return os;
80105704:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105707:	eb 31                	jmp    8010573a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105709:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010570d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105711:	7e 1e                	jle    80105731 <safestrcpy+0x43>
80105713:	8b 55 0c             	mov    0xc(%ebp),%edx
80105716:	8d 42 01             	lea    0x1(%edx),%eax
80105719:	89 45 0c             	mov    %eax,0xc(%ebp)
8010571c:	8b 45 08             	mov    0x8(%ebp),%eax
8010571f:	8d 48 01             	lea    0x1(%eax),%ecx
80105722:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105725:	0f b6 12             	movzbl (%edx),%edx
80105728:	88 10                	mov    %dl,(%eax)
8010572a:	0f b6 00             	movzbl (%eax),%eax
8010572d:	84 c0                	test   %al,%al
8010572f:	75 d8                	jne    80105709 <safestrcpy+0x1b>
    ;
  *s = 0;
80105731:	8b 45 08             	mov    0x8(%ebp),%eax
80105734:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105737:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010573a:	c9                   	leave  
8010573b:	c3                   	ret    

8010573c <strlen>:

int
strlen(const char *s)
{
8010573c:	f3 0f 1e fb          	endbr32 
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
80105743:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105746:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010574d:	eb 04                	jmp    80105753 <strlen+0x17>
8010574f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105753:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105756:	8b 45 08             	mov    0x8(%ebp),%eax
80105759:	01 d0                	add    %edx,%eax
8010575b:	0f b6 00             	movzbl (%eax),%eax
8010575e:	84 c0                	test   %al,%al
80105760:	75 ed                	jne    8010574f <strlen+0x13>
    ;
  return n;
80105762:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105765:	c9                   	leave  
80105766:	c3                   	ret    

80105767 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105767:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010576b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
8010576f:	55                   	push   %ebp
  pushl %ebx
80105770:	53                   	push   %ebx
  pushl %esi
80105771:	56                   	push   %esi
  pushl %edi
80105772:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105773:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105775:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105777:	5f                   	pop    %edi
  popl %esi
80105778:	5e                   	pop    %esi
  popl %ebx
80105779:	5b                   	pop    %ebx
  popl %ebp
8010577a:	5d                   	pop    %ebp
  ret
8010577b:	c3                   	ret    

8010577c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010577c:	f3 0f 1e fb          	endbr32 
80105780:	55                   	push   %ebp
80105781:	89 e5                	mov    %esp,%ebp
80105783:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105786:	e8 0c ed ff ff       	call   80104497 <myproc>
8010578b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010578e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105791:	8b 00                	mov    (%eax),%eax
80105793:	39 45 08             	cmp    %eax,0x8(%ebp)
80105796:	73 0f                	jae    801057a7 <fetchint+0x2b>
80105798:	8b 45 08             	mov    0x8(%ebp),%eax
8010579b:	8d 50 04             	lea    0x4(%eax),%edx
8010579e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a1:	8b 00                	mov    (%eax),%eax
801057a3:	39 c2                	cmp    %eax,%edx
801057a5:	76 07                	jbe    801057ae <fetchint+0x32>
    return -1;
801057a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ac:	eb 0f                	jmp    801057bd <fetchint+0x41>
  *ip = *(int*)(addr);
801057ae:	8b 45 08             	mov    0x8(%ebp),%eax
801057b1:	8b 10                	mov    (%eax),%edx
801057b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b6:	89 10                	mov    %edx,(%eax)
  return 0;
801057b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057bd:	c9                   	leave  
801057be:	c3                   	ret    

801057bf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801057bf:	f3 0f 1e fb          	endbr32 
801057c3:	55                   	push   %ebp
801057c4:	89 e5                	mov    %esp,%ebp
801057c6:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801057c9:	e8 c9 ec ff ff       	call   80104497 <myproc>
801057ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d4:	8b 00                	mov    (%eax),%eax
801057d6:	39 45 08             	cmp    %eax,0x8(%ebp)
801057d9:	72 07                	jb     801057e2 <fetchstr+0x23>
    return -1;
801057db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e0:	eb 43                	jmp    80105825 <fetchstr+0x66>
  *pp = (char*)addr;
801057e2:	8b 55 08             	mov    0x8(%ebp),%edx
801057e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e8:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801057ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ed:	8b 00                	mov    (%eax),%eax
801057ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801057f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f5:	8b 00                	mov    (%eax),%eax
801057f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057fa:	eb 1c                	jmp    80105818 <fetchstr+0x59>
    if(*s == 0)
801057fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ff:	0f b6 00             	movzbl (%eax),%eax
80105802:	84 c0                	test   %al,%al
80105804:	75 0e                	jne    80105814 <fetchstr+0x55>
      return s - *pp;
80105806:	8b 45 0c             	mov    0xc(%ebp),%eax
80105809:	8b 00                	mov    (%eax),%eax
8010580b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010580e:	29 c2                	sub    %eax,%edx
80105810:	89 d0                	mov    %edx,%eax
80105812:	eb 11                	jmp    80105825 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105814:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010581e:	72 dc                	jb     801057fc <fetchstr+0x3d>
  }
  return -1;
80105820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105825:	c9                   	leave  
80105826:	c3                   	ret    

80105827 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105827:	f3 0f 1e fb          	endbr32 
8010582b:	55                   	push   %ebp
8010582c:	89 e5                	mov    %esp,%ebp
8010582e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105831:	e8 61 ec ff ff       	call   80104497 <myproc>
80105836:	8b 40 18             	mov    0x18(%eax),%eax
80105839:	8b 40 44             	mov    0x44(%eax),%eax
8010583c:	8b 55 08             	mov    0x8(%ebp),%edx
8010583f:	c1 e2 02             	shl    $0x2,%edx
80105842:	01 d0                	add    %edx,%eax
80105844:	83 c0 04             	add    $0x4,%eax
80105847:	83 ec 08             	sub    $0x8,%esp
8010584a:	ff 75 0c             	pushl  0xc(%ebp)
8010584d:	50                   	push   %eax
8010584e:	e8 29 ff ff ff       	call   8010577c <fetchint>
80105853:	83 c4 10             	add    $0x10,%esp
}
80105856:	c9                   	leave  
80105857:	c3                   	ret    

80105858 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105858:	f3 0f 1e fb          	endbr32 
8010585c:	55                   	push   %ebp
8010585d:	89 e5                	mov    %esp,%ebp
8010585f:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105862:	e8 30 ec ff ff       	call   80104497 <myproc>
80105867:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010586a:	83 ec 08             	sub    $0x8,%esp
8010586d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105870:	50                   	push   %eax
80105871:	ff 75 08             	pushl  0x8(%ebp)
80105874:	e8 ae ff ff ff       	call   80105827 <argint>
80105879:	83 c4 10             	add    $0x10,%esp
8010587c:	85 c0                	test   %eax,%eax
8010587e:	79 07                	jns    80105887 <argptr+0x2f>
    return -1;
80105880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105885:	eb 3b                	jmp    801058c2 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105887:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010588b:	78 1f                	js     801058ac <argptr+0x54>
8010588d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105890:	8b 00                	mov    (%eax),%eax
80105892:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105895:	39 d0                	cmp    %edx,%eax
80105897:	76 13                	jbe    801058ac <argptr+0x54>
80105899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589c:	89 c2                	mov    %eax,%edx
8010589e:	8b 45 10             	mov    0x10(%ebp),%eax
801058a1:	01 c2                	add    %eax,%edx
801058a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a6:	8b 00                	mov    (%eax),%eax
801058a8:	39 c2                	cmp    %eax,%edx
801058aa:	76 07                	jbe    801058b3 <argptr+0x5b>
    return -1;
801058ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b1:	eb 0f                	jmp    801058c2 <argptr+0x6a>
  *pp = (char*)i;
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	89 c2                	mov    %eax,%edx
801058b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801058bb:	89 10                	mov    %edx,(%eax)
  return 0;
801058bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058c2:	c9                   	leave  
801058c3:	c3                   	ret    

801058c4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058c4:	f3 0f 1e fb          	endbr32 
801058c8:	55                   	push   %ebp
801058c9:	89 e5                	mov    %esp,%ebp
801058cb:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058ce:	83 ec 08             	sub    $0x8,%esp
801058d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d4:	50                   	push   %eax
801058d5:	ff 75 08             	pushl  0x8(%ebp)
801058d8:	e8 4a ff ff ff       	call   80105827 <argint>
801058dd:	83 c4 10             	add    $0x10,%esp
801058e0:	85 c0                	test   %eax,%eax
801058e2:	79 07                	jns    801058eb <argstr+0x27>
    return -1;
801058e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e9:	eb 12                	jmp    801058fd <argstr+0x39>
  return fetchstr(addr, pp);
801058eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ee:	83 ec 08             	sub    $0x8,%esp
801058f1:	ff 75 0c             	pushl  0xc(%ebp)
801058f4:	50                   	push   %eax
801058f5:	e8 c5 fe ff ff       	call   801057bf <fetchstr>
801058fa:	83 c4 10             	add    $0x10,%esp
}
801058fd:	c9                   	leave  
801058fe:	c3                   	ret    

801058ff <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801058ff:	f3 0f 1e fb          	endbr32 
80105903:	55                   	push   %ebp
80105904:	89 e5                	mov    %esp,%ebp
80105906:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105909:	e8 89 eb ff ff       	call   80104497 <myproc>
8010590e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105914:	8b 40 18             	mov    0x18(%eax),%eax
80105917:	8b 40 1c             	mov    0x1c(%eax),%eax
8010591a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010591d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105921:	7e 2f                	jle    80105952 <syscall+0x53>
80105923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105926:	83 f8 18             	cmp    $0x18,%eax
80105929:	77 27                	ja     80105952 <syscall+0x53>
8010592b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592e:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105935:	85 c0                	test   %eax,%eax
80105937:	74 19                	je     80105952 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593c:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105943:	ff d0                	call   *%eax
80105945:	89 c2                	mov    %eax,%edx
80105947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594a:	8b 40 18             	mov    0x18(%eax),%eax
8010594d:	89 50 1c             	mov    %edx,0x1c(%eax)
80105950:	eb 2c                	jmp    8010597e <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105955:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595b:	8b 40 10             	mov    0x10(%eax),%eax
8010595e:	ff 75 f0             	pushl  -0x10(%ebp)
80105961:	52                   	push   %edx
80105962:	50                   	push   %eax
80105963:	68 42 91 10 80       	push   $0x80109142
80105968:	e8 ab aa ff ff       	call   80100418 <cprintf>
8010596d:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	8b 40 18             	mov    0x18(%eax),%eax
80105976:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010597d:	90                   	nop
8010597e:	90                   	nop
8010597f:	c9                   	leave  
80105980:	c3                   	ret    

80105981 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105981:	f3 0f 1e fb          	endbr32 
80105985:	55                   	push   %ebp
80105986:	89 e5                	mov    %esp,%ebp
80105988:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010598b:	83 ec 08             	sub    $0x8,%esp
8010598e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105991:	50                   	push   %eax
80105992:	ff 75 08             	pushl  0x8(%ebp)
80105995:	e8 8d fe ff ff       	call   80105827 <argint>
8010599a:	83 c4 10             	add    $0x10,%esp
8010599d:	85 c0                	test   %eax,%eax
8010599f:	79 07                	jns    801059a8 <argfd+0x27>
    return -1;
801059a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a6:	eb 4f                	jmp    801059f7 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801059a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ab:	85 c0                	test   %eax,%eax
801059ad:	78 20                	js     801059cf <argfd+0x4e>
801059af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b2:	83 f8 0f             	cmp    $0xf,%eax
801059b5:	7f 18                	jg     801059cf <argfd+0x4e>
801059b7:	e8 db ea ff ff       	call   80104497 <myproc>
801059bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059bf:	83 c2 08             	add    $0x8,%edx
801059c2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059cd:	75 07                	jne    801059d6 <argfd+0x55>
    return -1;
801059cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d4:	eb 21                	jmp    801059f7 <argfd+0x76>
  if(pfd)
801059d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059da:	74 08                	je     801059e4 <argfd+0x63>
    *pfd = fd;
801059dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059df:	8b 45 0c             	mov    0xc(%ebp),%eax
801059e2:	89 10                	mov    %edx,(%eax)
  if(pf)
801059e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059e8:	74 08                	je     801059f2 <argfd+0x71>
    *pf = f;
801059ea:	8b 45 10             	mov    0x10(%ebp),%eax
801059ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059f0:	89 10                	mov    %edx,(%eax)
  return 0;
801059f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f7:	c9                   	leave  
801059f8:	c3                   	ret    

801059f9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801059f9:	f3 0f 1e fb          	endbr32 
801059fd:	55                   	push   %ebp
801059fe:	89 e5                	mov    %esp,%ebp
80105a00:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a03:	e8 8f ea ff ff       	call   80104497 <myproc>
80105a08:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a12:	eb 2a                	jmp    80105a3e <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a1a:	83 c2 08             	add    $0x8,%edx
80105a1d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a21:	85 c0                	test   %eax,%eax
80105a23:	75 15                	jne    80105a3a <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a2b:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a2e:	8b 55 08             	mov    0x8(%ebp),%edx
80105a31:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a38:	eb 0f                	jmp    80105a49 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105a3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a3e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a42:	7e d0                	jle    80105a14 <fdalloc+0x1b>
    }
  }
  return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a49:	c9                   	leave  
80105a4a:	c3                   	ret    

80105a4b <sys_dup>:

int
sys_dup(void)
{
80105a4b:	f3 0f 1e fb          	endbr32 
80105a4f:	55                   	push   %ebp
80105a50:	89 e5                	mov    %esp,%ebp
80105a52:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a55:	83 ec 04             	sub    $0x4,%esp
80105a58:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a5b:	50                   	push   %eax
80105a5c:	6a 00                	push   $0x0
80105a5e:	6a 00                	push   $0x0
80105a60:	e8 1c ff ff ff       	call   80105981 <argfd>
80105a65:	83 c4 10             	add    $0x10,%esp
80105a68:	85 c0                	test   %eax,%eax
80105a6a:	79 07                	jns    80105a73 <sys_dup+0x28>
    return -1;
80105a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a71:	eb 31                	jmp    80105aa4 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	50                   	push   %eax
80105a7a:	e8 7a ff ff ff       	call   801059f9 <fdalloc>
80105a7f:	83 c4 10             	add    $0x10,%esp
80105a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a89:	79 07                	jns    80105a92 <sys_dup+0x47>
    return -1;
80105a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a90:	eb 12                	jmp    80105aa4 <sys_dup+0x59>
  filedup(f);
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	83 ec 0c             	sub    $0xc,%esp
80105a98:	50                   	push   %eax
80105a99:	e8 96 b6 ff ff       	call   80101134 <filedup>
80105a9e:	83 c4 10             	add    $0x10,%esp
  return fd;
80105aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105aa4:	c9                   	leave  
80105aa5:	c3                   	ret    

80105aa6 <sys_read>:

int
sys_read(void)
{
80105aa6:	f3 0f 1e fb          	endbr32 
80105aaa:	55                   	push   %ebp
80105aab:	89 e5                	mov    %esp,%ebp
80105aad:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ab0:	83 ec 04             	sub    $0x4,%esp
80105ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab6:	50                   	push   %eax
80105ab7:	6a 00                	push   $0x0
80105ab9:	6a 00                	push   $0x0
80105abb:	e8 c1 fe ff ff       	call   80105981 <argfd>
80105ac0:	83 c4 10             	add    $0x10,%esp
80105ac3:	85 c0                	test   %eax,%eax
80105ac5:	78 2e                	js     80105af5 <sys_read+0x4f>
80105ac7:	83 ec 08             	sub    $0x8,%esp
80105aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105acd:	50                   	push   %eax
80105ace:	6a 02                	push   $0x2
80105ad0:	e8 52 fd ff ff       	call   80105827 <argint>
80105ad5:	83 c4 10             	add    $0x10,%esp
80105ad8:	85 c0                	test   %eax,%eax
80105ada:	78 19                	js     80105af5 <sys_read+0x4f>
80105adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adf:	83 ec 04             	sub    $0x4,%esp
80105ae2:	50                   	push   %eax
80105ae3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ae6:	50                   	push   %eax
80105ae7:	6a 01                	push   $0x1
80105ae9:	e8 6a fd ff ff       	call   80105858 <argptr>
80105aee:	83 c4 10             	add    $0x10,%esp
80105af1:	85 c0                	test   %eax,%eax
80105af3:	79 07                	jns    80105afc <sys_read+0x56>
    return -1;
80105af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afa:	eb 17                	jmp    80105b13 <sys_read+0x6d>
  return fileread(f, p, n);
80105afc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	83 ec 04             	sub    $0x4,%esp
80105b08:	51                   	push   %ecx
80105b09:	52                   	push   %edx
80105b0a:	50                   	push   %eax
80105b0b:	e8 c0 b7 ff ff       	call   801012d0 <fileread>
80105b10:	83 c4 10             	add    $0x10,%esp
}
80105b13:	c9                   	leave  
80105b14:	c3                   	ret    

80105b15 <sys_write>:

int
sys_write(void)
{
80105b15:	f3 0f 1e fb          	endbr32 
80105b19:	55                   	push   %ebp
80105b1a:	89 e5                	mov    %esp,%ebp
80105b1c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b1f:	83 ec 04             	sub    $0x4,%esp
80105b22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b25:	50                   	push   %eax
80105b26:	6a 00                	push   $0x0
80105b28:	6a 00                	push   $0x0
80105b2a:	e8 52 fe ff ff       	call   80105981 <argfd>
80105b2f:	83 c4 10             	add    $0x10,%esp
80105b32:	85 c0                	test   %eax,%eax
80105b34:	78 2e                	js     80105b64 <sys_write+0x4f>
80105b36:	83 ec 08             	sub    $0x8,%esp
80105b39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b3c:	50                   	push   %eax
80105b3d:	6a 02                	push   $0x2
80105b3f:	e8 e3 fc ff ff       	call   80105827 <argint>
80105b44:	83 c4 10             	add    $0x10,%esp
80105b47:	85 c0                	test   %eax,%eax
80105b49:	78 19                	js     80105b64 <sys_write+0x4f>
80105b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4e:	83 ec 04             	sub    $0x4,%esp
80105b51:	50                   	push   %eax
80105b52:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b55:	50                   	push   %eax
80105b56:	6a 01                	push   $0x1
80105b58:	e8 fb fc ff ff       	call   80105858 <argptr>
80105b5d:	83 c4 10             	add    $0x10,%esp
80105b60:	85 c0                	test   %eax,%eax
80105b62:	79 07                	jns    80105b6b <sys_write+0x56>
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 17                	jmp    80105b82 <sys_write+0x6d>
  return filewrite(f, p, n);
80105b6b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b74:	83 ec 04             	sub    $0x4,%esp
80105b77:	51                   	push   %ecx
80105b78:	52                   	push   %edx
80105b79:	50                   	push   %eax
80105b7a:	e8 0d b8 ff ff       	call   8010138c <filewrite>
80105b7f:	83 c4 10             	add    $0x10,%esp
}
80105b82:	c9                   	leave  
80105b83:	c3                   	ret    

80105b84 <sys_close>:

int
sys_close(void)
{
80105b84:	f3 0f 1e fb          	endbr32 
80105b88:	55                   	push   %ebp
80105b89:	89 e5                	mov    %esp,%ebp
80105b8b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b8e:	83 ec 04             	sub    $0x4,%esp
80105b91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b94:	50                   	push   %eax
80105b95:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b98:	50                   	push   %eax
80105b99:	6a 00                	push   $0x0
80105b9b:	e8 e1 fd ff ff       	call   80105981 <argfd>
80105ba0:	83 c4 10             	add    $0x10,%esp
80105ba3:	85 c0                	test   %eax,%eax
80105ba5:	79 07                	jns    80105bae <sys_close+0x2a>
    return -1;
80105ba7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bac:	eb 27                	jmp    80105bd5 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105bae:	e8 e4 e8 ff ff       	call   80104497 <myproc>
80105bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bb6:	83 c2 08             	add    $0x8,%edx
80105bb9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bc0:	00 
  fileclose(f);
80105bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc4:	83 ec 0c             	sub    $0xc,%esp
80105bc7:	50                   	push   %eax
80105bc8:	e8 bc b5 ff ff       	call   80101189 <fileclose>
80105bcd:	83 c4 10             	add    $0x10,%esp
  return 0;
80105bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bd5:	c9                   	leave  
80105bd6:	c3                   	ret    

80105bd7 <sys_fstat>:

int
sys_fstat(void)
{
80105bd7:	f3 0f 1e fb          	endbr32 
80105bdb:	55                   	push   %ebp
80105bdc:	89 e5                	mov    %esp,%ebp
80105bde:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105be1:	83 ec 04             	sub    $0x4,%esp
80105be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	6a 00                	push   $0x0
80105bea:	6a 00                	push   $0x0
80105bec:	e8 90 fd ff ff       	call   80105981 <argfd>
80105bf1:	83 c4 10             	add    $0x10,%esp
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	78 17                	js     80105c0f <sys_fstat+0x38>
80105bf8:	83 ec 04             	sub    $0x4,%esp
80105bfb:	6a 14                	push   $0x14
80105bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c00:	50                   	push   %eax
80105c01:	6a 01                	push   $0x1
80105c03:	e8 50 fc ff ff       	call   80105858 <argptr>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	79 07                	jns    80105c16 <sys_fstat+0x3f>
    return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c14:	eb 13                	jmp    80105c29 <sys_fstat+0x52>
  return filestat(f, st);
80105c16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1c:	83 ec 08             	sub    $0x8,%esp
80105c1f:	52                   	push   %edx
80105c20:	50                   	push   %eax
80105c21:	e8 4f b6 ff ff       	call   80101275 <filestat>
80105c26:	83 c4 10             	add    $0x10,%esp
}
80105c29:	c9                   	leave  
80105c2a:	c3                   	ret    

80105c2b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c2b:	f3 0f 1e fb          	endbr32 
80105c2f:	55                   	push   %ebp
80105c30:	89 e5                	mov    %esp,%ebp
80105c32:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c35:	83 ec 08             	sub    $0x8,%esp
80105c38:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c3b:	50                   	push   %eax
80105c3c:	6a 00                	push   $0x0
80105c3e:	e8 81 fc ff ff       	call   801058c4 <argstr>
80105c43:	83 c4 10             	add    $0x10,%esp
80105c46:	85 c0                	test   %eax,%eax
80105c48:	78 15                	js     80105c5f <sys_link+0x34>
80105c4a:	83 ec 08             	sub    $0x8,%esp
80105c4d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c50:	50                   	push   %eax
80105c51:	6a 01                	push   $0x1
80105c53:	e8 6c fc ff ff       	call   801058c4 <argstr>
80105c58:	83 c4 10             	add    $0x10,%esp
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	79 0a                	jns    80105c69 <sys_link+0x3e>
    return -1;
80105c5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c64:	e9 68 01 00 00       	jmp    80105dd1 <sys_link+0x1a6>

  begin_op();
80105c69:	e8 6a da ff ff       	call   801036d8 <begin_op>
  if((ip = namei(old)) == 0){
80105c6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c71:	83 ec 0c             	sub    $0xc,%esp
80105c74:	50                   	push   %eax
80105c75:	e8 fa c9 ff ff       	call   80102674 <namei>
80105c7a:	83 c4 10             	add    $0x10,%esp
80105c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c80:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c84:	75 0f                	jne    80105c95 <sys_link+0x6a>
    end_op();
80105c86:	e8 dd da ff ff       	call   80103768 <end_op>
    return -1;
80105c8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c90:	e9 3c 01 00 00       	jmp    80105dd1 <sys_link+0x1a6>
  }

  ilock(ip);
80105c95:	83 ec 0c             	sub    $0xc,%esp
80105c98:	ff 75 f4             	pushl  -0xc(%ebp)
80105c9b:	e8 69 be ff ff       	call   80101b09 <ilock>
80105ca0:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105caa:	66 83 f8 01          	cmp    $0x1,%ax
80105cae:	75 1d                	jne    80105ccd <sys_link+0xa2>
    iunlockput(ip);
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	ff 75 f4             	pushl  -0xc(%ebp)
80105cb6:	e8 8b c0 ff ff       	call   80101d46 <iunlockput>
80105cbb:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cbe:	e8 a5 da ff ff       	call   80103768 <end_op>
    return -1;
80105cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc8:	e9 04 01 00 00       	jmp    80105dd1 <sys_link+0x1a6>
  }

  ip->nlink++;
80105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cd4:	83 c0 01             	add    $0x1,%eax
80105cd7:	89 c2                	mov    %eax,%edx
80105cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdc:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ce0:	83 ec 0c             	sub    $0xc,%esp
80105ce3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce6:	e8 35 bc ff ff       	call   80101920 <iupdate>
80105ceb:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105cee:	83 ec 0c             	sub    $0xc,%esp
80105cf1:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf4:	e8 27 bf ff ff       	call   80101c20 <iunlock>
80105cf9:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105cfc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cff:	83 ec 08             	sub    $0x8,%esp
80105d02:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d05:	52                   	push   %edx
80105d06:	50                   	push   %eax
80105d07:	e8 88 c9 ff ff       	call   80102694 <nameiparent>
80105d0c:	83 c4 10             	add    $0x10,%esp
80105d0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d16:	74 71                	je     80105d89 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105d18:	83 ec 0c             	sub    $0xc,%esp
80105d1b:	ff 75 f0             	pushl  -0x10(%ebp)
80105d1e:	e8 e6 bd ff ff       	call   80101b09 <ilock>
80105d23:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d29:	8b 10                	mov    (%eax),%edx
80105d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2e:	8b 00                	mov    (%eax),%eax
80105d30:	39 c2                	cmp    %eax,%edx
80105d32:	75 1d                	jne    80105d51 <sys_link+0x126>
80105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d37:	8b 40 04             	mov    0x4(%eax),%eax
80105d3a:	83 ec 04             	sub    $0x4,%esp
80105d3d:	50                   	push   %eax
80105d3e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d41:	50                   	push   %eax
80105d42:	ff 75 f0             	pushl  -0x10(%ebp)
80105d45:	e8 87 c6 ff ff       	call   801023d1 <dirlink>
80105d4a:	83 c4 10             	add    $0x10,%esp
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	79 10                	jns    80105d61 <sys_link+0x136>
    iunlockput(dp);
80105d51:	83 ec 0c             	sub    $0xc,%esp
80105d54:	ff 75 f0             	pushl  -0x10(%ebp)
80105d57:	e8 ea bf ff ff       	call   80101d46 <iunlockput>
80105d5c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d5f:	eb 29                	jmp    80105d8a <sys_link+0x15f>
  }
  iunlockput(dp);
80105d61:	83 ec 0c             	sub    $0xc,%esp
80105d64:	ff 75 f0             	pushl  -0x10(%ebp)
80105d67:	e8 da bf ff ff       	call   80101d46 <iunlockput>
80105d6c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105d6f:	83 ec 0c             	sub    $0xc,%esp
80105d72:	ff 75 f4             	pushl  -0xc(%ebp)
80105d75:	e8 f8 be ff ff       	call   80101c72 <iput>
80105d7a:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d7d:	e8 e6 d9 ff ff       	call   80103768 <end_op>

  return 0;
80105d82:	b8 00 00 00 00       	mov    $0x0,%eax
80105d87:	eb 48                	jmp    80105dd1 <sys_link+0x1a6>
    goto bad;
80105d89:	90                   	nop

bad:
  ilock(ip);
80105d8a:	83 ec 0c             	sub    $0xc,%esp
80105d8d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d90:	e8 74 bd ff ff       	call   80101b09 <ilock>
80105d95:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d9f:	83 e8 01             	sub    $0x1,%eax
80105da2:	89 c2                	mov    %eax,%edx
80105da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dab:	83 ec 0c             	sub    $0xc,%esp
80105dae:	ff 75 f4             	pushl  -0xc(%ebp)
80105db1:	e8 6a bb ff ff       	call   80101920 <iupdate>
80105db6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105db9:	83 ec 0c             	sub    $0xc,%esp
80105dbc:	ff 75 f4             	pushl  -0xc(%ebp)
80105dbf:	e8 82 bf ff ff       	call   80101d46 <iunlockput>
80105dc4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dc7:	e8 9c d9 ff ff       	call   80103768 <end_op>
  return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dd1:	c9                   	leave  
80105dd2:	c3                   	ret    

80105dd3 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105dd3:	f3 0f 1e fb          	endbr32 
80105dd7:	55                   	push   %ebp
80105dd8:	89 e5                	mov    %esp,%ebp
80105dda:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ddd:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105de4:	eb 40                	jmp    80105e26 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de9:	6a 10                	push   $0x10
80105deb:	50                   	push   %eax
80105dec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105def:	50                   	push   %eax
80105df0:	ff 75 08             	pushl  0x8(%ebp)
80105df3:	e8 19 c2 ff ff       	call   80102011 <readi>
80105df8:	83 c4 10             	add    $0x10,%esp
80105dfb:	83 f8 10             	cmp    $0x10,%eax
80105dfe:	74 0d                	je     80105e0d <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e00:	83 ec 0c             	sub    $0xc,%esp
80105e03:	68 5e 91 10 80       	push   $0x8010915e
80105e08:	e8 fb a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e0d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e11:	66 85 c0             	test   %ax,%ax
80105e14:	74 07                	je     80105e1d <isdirempty+0x4a>
      return 0;
80105e16:	b8 00 00 00 00       	mov    $0x0,%eax
80105e1b:	eb 1b                	jmp    80105e38 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e20:	83 c0 10             	add    $0x10,%eax
80105e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e26:	8b 45 08             	mov    0x8(%ebp),%eax
80105e29:	8b 50 58             	mov    0x58(%eax),%edx
80105e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2f:	39 c2                	cmp    %eax,%edx
80105e31:	77 b3                	ja     80105de6 <isdirempty+0x13>
  }
  return 1;
80105e33:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e38:	c9                   	leave  
80105e39:	c3                   	ret    

80105e3a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e3a:	f3 0f 1e fb          	endbr32 
80105e3e:	55                   	push   %ebp
80105e3f:	89 e5                	mov    %esp,%ebp
80105e41:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e44:	83 ec 08             	sub    $0x8,%esp
80105e47:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e4a:	50                   	push   %eax
80105e4b:	6a 00                	push   $0x0
80105e4d:	e8 72 fa ff ff       	call   801058c4 <argstr>
80105e52:	83 c4 10             	add    $0x10,%esp
80105e55:	85 c0                	test   %eax,%eax
80105e57:	79 0a                	jns    80105e63 <sys_unlink+0x29>
    return -1;
80105e59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5e:	e9 bf 01 00 00       	jmp    80106022 <sys_unlink+0x1e8>

  begin_op();
80105e63:	e8 70 d8 ff ff       	call   801036d8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e68:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e6b:	83 ec 08             	sub    $0x8,%esp
80105e6e:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e71:	52                   	push   %edx
80105e72:	50                   	push   %eax
80105e73:	e8 1c c8 ff ff       	call   80102694 <nameiparent>
80105e78:	83 c4 10             	add    $0x10,%esp
80105e7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e82:	75 0f                	jne    80105e93 <sys_unlink+0x59>
    end_op();
80105e84:	e8 df d8 ff ff       	call   80103768 <end_op>
    return -1;
80105e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8e:	e9 8f 01 00 00       	jmp    80106022 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105e93:	83 ec 0c             	sub    $0xc,%esp
80105e96:	ff 75 f4             	pushl  -0xc(%ebp)
80105e99:	e8 6b bc ff ff       	call   80101b09 <ilock>
80105e9e:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ea1:	83 ec 08             	sub    $0x8,%esp
80105ea4:	68 70 91 10 80       	push   $0x80109170
80105ea9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eac:	50                   	push   %eax
80105ead:	e8 42 c4 ff ff       	call   801022f4 <namecmp>
80105eb2:	83 c4 10             	add    $0x10,%esp
80105eb5:	85 c0                	test   %eax,%eax
80105eb7:	0f 84 49 01 00 00    	je     80106006 <sys_unlink+0x1cc>
80105ebd:	83 ec 08             	sub    $0x8,%esp
80105ec0:	68 72 91 10 80       	push   $0x80109172
80105ec5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ec8:	50                   	push   %eax
80105ec9:	e8 26 c4 ff ff       	call   801022f4 <namecmp>
80105ece:	83 c4 10             	add    $0x10,%esp
80105ed1:	85 c0                	test   %eax,%eax
80105ed3:	0f 84 2d 01 00 00    	je     80106006 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ed9:	83 ec 04             	sub    $0x4,%esp
80105edc:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105edf:	50                   	push   %eax
80105ee0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ee3:	50                   	push   %eax
80105ee4:	ff 75 f4             	pushl  -0xc(%ebp)
80105ee7:	e8 27 c4 ff ff       	call   80102313 <dirlookup>
80105eec:	83 c4 10             	add    $0x10,%esp
80105eef:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ef2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef6:	0f 84 0d 01 00 00    	je     80106009 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105efc:	83 ec 0c             	sub    $0xc,%esp
80105eff:	ff 75 f0             	pushl  -0x10(%ebp)
80105f02:	e8 02 bc ff ff       	call   80101b09 <ilock>
80105f07:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f11:	66 85 c0             	test   %ax,%ax
80105f14:	7f 0d                	jg     80105f23 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105f16:	83 ec 0c             	sub    $0xc,%esp
80105f19:	68 75 91 10 80       	push   $0x80109175
80105f1e:	e8 e5 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f26:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f2a:	66 83 f8 01          	cmp    $0x1,%ax
80105f2e:	75 25                	jne    80105f55 <sys_unlink+0x11b>
80105f30:	83 ec 0c             	sub    $0xc,%esp
80105f33:	ff 75 f0             	pushl  -0x10(%ebp)
80105f36:	e8 98 fe ff ff       	call   80105dd3 <isdirempty>
80105f3b:	83 c4 10             	add    $0x10,%esp
80105f3e:	85 c0                	test   %eax,%eax
80105f40:	75 13                	jne    80105f55 <sys_unlink+0x11b>
    iunlockput(ip);
80105f42:	83 ec 0c             	sub    $0xc,%esp
80105f45:	ff 75 f0             	pushl  -0x10(%ebp)
80105f48:	e8 f9 bd ff ff       	call   80101d46 <iunlockput>
80105f4d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105f50:	e9 b5 00 00 00       	jmp    8010600a <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105f55:	83 ec 04             	sub    $0x4,%esp
80105f58:	6a 10                	push   $0x10
80105f5a:	6a 00                	push   $0x0
80105f5c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f5f:	50                   	push   %eax
80105f60:	e8 6e f5 ff ff       	call   801054d3 <memset>
80105f65:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f68:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105f6b:	6a 10                	push   $0x10
80105f6d:	50                   	push   %eax
80105f6e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f71:	50                   	push   %eax
80105f72:	ff 75 f4             	pushl  -0xc(%ebp)
80105f75:	e8 f0 c1 ff ff       	call   8010216a <writei>
80105f7a:	83 c4 10             	add    $0x10,%esp
80105f7d:	83 f8 10             	cmp    $0x10,%eax
80105f80:	74 0d                	je     80105f8f <sys_unlink+0x155>
    panic("unlink: writei");
80105f82:	83 ec 0c             	sub    $0xc,%esp
80105f85:	68 87 91 10 80       	push   $0x80109187
80105f8a:	e8 79 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80105f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f92:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f96:	66 83 f8 01          	cmp    $0x1,%ax
80105f9a:	75 21                	jne    80105fbd <sys_unlink+0x183>
    dp->nlink--;
80105f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fa3:	83 e8 01             	sub    $0x1,%eax
80105fa6:	89 c2                	mov    %eax,%edx
80105fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fab:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105faf:	83 ec 0c             	sub    $0xc,%esp
80105fb2:	ff 75 f4             	pushl  -0xc(%ebp)
80105fb5:	e8 66 b9 ff ff       	call   80101920 <iupdate>
80105fba:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105fbd:	83 ec 0c             	sub    $0xc,%esp
80105fc0:	ff 75 f4             	pushl  -0xc(%ebp)
80105fc3:	e8 7e bd ff ff       	call   80101d46 <iunlockput>
80105fc8:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fce:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fd2:	83 e8 01             	sub    $0x1,%eax
80105fd5:	89 c2                	mov    %eax,%edx
80105fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fda:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105fde:	83 ec 0c             	sub    $0xc,%esp
80105fe1:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe4:	e8 37 b9 ff ff       	call   80101920 <iupdate>
80105fe9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105fec:	83 ec 0c             	sub    $0xc,%esp
80105fef:	ff 75 f0             	pushl  -0x10(%ebp)
80105ff2:	e8 4f bd ff ff       	call   80101d46 <iunlockput>
80105ff7:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ffa:	e8 69 d7 ff ff       	call   80103768 <end_op>

  return 0;
80105fff:	b8 00 00 00 00       	mov    $0x0,%eax
80106004:	eb 1c                	jmp    80106022 <sys_unlink+0x1e8>
    goto bad;
80106006:	90                   	nop
80106007:	eb 01                	jmp    8010600a <sys_unlink+0x1d0>
    goto bad;
80106009:	90                   	nop

bad:
  iunlockput(dp);
8010600a:	83 ec 0c             	sub    $0xc,%esp
8010600d:	ff 75 f4             	pushl  -0xc(%ebp)
80106010:	e8 31 bd ff ff       	call   80101d46 <iunlockput>
80106015:	83 c4 10             	add    $0x10,%esp
  end_op();
80106018:	e8 4b d7 ff ff       	call   80103768 <end_op>
  return -1;
8010601d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106022:	c9                   	leave  
80106023:	c3                   	ret    

80106024 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106024:	f3 0f 1e fb          	endbr32 
80106028:	55                   	push   %ebp
80106029:	89 e5                	mov    %esp,%ebp
8010602b:	83 ec 38             	sub    $0x38,%esp
8010602e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106031:	8b 55 10             	mov    0x10(%ebp),%edx
80106034:	8b 45 14             	mov    0x14(%ebp),%eax
80106037:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010603b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010603f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106043:	83 ec 08             	sub    $0x8,%esp
80106046:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106049:	50                   	push   %eax
8010604a:	ff 75 08             	pushl  0x8(%ebp)
8010604d:	e8 42 c6 ff ff       	call   80102694 <nameiparent>
80106052:	83 c4 10             	add    $0x10,%esp
80106055:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106058:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010605c:	75 0a                	jne    80106068 <create+0x44>
    return 0;
8010605e:	b8 00 00 00 00       	mov    $0x0,%eax
80106063:	e9 8e 01 00 00       	jmp    801061f6 <create+0x1d2>
  ilock(dp);
80106068:	83 ec 0c             	sub    $0xc,%esp
8010606b:	ff 75 f4             	pushl  -0xc(%ebp)
8010606e:	e8 96 ba ff ff       	call   80101b09 <ilock>
80106073:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106076:	83 ec 04             	sub    $0x4,%esp
80106079:	6a 00                	push   $0x0
8010607b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010607e:	50                   	push   %eax
8010607f:	ff 75 f4             	pushl  -0xc(%ebp)
80106082:	e8 8c c2 ff ff       	call   80102313 <dirlookup>
80106087:	83 c4 10             	add    $0x10,%esp
8010608a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010608d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106091:	74 50                	je     801060e3 <create+0xbf>
    iunlockput(dp);
80106093:	83 ec 0c             	sub    $0xc,%esp
80106096:	ff 75 f4             	pushl  -0xc(%ebp)
80106099:	e8 a8 bc ff ff       	call   80101d46 <iunlockput>
8010609e:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801060a1:	83 ec 0c             	sub    $0xc,%esp
801060a4:	ff 75 f0             	pushl  -0x10(%ebp)
801060a7:	e8 5d ba ff ff       	call   80101b09 <ilock>
801060ac:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801060af:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060b4:	75 15                	jne    801060cb <create+0xa7>
801060b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060bd:	66 83 f8 02          	cmp    $0x2,%ax
801060c1:	75 08                	jne    801060cb <create+0xa7>
      return ip;
801060c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c6:	e9 2b 01 00 00       	jmp    801061f6 <create+0x1d2>
    iunlockput(ip);
801060cb:	83 ec 0c             	sub    $0xc,%esp
801060ce:	ff 75 f0             	pushl  -0x10(%ebp)
801060d1:	e8 70 bc ff ff       	call   80101d46 <iunlockput>
801060d6:	83 c4 10             	add    $0x10,%esp
    return 0;
801060d9:	b8 00 00 00 00       	mov    $0x0,%eax
801060de:	e9 13 01 00 00       	jmp    801061f6 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060e3:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ea:	8b 00                	mov    (%eax),%eax
801060ec:	83 ec 08             	sub    $0x8,%esp
801060ef:	52                   	push   %edx
801060f0:	50                   	push   %eax
801060f1:	e8 4f b7 ff ff       	call   80101845 <ialloc>
801060f6:	83 c4 10             	add    $0x10,%esp
801060f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106100:	75 0d                	jne    8010610f <create+0xeb>
    panic("create: ialloc");
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	68 96 91 10 80       	push   $0x80109196
8010610a:	e8 f9 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
8010610f:	83 ec 0c             	sub    $0xc,%esp
80106112:	ff 75 f0             	pushl  -0x10(%ebp)
80106115:	e8 ef b9 ff ff       	call   80101b09 <ilock>
8010611a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010611d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106120:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106124:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010612f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106136:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010613c:	83 ec 0c             	sub    $0xc,%esp
8010613f:	ff 75 f0             	pushl  -0x10(%ebp)
80106142:	e8 d9 b7 ff ff       	call   80101920 <iupdate>
80106147:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010614a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010614f:	75 6a                	jne    801061bb <create+0x197>
    dp->nlink++;  // for ".."
80106151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106154:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106158:	83 c0 01             	add    $0x1,%eax
8010615b:	89 c2                	mov    %eax,%edx
8010615d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106160:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106164:	83 ec 0c             	sub    $0xc,%esp
80106167:	ff 75 f4             	pushl  -0xc(%ebp)
8010616a:	e8 b1 b7 ff ff       	call   80101920 <iupdate>
8010616f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106175:	8b 40 04             	mov    0x4(%eax),%eax
80106178:	83 ec 04             	sub    $0x4,%esp
8010617b:	50                   	push   %eax
8010617c:	68 70 91 10 80       	push   $0x80109170
80106181:	ff 75 f0             	pushl  -0x10(%ebp)
80106184:	e8 48 c2 ff ff       	call   801023d1 <dirlink>
80106189:	83 c4 10             	add    $0x10,%esp
8010618c:	85 c0                	test   %eax,%eax
8010618e:	78 1e                	js     801061ae <create+0x18a>
80106190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106193:	8b 40 04             	mov    0x4(%eax),%eax
80106196:	83 ec 04             	sub    $0x4,%esp
80106199:	50                   	push   %eax
8010619a:	68 72 91 10 80       	push   $0x80109172
8010619f:	ff 75 f0             	pushl  -0x10(%ebp)
801061a2:	e8 2a c2 ff ff       	call   801023d1 <dirlink>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	85 c0                	test   %eax,%eax
801061ac:	79 0d                	jns    801061bb <create+0x197>
      panic("create dots");
801061ae:	83 ec 0c             	sub    $0xc,%esp
801061b1:	68 a5 91 10 80       	push   $0x801091a5
801061b6:	e8 4d a4 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061be:	8b 40 04             	mov    0x4(%eax),%eax
801061c1:	83 ec 04             	sub    $0x4,%esp
801061c4:	50                   	push   %eax
801061c5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061c8:	50                   	push   %eax
801061c9:	ff 75 f4             	pushl  -0xc(%ebp)
801061cc:	e8 00 c2 ff ff       	call   801023d1 <dirlink>
801061d1:	83 c4 10             	add    $0x10,%esp
801061d4:	85 c0                	test   %eax,%eax
801061d6:	79 0d                	jns    801061e5 <create+0x1c1>
    panic("create: dirlink");
801061d8:	83 ec 0c             	sub    $0xc,%esp
801061db:	68 b1 91 10 80       	push   $0x801091b1
801061e0:	e8 23 a4 ff ff       	call   80100608 <panic>

  iunlockput(dp);
801061e5:	83 ec 0c             	sub    $0xc,%esp
801061e8:	ff 75 f4             	pushl  -0xc(%ebp)
801061eb:	e8 56 bb ff ff       	call   80101d46 <iunlockput>
801061f0:	83 c4 10             	add    $0x10,%esp

  return ip;
801061f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801061f6:	c9                   	leave  
801061f7:	c3                   	ret    

801061f8 <sys_open>:

int
sys_open(void)
{
801061f8:	f3 0f 1e fb          	endbr32 
801061fc:	55                   	push   %ebp
801061fd:	89 e5                	mov    %esp,%ebp
801061ff:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106202:	83 ec 08             	sub    $0x8,%esp
80106205:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106208:	50                   	push   %eax
80106209:	6a 00                	push   $0x0
8010620b:	e8 b4 f6 ff ff       	call   801058c4 <argstr>
80106210:	83 c4 10             	add    $0x10,%esp
80106213:	85 c0                	test   %eax,%eax
80106215:	78 15                	js     8010622c <sys_open+0x34>
80106217:	83 ec 08             	sub    $0x8,%esp
8010621a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010621d:	50                   	push   %eax
8010621e:	6a 01                	push   $0x1
80106220:	e8 02 f6 ff ff       	call   80105827 <argint>
80106225:	83 c4 10             	add    $0x10,%esp
80106228:	85 c0                	test   %eax,%eax
8010622a:	79 0a                	jns    80106236 <sys_open+0x3e>
    return -1;
8010622c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106231:	e9 61 01 00 00       	jmp    80106397 <sys_open+0x19f>

  begin_op();
80106236:	e8 9d d4 ff ff       	call   801036d8 <begin_op>

  if(omode & O_CREATE){
8010623b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010623e:	25 00 02 00 00       	and    $0x200,%eax
80106243:	85 c0                	test   %eax,%eax
80106245:	74 2a                	je     80106271 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106247:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624a:	6a 00                	push   $0x0
8010624c:	6a 00                	push   $0x0
8010624e:	6a 02                	push   $0x2
80106250:	50                   	push   %eax
80106251:	e8 ce fd ff ff       	call   80106024 <create>
80106256:	83 c4 10             	add    $0x10,%esp
80106259:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010625c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106260:	75 75                	jne    801062d7 <sys_open+0xdf>
      end_op();
80106262:	e8 01 d5 ff ff       	call   80103768 <end_op>
      return -1;
80106267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626c:	e9 26 01 00 00       	jmp    80106397 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106271:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106274:	83 ec 0c             	sub    $0xc,%esp
80106277:	50                   	push   %eax
80106278:	e8 f7 c3 ff ff       	call   80102674 <namei>
8010627d:	83 c4 10             	add    $0x10,%esp
80106280:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106283:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106287:	75 0f                	jne    80106298 <sys_open+0xa0>
      end_op();
80106289:	e8 da d4 ff ff       	call   80103768 <end_op>
      return -1;
8010628e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106293:	e9 ff 00 00 00       	jmp    80106397 <sys_open+0x19f>
    }
    ilock(ip);
80106298:	83 ec 0c             	sub    $0xc,%esp
8010629b:	ff 75 f4             	pushl  -0xc(%ebp)
8010629e:	e8 66 b8 ff ff       	call   80101b09 <ilock>
801062a3:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801062a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801062ad:	66 83 f8 01          	cmp    $0x1,%ax
801062b1:	75 24                	jne    801062d7 <sys_open+0xdf>
801062b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b6:	85 c0                	test   %eax,%eax
801062b8:	74 1d                	je     801062d7 <sys_open+0xdf>
      iunlockput(ip);
801062ba:	83 ec 0c             	sub    $0xc,%esp
801062bd:	ff 75 f4             	pushl  -0xc(%ebp)
801062c0:	e8 81 ba ff ff       	call   80101d46 <iunlockput>
801062c5:	83 c4 10             	add    $0x10,%esp
      end_op();
801062c8:	e8 9b d4 ff ff       	call   80103768 <end_op>
      return -1;
801062cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d2:	e9 c0 00 00 00       	jmp    80106397 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062d7:	e8 e7 ad ff ff       	call   801010c3 <filealloc>
801062dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062e3:	74 17                	je     801062fc <sys_open+0x104>
801062e5:	83 ec 0c             	sub    $0xc,%esp
801062e8:	ff 75 f0             	pushl  -0x10(%ebp)
801062eb:	e8 09 f7 ff ff       	call   801059f9 <fdalloc>
801062f0:	83 c4 10             	add    $0x10,%esp
801062f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801062f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801062fa:	79 2e                	jns    8010632a <sys_open+0x132>
    if(f)
801062fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106300:	74 0e                	je     80106310 <sys_open+0x118>
      fileclose(f);
80106302:	83 ec 0c             	sub    $0xc,%esp
80106305:	ff 75 f0             	pushl  -0x10(%ebp)
80106308:	e8 7c ae ff ff       	call   80101189 <fileclose>
8010630d:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106310:	83 ec 0c             	sub    $0xc,%esp
80106313:	ff 75 f4             	pushl  -0xc(%ebp)
80106316:	e8 2b ba ff ff       	call   80101d46 <iunlockput>
8010631b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010631e:	e8 45 d4 ff ff       	call   80103768 <end_op>
    return -1;
80106323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106328:	eb 6d                	jmp    80106397 <sys_open+0x19f>
  }
  iunlock(ip);
8010632a:	83 ec 0c             	sub    $0xc,%esp
8010632d:	ff 75 f4             	pushl  -0xc(%ebp)
80106330:	e8 eb b8 ff ff       	call   80101c20 <iunlock>
80106335:	83 c4 10             	add    $0x10,%esp
  end_op();
80106338:	e8 2b d4 ff ff       	call   80103768 <end_op>

  f->type = FD_INODE;
8010633d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106340:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106349:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010634f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106352:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010635c:	83 e0 01             	and    $0x1,%eax
8010635f:	85 c0                	test   %eax,%eax
80106361:	0f 94 c0             	sete   %al
80106364:	89 c2                	mov    %eax,%edx
80106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106369:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010636c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010636f:	83 e0 01             	and    $0x1,%eax
80106372:	85 c0                	test   %eax,%eax
80106374:	75 0a                	jne    80106380 <sys_open+0x188>
80106376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106379:	83 e0 02             	and    $0x2,%eax
8010637c:	85 c0                	test   %eax,%eax
8010637e:	74 07                	je     80106387 <sys_open+0x18f>
80106380:	b8 01 00 00 00       	mov    $0x1,%eax
80106385:	eb 05                	jmp    8010638c <sys_open+0x194>
80106387:	b8 00 00 00 00       	mov    $0x0,%eax
8010638c:	89 c2                	mov    %eax,%edx
8010638e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106391:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106394:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106397:	c9                   	leave  
80106398:	c3                   	ret    

80106399 <sys_mkdir>:

int
sys_mkdir(void)
{
80106399:	f3 0f 1e fb          	endbr32 
8010639d:	55                   	push   %ebp
8010639e:	89 e5                	mov    %esp,%ebp
801063a0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063a3:	e8 30 d3 ff ff       	call   801036d8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063a8:	83 ec 08             	sub    $0x8,%esp
801063ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ae:	50                   	push   %eax
801063af:	6a 00                	push   $0x0
801063b1:	e8 0e f5 ff ff       	call   801058c4 <argstr>
801063b6:	83 c4 10             	add    $0x10,%esp
801063b9:	85 c0                	test   %eax,%eax
801063bb:	78 1b                	js     801063d8 <sys_mkdir+0x3f>
801063bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c0:	6a 00                	push   $0x0
801063c2:	6a 00                	push   $0x0
801063c4:	6a 01                	push   $0x1
801063c6:	50                   	push   %eax
801063c7:	e8 58 fc ff ff       	call   80106024 <create>
801063cc:	83 c4 10             	add    $0x10,%esp
801063cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063d6:	75 0c                	jne    801063e4 <sys_mkdir+0x4b>
    end_op();
801063d8:	e8 8b d3 ff ff       	call   80103768 <end_op>
    return -1;
801063dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e2:	eb 18                	jmp    801063fc <sys_mkdir+0x63>
  }
  iunlockput(ip);
801063e4:	83 ec 0c             	sub    $0xc,%esp
801063e7:	ff 75 f4             	pushl  -0xc(%ebp)
801063ea:	e8 57 b9 ff ff       	call   80101d46 <iunlockput>
801063ef:	83 c4 10             	add    $0x10,%esp
  end_op();
801063f2:	e8 71 d3 ff ff       	call   80103768 <end_op>
  return 0;
801063f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063fc:	c9                   	leave  
801063fd:	c3                   	ret    

801063fe <sys_mknod>:

int
sys_mknod(void)
{
801063fe:	f3 0f 1e fb          	endbr32 
80106402:	55                   	push   %ebp
80106403:	89 e5                	mov    %esp,%ebp
80106405:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106408:	e8 cb d2 ff ff       	call   801036d8 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010640d:	83 ec 08             	sub    $0x8,%esp
80106410:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106413:	50                   	push   %eax
80106414:	6a 00                	push   $0x0
80106416:	e8 a9 f4 ff ff       	call   801058c4 <argstr>
8010641b:	83 c4 10             	add    $0x10,%esp
8010641e:	85 c0                	test   %eax,%eax
80106420:	78 4f                	js     80106471 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106422:	83 ec 08             	sub    $0x8,%esp
80106425:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106428:	50                   	push   %eax
80106429:	6a 01                	push   $0x1
8010642b:	e8 f7 f3 ff ff       	call   80105827 <argint>
80106430:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106433:	85 c0                	test   %eax,%eax
80106435:	78 3a                	js     80106471 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106437:	83 ec 08             	sub    $0x8,%esp
8010643a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010643d:	50                   	push   %eax
8010643e:	6a 02                	push   $0x2
80106440:	e8 e2 f3 ff ff       	call   80105827 <argint>
80106445:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106448:	85 c0                	test   %eax,%eax
8010644a:	78 25                	js     80106471 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010644c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010644f:	0f bf c8             	movswl %ax,%ecx
80106452:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106455:	0f bf d0             	movswl %ax,%edx
80106458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645b:	51                   	push   %ecx
8010645c:	52                   	push   %edx
8010645d:	6a 03                	push   $0x3
8010645f:	50                   	push   %eax
80106460:	e8 bf fb ff ff       	call   80106024 <create>
80106465:	83 c4 10             	add    $0x10,%esp
80106468:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010646b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010646f:	75 0c                	jne    8010647d <sys_mknod+0x7f>
    end_op();
80106471:	e8 f2 d2 ff ff       	call   80103768 <end_op>
    return -1;
80106476:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647b:	eb 18                	jmp    80106495 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010647d:	83 ec 0c             	sub    $0xc,%esp
80106480:	ff 75 f4             	pushl  -0xc(%ebp)
80106483:	e8 be b8 ff ff       	call   80101d46 <iunlockput>
80106488:	83 c4 10             	add    $0x10,%esp
  end_op();
8010648b:	e8 d8 d2 ff ff       	call   80103768 <end_op>
  return 0;
80106490:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106495:	c9                   	leave  
80106496:	c3                   	ret    

80106497 <sys_chdir>:

int
sys_chdir(void)
{
80106497:	f3 0f 1e fb          	endbr32 
8010649b:	55                   	push   %ebp
8010649c:	89 e5                	mov    %esp,%ebp
8010649e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801064a1:	e8 f1 df ff ff       	call   80104497 <myproc>
801064a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801064a9:	e8 2a d2 ff ff       	call   801036d8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064ae:	83 ec 08             	sub    $0x8,%esp
801064b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064b4:	50                   	push   %eax
801064b5:	6a 00                	push   $0x0
801064b7:	e8 08 f4 ff ff       	call   801058c4 <argstr>
801064bc:	83 c4 10             	add    $0x10,%esp
801064bf:	85 c0                	test   %eax,%eax
801064c1:	78 18                	js     801064db <sys_chdir+0x44>
801064c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064c6:	83 ec 0c             	sub    $0xc,%esp
801064c9:	50                   	push   %eax
801064ca:	e8 a5 c1 ff ff       	call   80102674 <namei>
801064cf:	83 c4 10             	add    $0x10,%esp
801064d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064d9:	75 0c                	jne    801064e7 <sys_chdir+0x50>
    end_op();
801064db:	e8 88 d2 ff ff       	call   80103768 <end_op>
    return -1;
801064e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e5:	eb 68                	jmp    8010654f <sys_chdir+0xb8>
  }
  ilock(ip);
801064e7:	83 ec 0c             	sub    $0xc,%esp
801064ea:	ff 75 f0             	pushl  -0x10(%ebp)
801064ed:	e8 17 b6 ff ff       	call   80101b09 <ilock>
801064f2:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801064f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801064fc:	66 83 f8 01          	cmp    $0x1,%ax
80106500:	74 1a                	je     8010651c <sys_chdir+0x85>
    iunlockput(ip);
80106502:	83 ec 0c             	sub    $0xc,%esp
80106505:	ff 75 f0             	pushl  -0x10(%ebp)
80106508:	e8 39 b8 ff ff       	call   80101d46 <iunlockput>
8010650d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106510:	e8 53 d2 ff ff       	call   80103768 <end_op>
    return -1;
80106515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651a:	eb 33                	jmp    8010654f <sys_chdir+0xb8>
  }
  iunlock(ip);
8010651c:	83 ec 0c             	sub    $0xc,%esp
8010651f:	ff 75 f0             	pushl  -0x10(%ebp)
80106522:	e8 f9 b6 ff ff       	call   80101c20 <iunlock>
80106527:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010652a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652d:	8b 40 68             	mov    0x68(%eax),%eax
80106530:	83 ec 0c             	sub    $0xc,%esp
80106533:	50                   	push   %eax
80106534:	e8 39 b7 ff ff       	call   80101c72 <iput>
80106539:	83 c4 10             	add    $0x10,%esp
  end_op();
8010653c:	e8 27 d2 ff ff       	call   80103768 <end_op>
  curproc->cwd = ip;
80106541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106544:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106547:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010654a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654f:	c9                   	leave  
80106550:	c3                   	ret    

80106551 <sys_exec>:

int
sys_exec(void)
{
80106551:	f3 0f 1e fb          	endbr32 
80106555:	55                   	push   %ebp
80106556:	89 e5                	mov    %esp,%ebp
80106558:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010655e:	83 ec 08             	sub    $0x8,%esp
80106561:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106564:	50                   	push   %eax
80106565:	6a 00                	push   $0x0
80106567:	e8 58 f3 ff ff       	call   801058c4 <argstr>
8010656c:	83 c4 10             	add    $0x10,%esp
8010656f:	85 c0                	test   %eax,%eax
80106571:	78 18                	js     8010658b <sys_exec+0x3a>
80106573:	83 ec 08             	sub    $0x8,%esp
80106576:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010657c:	50                   	push   %eax
8010657d:	6a 01                	push   $0x1
8010657f:	e8 a3 f2 ff ff       	call   80105827 <argint>
80106584:	83 c4 10             	add    $0x10,%esp
80106587:	85 c0                	test   %eax,%eax
80106589:	79 0a                	jns    80106595 <sys_exec+0x44>
    return -1;
8010658b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106590:	e9 c6 00 00 00       	jmp    8010665b <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106595:	83 ec 04             	sub    $0x4,%esp
80106598:	68 80 00 00 00       	push   $0x80
8010659d:	6a 00                	push   $0x0
8010659f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065a5:	50                   	push   %eax
801065a6:	e8 28 ef ff ff       	call   801054d3 <memset>
801065ab:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801065ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b8:	83 f8 1f             	cmp    $0x1f,%eax
801065bb:	76 0a                	jbe    801065c7 <sys_exec+0x76>
      return -1;
801065bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c2:	e9 94 00 00 00       	jmp    8010665b <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ca:	c1 e0 02             	shl    $0x2,%eax
801065cd:	89 c2                	mov    %eax,%edx
801065cf:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065d5:	01 c2                	add    %eax,%edx
801065d7:	83 ec 08             	sub    $0x8,%esp
801065da:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065e0:	50                   	push   %eax
801065e1:	52                   	push   %edx
801065e2:	e8 95 f1 ff ff       	call   8010577c <fetchint>
801065e7:	83 c4 10             	add    $0x10,%esp
801065ea:	85 c0                	test   %eax,%eax
801065ec:	79 07                	jns    801065f5 <sys_exec+0xa4>
      return -1;
801065ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f3:	eb 66                	jmp    8010665b <sys_exec+0x10a>
    if(uarg == 0){
801065f5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065fb:	85 c0                	test   %eax,%eax
801065fd:	75 27                	jne    80106626 <sys_exec+0xd5>
      argv[i] = 0;
801065ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106602:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106609:	00 00 00 00 
      break;
8010660d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010660e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106611:	83 ec 08             	sub    $0x8,%esp
80106614:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010661a:	52                   	push   %edx
8010661b:	50                   	push   %eax
8010661c:	e8 0f a6 ff ff       	call   80100c30 <exec>
80106621:	83 c4 10             	add    $0x10,%esp
80106624:	eb 35                	jmp    8010665b <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106626:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010662c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010662f:	c1 e2 02             	shl    $0x2,%edx
80106632:	01 c2                	add    %eax,%edx
80106634:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010663a:	83 ec 08             	sub    $0x8,%esp
8010663d:	52                   	push   %edx
8010663e:	50                   	push   %eax
8010663f:	e8 7b f1 ff ff       	call   801057bf <fetchstr>
80106644:	83 c4 10             	add    $0x10,%esp
80106647:	85 c0                	test   %eax,%eax
80106649:	79 07                	jns    80106652 <sys_exec+0x101>
      return -1;
8010664b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106650:	eb 09                	jmp    8010665b <sys_exec+0x10a>
  for(i=0;; i++){
80106652:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106656:	e9 5a ff ff ff       	jmp    801065b5 <sys_exec+0x64>
}
8010665b:	c9                   	leave  
8010665c:	c3                   	ret    

8010665d <sys_pipe>:

int
sys_pipe(void)
{
8010665d:	f3 0f 1e fb          	endbr32 
80106661:	55                   	push   %ebp
80106662:	89 e5                	mov    %esp,%ebp
80106664:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106667:	83 ec 04             	sub    $0x4,%esp
8010666a:	6a 08                	push   $0x8
8010666c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010666f:	50                   	push   %eax
80106670:	6a 00                	push   $0x0
80106672:	e8 e1 f1 ff ff       	call   80105858 <argptr>
80106677:	83 c4 10             	add    $0x10,%esp
8010667a:	85 c0                	test   %eax,%eax
8010667c:	79 0a                	jns    80106688 <sys_pipe+0x2b>
    return -1;
8010667e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106683:	e9 ae 00 00 00       	jmp    80106736 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106688:	83 ec 08             	sub    $0x8,%esp
8010668b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010668e:	50                   	push   %eax
8010668f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106692:	50                   	push   %eax
80106693:	e8 20 d9 ff ff       	call   80103fb8 <pipealloc>
80106698:	83 c4 10             	add    $0x10,%esp
8010669b:	85 c0                	test   %eax,%eax
8010669d:	79 0a                	jns    801066a9 <sys_pipe+0x4c>
    return -1;
8010669f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a4:	e9 8d 00 00 00       	jmp    80106736 <sys_pipe+0xd9>
  fd0 = -1;
801066a9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066b3:	83 ec 0c             	sub    $0xc,%esp
801066b6:	50                   	push   %eax
801066b7:	e8 3d f3 ff ff       	call   801059f9 <fdalloc>
801066bc:	83 c4 10             	add    $0x10,%esp
801066bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066c6:	78 18                	js     801066e0 <sys_pipe+0x83>
801066c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066cb:	83 ec 0c             	sub    $0xc,%esp
801066ce:	50                   	push   %eax
801066cf:	e8 25 f3 ff ff       	call   801059f9 <fdalloc>
801066d4:	83 c4 10             	add    $0x10,%esp
801066d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066de:	79 3e                	jns    8010671e <sys_pipe+0xc1>
    if(fd0 >= 0)
801066e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066e4:	78 13                	js     801066f9 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801066e6:	e8 ac dd ff ff       	call   80104497 <myproc>
801066eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066ee:	83 c2 08             	add    $0x8,%edx
801066f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066f8:	00 
    fileclose(rf);
801066f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066fc:	83 ec 0c             	sub    $0xc,%esp
801066ff:	50                   	push   %eax
80106700:	e8 84 aa ff ff       	call   80101189 <fileclose>
80106705:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010670b:	83 ec 0c             	sub    $0xc,%esp
8010670e:	50                   	push   %eax
8010670f:	e8 75 aa ff ff       	call   80101189 <fileclose>
80106714:	83 c4 10             	add    $0x10,%esp
    return -1;
80106717:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671c:	eb 18                	jmp    80106736 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
8010671e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106721:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106724:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106726:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106729:	8d 50 04             	lea    0x4(%eax),%edx
8010672c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010672f:	89 02                	mov    %eax,(%edx)
  return 0;
80106731:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106736:	c9                   	leave  
80106737:	c3                   	ret    

80106738 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106738:	f3 0f 1e fb          	endbr32 
8010673c:	55                   	push   %ebp
8010673d:	89 e5                	mov    %esp,%ebp
8010673f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106742:	e8 be e0 ff ff       	call   80104805 <fork>
}
80106747:	c9                   	leave  
80106748:	c3                   	ret    

80106749 <sys_exit>:

int
sys_exit(void)
{
80106749:	f3 0f 1e fb          	endbr32 
8010674d:	55                   	push   %ebp
8010674e:	89 e5                	mov    %esp,%ebp
80106750:	83 ec 08             	sub    $0x8,%esp
  exit();
80106753:	e8 2a e2 ff ff       	call   80104982 <exit>
  return 0;  // not reached
80106758:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010675d:	c9                   	leave  
8010675e:	c3                   	ret    

8010675f <sys_wait>:

int
sys_wait(void)
{
8010675f:	f3 0f 1e fb          	endbr32 
80106763:	55                   	push   %ebp
80106764:	89 e5                	mov    %esp,%ebp
80106766:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106769:	e8 38 e3 ff ff       	call   80104aa6 <wait>
}
8010676e:	c9                   	leave  
8010676f:	c3                   	ret    

80106770 <sys_kill>:

int
sys_kill(void)
{
80106770:	f3 0f 1e fb          	endbr32 
80106774:	55                   	push   %ebp
80106775:	89 e5                	mov    %esp,%ebp
80106777:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010677a:	83 ec 08             	sub    $0x8,%esp
8010677d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106780:	50                   	push   %eax
80106781:	6a 00                	push   $0x0
80106783:	e8 9f f0 ff ff       	call   80105827 <argint>
80106788:	83 c4 10             	add    $0x10,%esp
8010678b:	85 c0                	test   %eax,%eax
8010678d:	79 07                	jns    80106796 <sys_kill+0x26>
    return -1;
8010678f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106794:	eb 0f                	jmp    801067a5 <sys_kill+0x35>
  return kill(pid);
80106796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106799:	83 ec 0c             	sub    $0xc,%esp
8010679c:	50                   	push   %eax
8010679d:	e8 53 e7 ff ff       	call   80104ef5 <kill>
801067a2:	83 c4 10             	add    $0x10,%esp
}
801067a5:	c9                   	leave  
801067a6:	c3                   	ret    

801067a7 <sys_getpid>:

int
sys_getpid(void)
{
801067a7:	f3 0f 1e fb          	endbr32 
801067ab:	55                   	push   %ebp
801067ac:	89 e5                	mov    %esp,%ebp
801067ae:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801067b1:	e8 e1 dc ff ff       	call   80104497 <myproc>
801067b6:	8b 40 10             	mov    0x10(%eax),%eax
}
801067b9:	c9                   	leave  
801067ba:	c3                   	ret    

801067bb <sys_sbrk>:

int
sys_sbrk(void)
{
801067bb:	f3 0f 1e fb          	endbr32 
801067bf:	55                   	push   %ebp
801067c0:	89 e5                	mov    %esp,%ebp
801067c2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801067c5:	83 ec 08             	sub    $0x8,%esp
801067c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067cb:	50                   	push   %eax
801067cc:	6a 00                	push   $0x0
801067ce:	e8 54 f0 ff ff       	call   80105827 <argint>
801067d3:	83 c4 10             	add    $0x10,%esp
801067d6:	85 c0                	test   %eax,%eax
801067d8:	79 07                	jns    801067e1 <sys_sbrk+0x26>
    return -1;
801067da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067df:	eb 27                	jmp    80106808 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801067e1:	e8 b1 dc ff ff       	call   80104497 <myproc>
801067e6:	8b 00                	mov    (%eax),%eax
801067e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ee:	83 ec 0c             	sub    $0xc,%esp
801067f1:	50                   	push   %eax
801067f2:	e8 14 df ff ff       	call   8010470b <growproc>
801067f7:	83 c4 10             	add    $0x10,%esp
801067fa:	85 c0                	test   %eax,%eax
801067fc:	79 07                	jns    80106805 <sys_sbrk+0x4a>
    return -1;
801067fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106803:	eb 03                	jmp    80106808 <sys_sbrk+0x4d>
  return addr;
80106805:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106808:	c9                   	leave  
80106809:	c3                   	ret    

8010680a <sys_sleep>:

int
sys_sleep(void)
{
8010680a:	f3 0f 1e fb          	endbr32 
8010680e:	55                   	push   %ebp
8010680f:	89 e5                	mov    %esp,%ebp
80106811:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106814:	83 ec 08             	sub    $0x8,%esp
80106817:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010681a:	50                   	push   %eax
8010681b:	6a 00                	push   $0x0
8010681d:	e8 05 f0 ff ff       	call   80105827 <argint>
80106822:	83 c4 10             	add    $0x10,%esp
80106825:	85 c0                	test   %eax,%eax
80106827:	79 07                	jns    80106830 <sys_sleep+0x26>
    return -1;
80106829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010682e:	eb 76                	jmp    801068a6 <sys_sleep+0x9c>
  acquire(&tickslock);
80106830:	83 ec 0c             	sub    $0xc,%esp
80106833:	68 00 6d 11 80       	push   $0x80116d00
80106838:	e8 f7 e9 ff ff       	call   80105234 <acquire>
8010683d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106840:	a1 40 75 11 80       	mov    0x80117540,%eax
80106845:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106848:	eb 38                	jmp    80106882 <sys_sleep+0x78>
    if(myproc()->killed){
8010684a:	e8 48 dc ff ff       	call   80104497 <myproc>
8010684f:	8b 40 24             	mov    0x24(%eax),%eax
80106852:	85 c0                	test   %eax,%eax
80106854:	74 17                	je     8010686d <sys_sleep+0x63>
      release(&tickslock);
80106856:	83 ec 0c             	sub    $0xc,%esp
80106859:	68 00 6d 11 80       	push   $0x80116d00
8010685e:	e8 43 ea ff ff       	call   801052a6 <release>
80106863:	83 c4 10             	add    $0x10,%esp
      return -1;
80106866:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686b:	eb 39                	jmp    801068a6 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010686d:	83 ec 08             	sub    $0x8,%esp
80106870:	68 00 6d 11 80       	push   $0x80116d00
80106875:	68 40 75 11 80       	push   $0x80117540
8010687a:	e8 4c e5 ff ff       	call   80104dcb <sleep>
8010687f:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106882:	a1 40 75 11 80       	mov    0x80117540,%eax
80106887:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010688a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010688d:	39 d0                	cmp    %edx,%eax
8010688f:	72 b9                	jb     8010684a <sys_sleep+0x40>
  }
  release(&tickslock);
80106891:	83 ec 0c             	sub    $0xc,%esp
80106894:	68 00 6d 11 80       	push   $0x80116d00
80106899:	e8 08 ea ff ff       	call   801052a6 <release>
8010689e:	83 c4 10             	add    $0x10,%esp
  return 0;
801068a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068a6:	c9                   	leave  
801068a7:	c3                   	ret    

801068a8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801068a8:	f3 0f 1e fb          	endbr32 
801068ac:	55                   	push   %ebp
801068ad:	89 e5                	mov    %esp,%ebp
801068af:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801068b2:	83 ec 0c             	sub    $0xc,%esp
801068b5:	68 00 6d 11 80       	push   $0x80116d00
801068ba:	e8 75 e9 ff ff       	call   80105234 <acquire>
801068bf:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801068c2:	a1 40 75 11 80       	mov    0x80117540,%eax
801068c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801068ca:	83 ec 0c             	sub    $0xc,%esp
801068cd:	68 00 6d 11 80       	push   $0x80116d00
801068d2:	e8 cf e9 ff ff       	call   801052a6 <release>
801068d7:	83 c4 10             	add    $0x10,%esp
  return xticks;
801068da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068dd:	c9                   	leave  
801068de:	c3                   	ret    

801068df <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
801068df:	f3 0f 1e fb          	endbr32 
801068e3:	55                   	push   %ebp
801068e4:	89 e5                	mov    %esp,%ebp
801068e6:	83 ec 18             	sub    $0x18,%esp
  char * virtual_addr;

  //TODO: what to do if len is 0?

  //dummy size because we're dealing with actual pages here
  if(argint(1, &len) < 0)
801068e9:	83 ec 08             	sub    $0x8,%esp
801068ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068ef:	50                   	push   %eax
801068f0:	6a 01                	push   $0x1
801068f2:	e8 30 ef ff ff       	call   80105827 <argint>
801068f7:	83 c4 10             	add    $0x10,%esp
801068fa:	85 c0                	test   %eax,%eax
801068fc:	79 07                	jns    80106905 <sys_mencrypt+0x26>
    return -1;
801068fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106903:	eb 5e                	jmp    80106963 <sys_mencrypt+0x84>
  if (len == 0) {
80106905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106908:	85 c0                	test   %eax,%eax
8010690a:	75 07                	jne    80106913 <sys_mencrypt+0x34>
    return 0;
8010690c:	b8 00 00 00 00       	mov    $0x0,%eax
80106911:	eb 50                	jmp    80106963 <sys_mencrypt+0x84>
  }
  if (len < 0) {
80106913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106916:	85 c0                	test   %eax,%eax
80106918:	79 07                	jns    80106921 <sys_mencrypt+0x42>
    return -1;
8010691a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691f:	eb 42                	jmp    80106963 <sys_mencrypt+0x84>
  }
  if (argptr(0, &virtual_addr, 1) < 0) {
80106921:	83 ec 04             	sub    $0x4,%esp
80106924:	6a 01                	push   $0x1
80106926:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106929:	50                   	push   %eax
8010692a:	6a 00                	push   $0x0
8010692c:	e8 27 ef ff ff       	call   80105858 <argptr>
80106931:	83 c4 10             	add    $0x10,%esp
80106934:	85 c0                	test   %eax,%eax
80106936:	79 07                	jns    8010693f <sys_mencrypt+0x60>
    return -1;
80106938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010693d:	eb 24                	jmp    80106963 <sys_mencrypt+0x84>
  }

  //geq or ge?
  if ((void *) virtual_addr >= (void *)KERNBASE) {
8010693f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106942:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80106947:	76 07                	jbe    80106950 <sys_mencrypt+0x71>
    return -1;
80106949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694e:	eb 13                	jmp    80106963 <sys_mencrypt+0x84>
  }
  //virtual_addr = (char *)5000;
  return mencrypt((char*)virtual_addr, len);
80106950:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106956:	83 ec 08             	sub    $0x8,%esp
80106959:	52                   	push   %edx
8010695a:	50                   	push   %eax
8010695b:	e8 dd 1f 00 00       	call   8010893d <mencrypt>
80106960:	83 c4 10             	add    $0x10,%esp
}
80106963:	c9                   	leave  
80106964:	c3                   	ret    

80106965 <sys_getpgtable>:

//changed: added wrapper here
int sys_getpgtable(void) {
80106965:	f3 0f 1e fb          	endbr32 
80106969:	55                   	push   %ebp
8010696a:	89 e5                	mov    %esp,%ebp
8010696c:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if((argint(1, &num) < 0)||(argint(2,&wsetOnly)))
8010696f:	83 ec 08             	sub    $0x8,%esp
80106972:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106975:	50                   	push   %eax
80106976:	6a 01                	push   $0x1
80106978:	e8 aa ee ff ff       	call   80105827 <argint>
8010697d:	83 c4 10             	add    $0x10,%esp
80106980:	85 c0                	test   %eax,%eax
80106982:	78 15                	js     80106999 <sys_getpgtable+0x34>
80106984:	83 ec 08             	sub    $0x8,%esp
80106987:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010698a:	50                   	push   %eax
8010698b:	6a 02                	push   $0x2
8010698d:	e8 95 ee ff ff       	call   80105827 <argint>
80106992:	83 c4 10             	add    $0x10,%esp
80106995:	85 c0                	test   %eax,%eax
80106997:	74 07                	je     801069a0 <sys_getpgtable+0x3b>

    return -1;
80106999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699e:	eb 3a                	jmp    801069da <sys_getpgtable+0x75>


  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
801069a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a3:	c1 e0 03             	shl    $0x3,%eax
801069a6:	83 ec 04             	sub    $0x4,%esp
801069a9:	50                   	push   %eax
801069aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069ad:	50                   	push   %eax
801069ae:	6a 00                	push   $0x0
801069b0:	e8 a3 ee ff ff       	call   80105858 <argptr>
801069b5:	83 c4 10             	add    $0x10,%esp
801069b8:	85 c0                	test   %eax,%eax
801069ba:	79 07                	jns    801069c3 <sys_getpgtable+0x5e>
    return -1;
801069bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c1:	eb 17                	jmp    801069da <sys_getpgtable+0x75>
  }
  return getpgtable(entries, num, wsetOnly);
801069c3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801069c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069cc:	83 ec 04             	sub    $0x4,%esp
801069cf:	51                   	push   %ecx
801069d0:	52                   	push   %edx
801069d1:	50                   	push   %eax
801069d2:	e8 89 20 00 00       	call   80108a60 <getpgtable>
801069d7:	83 c4 10             	add    $0x10,%esp
}
801069da:	c9                   	leave  
801069db:	c3                   	ret    

801069dc <sys_dump_rawphymem>:

//changed: added wrapper here
int sys_dump_rawphymem(void) {
801069dc:	f3 0f 1e fb          	endbr32 
801069e0:	55                   	push   %ebp
801069e1:	89 e5                	mov    %esp,%ebp
801069e3:	83 ec 18             	sub    $0x18,%esp
  uint physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
801069e6:	83 ec 04             	sub    $0x4,%esp
801069e9:	68 00 10 00 00       	push   $0x1000
801069ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069f1:	50                   	push   %eax
801069f2:	6a 01                	push   $0x1
801069f4:	e8 5f ee ff ff       	call   80105858 <argptr>
801069f9:	83 c4 10             	add    $0x10,%esp
801069fc:	85 c0                	test   %eax,%eax
801069fe:	79 07                	jns    80106a07 <sys_dump_rawphymem+0x2b>
    return -1;
80106a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a05:	eb 2f                	jmp    80106a36 <sys_dump_rawphymem+0x5a>

  //dummy size because we're dealing with actual pages here
  if(argint(0, (int*)&physical_addr) < 0)
80106a07:	83 ec 08             	sub    $0x8,%esp
80106a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a0d:	50                   	push   %eax
80106a0e:	6a 00                	push   $0x0
80106a10:	e8 12 ee ff ff       	call   80105827 <argint>
80106a15:	83 c4 10             	add    $0x10,%esp
80106a18:	85 c0                	test   %eax,%eax
80106a1a:	79 07                	jns    80106a23 <sys_dump_rawphymem+0x47>
    return -1;
80106a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a21:	eb 13                	jmp    80106a36 <sys_dump_rawphymem+0x5a>

  return dump_rawphymem(physical_addr, buffer);
80106a23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a29:	83 ec 08             	sub    $0x8,%esp
80106a2c:	52                   	push   %edx
80106a2d:	50                   	push   %eax
80106a2e:	e8 ee 21 00 00       	call   80108c21 <dump_rawphymem>
80106a33:	83 c4 10             	add    $0x10,%esp
80106a36:	c9                   	leave  
80106a37:	c3                   	ret    

80106a38 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a38:	1e                   	push   %ds
  pushl %es
80106a39:	06                   	push   %es
  pushl %fs
80106a3a:	0f a0                	push   %fs
  pushl %gs
80106a3c:	0f a8                	push   %gs
  pushal
80106a3e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106a3f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a43:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a45:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a47:	54                   	push   %esp
  call trap
80106a48:	e8 df 01 00 00       	call   80106c2c <trap>
  addl $4, %esp
80106a4d:	83 c4 04             	add    $0x4,%esp

80106a50 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a50:	61                   	popa   
  popl %gs
80106a51:	0f a9                	pop    %gs
  popl %fs
80106a53:	0f a1                	pop    %fs
  popl %es
80106a55:	07                   	pop    %es
  popl %ds
80106a56:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a57:	83 c4 08             	add    $0x8,%esp
  iret
80106a5a:	cf                   	iret   

80106a5b <lidt>:
{
80106a5b:	55                   	push   %ebp
80106a5c:	89 e5                	mov    %esp,%ebp
80106a5e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106a61:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a64:	83 e8 01             	sub    $0x1,%eax
80106a67:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a72:	8b 45 08             	mov    0x8(%ebp),%eax
80106a75:	c1 e8 10             	shr    $0x10,%eax
80106a78:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106a7c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a7f:	0f 01 18             	lidtl  (%eax)
}
80106a82:	90                   	nop
80106a83:	c9                   	leave  
80106a84:	c3                   	ret    

80106a85 <rcr2>:

static inline uint
rcr2(void)
{
80106a85:	55                   	push   %ebp
80106a86:	89 e5                	mov    %esp,%ebp
80106a88:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a8b:	0f 20 d0             	mov    %cr2,%eax
80106a8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106a91:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a94:	c9                   	leave  
80106a95:	c3                   	ret    

80106a96 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a96:	f3 0f 1e fb          	endbr32 
80106a9a:	55                   	push   %ebp
80106a9b:	89 e5                	mov    %esp,%ebp
80106a9d:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106aa7:	e9 c3 00 00 00       	jmp    80106b6f <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aaf:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106ab6:	89 c2                	mov    %eax,%edx
80106ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abb:	66 89 14 c5 40 6d 11 	mov    %dx,-0x7fee92c0(,%eax,8)
80106ac2:	80 
80106ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac6:	66 c7 04 c5 42 6d 11 	movw   $0x8,-0x7fee92be(,%eax,8)
80106acd:	80 08 00 
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad3:	0f b6 14 c5 44 6d 11 	movzbl -0x7fee92bc(,%eax,8),%edx
80106ada:	80 
80106adb:	83 e2 e0             	and    $0xffffffe0,%edx
80106ade:	88 14 c5 44 6d 11 80 	mov    %dl,-0x7fee92bc(,%eax,8)
80106ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae8:	0f b6 14 c5 44 6d 11 	movzbl -0x7fee92bc(,%eax,8),%edx
80106aef:	80 
80106af0:	83 e2 1f             	and    $0x1f,%edx
80106af3:	88 14 c5 44 6d 11 80 	mov    %dl,-0x7fee92bc(,%eax,8)
80106afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afd:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b04:	80 
80106b05:	83 e2 f0             	and    $0xfffffff0,%edx
80106b08:	83 ca 0e             	or     $0xe,%edx
80106b0b:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b15:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b1c:	80 
80106b1d:	83 e2 ef             	and    $0xffffffef,%edx
80106b20:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2a:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b31:	80 
80106b32:	83 e2 9f             	and    $0xffffff9f,%edx
80106b35:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3f:	0f b6 14 c5 45 6d 11 	movzbl -0x7fee92bb(,%eax,8),%edx
80106b46:	80 
80106b47:	83 ca 80             	or     $0xffffff80,%edx
80106b4a:	88 14 c5 45 6d 11 80 	mov    %dl,-0x7fee92bb(,%eax,8)
80106b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b54:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b5b:	c1 e8 10             	shr    $0x10,%eax
80106b5e:	89 c2                	mov    %eax,%edx
80106b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b63:	66 89 14 c5 46 6d 11 	mov    %dx,-0x7fee92ba(,%eax,8)
80106b6a:	80 
  for(i = 0; i < 256; i++)
80106b6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b6f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b76:	0f 8e 30 ff ff ff    	jle    80106aac <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b7c:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106b81:	66 a3 40 6f 11 80    	mov    %ax,0x80116f40
80106b87:	66 c7 05 42 6f 11 80 	movw   $0x8,0x80116f42
80106b8e:	08 00 
80106b90:	0f b6 05 44 6f 11 80 	movzbl 0x80116f44,%eax
80106b97:	83 e0 e0             	and    $0xffffffe0,%eax
80106b9a:	a2 44 6f 11 80       	mov    %al,0x80116f44
80106b9f:	0f b6 05 44 6f 11 80 	movzbl 0x80116f44,%eax
80106ba6:	83 e0 1f             	and    $0x1f,%eax
80106ba9:	a2 44 6f 11 80       	mov    %al,0x80116f44
80106bae:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bb5:	83 c8 0f             	or     $0xf,%eax
80106bb8:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bbd:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bc4:	83 e0 ef             	and    $0xffffffef,%eax
80106bc7:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bcc:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106bd3:	83 c8 60             	or     $0x60,%eax
80106bd6:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bdb:	0f b6 05 45 6f 11 80 	movzbl 0x80116f45,%eax
80106be2:	83 c8 80             	or     $0xffffff80,%eax
80106be5:	a2 45 6f 11 80       	mov    %al,0x80116f45
80106bea:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106bef:	c1 e8 10             	shr    $0x10,%eax
80106bf2:	66 a3 46 6f 11 80    	mov    %ax,0x80116f46

  initlock(&tickslock, "time");
80106bf8:	83 ec 08             	sub    $0x8,%esp
80106bfb:	68 c4 91 10 80       	push   $0x801091c4
80106c00:	68 00 6d 11 80       	push   $0x80116d00
80106c05:	e8 04 e6 ff ff       	call   8010520e <initlock>
80106c0a:	83 c4 10             	add    $0x10,%esp
}
80106c0d:	90                   	nop
80106c0e:	c9                   	leave  
80106c0f:	c3                   	ret    

80106c10 <idtinit>:

void
idtinit(void)
{
80106c10:	f3 0f 1e fb          	endbr32 
80106c14:	55                   	push   %ebp
80106c15:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c17:	68 00 08 00 00       	push   $0x800
80106c1c:	68 40 6d 11 80       	push   $0x80116d40
80106c21:	e8 35 fe ff ff       	call   80106a5b <lidt>
80106c26:	83 c4 08             	add    $0x8,%esp
}
80106c29:	90                   	nop
80106c2a:	c9                   	leave  
80106c2b:	c3                   	ret    

80106c2c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c2c:	f3 0f 1e fb          	endbr32 
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
80106c33:	57                   	push   %edi
80106c34:	56                   	push   %esi
80106c35:	53                   	push   %ebx
80106c36:	83 ec 2c             	sub    $0x2c,%esp
  //cprintf("in trap\n");
  if(tf->trapno == T_SYSCALL){
80106c39:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3c:	8b 40 30             	mov    0x30(%eax),%eax
80106c3f:	83 f8 40             	cmp    $0x40,%eax
80106c42:	75 3b                	jne    80106c7f <trap+0x53>
    if(myproc()->killed)
80106c44:	e8 4e d8 ff ff       	call   80104497 <myproc>
80106c49:	8b 40 24             	mov    0x24(%eax),%eax
80106c4c:	85 c0                	test   %eax,%eax
80106c4e:	74 05                	je     80106c55 <trap+0x29>
      exit();
80106c50:	e8 2d dd ff ff       	call   80104982 <exit>
    myproc()->tf = tf;
80106c55:	e8 3d d8 ff ff       	call   80104497 <myproc>
80106c5a:	8b 55 08             	mov    0x8(%ebp),%edx
80106c5d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c60:	e8 9a ec ff ff       	call   801058ff <syscall>
    if(myproc()->killed)
80106c65:	e8 2d d8 ff ff       	call   80104497 <myproc>
80106c6a:	8b 40 24             	mov    0x24(%eax),%eax
80106c6d:	85 c0                	test   %eax,%eax
80106c6f:	0f 84 28 02 00 00    	je     80106e9d <trap+0x271>
      exit();
80106c75:	e8 08 dd ff ff       	call   80104982 <exit>
    return;
80106c7a:	e9 1e 02 00 00       	jmp    80106e9d <trap+0x271>
  }
  char *addr;
  switch(tf->trapno){
80106c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c82:	8b 40 30             	mov    0x30(%eax),%eax
80106c85:	83 e8 0e             	sub    $0xe,%eax
80106c88:	83 f8 31             	cmp    $0x31,%eax
80106c8b:	0f 87 d4 00 00 00    	ja     80106d65 <trap+0x139>
80106c91:	8b 04 85 6c 92 10 80 	mov    -0x7fef6d94(,%eax,4),%eax
80106c98:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106c9b:	e8 5c d7 ff ff       	call   801043fc <cpuid>
80106ca0:	85 c0                	test   %eax,%eax
80106ca2:	75 3d                	jne    80106ce1 <trap+0xb5>
      acquire(&tickslock);
80106ca4:	83 ec 0c             	sub    $0xc,%esp
80106ca7:	68 00 6d 11 80       	push   $0x80116d00
80106cac:	e8 83 e5 ff ff       	call   80105234 <acquire>
80106cb1:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106cb4:	a1 40 75 11 80       	mov    0x80117540,%eax
80106cb9:	83 c0 01             	add    $0x1,%eax
80106cbc:	a3 40 75 11 80       	mov    %eax,0x80117540
      wakeup(&ticks);
80106cc1:	83 ec 0c             	sub    $0xc,%esp
80106cc4:	68 40 75 11 80       	push   $0x80117540
80106cc9:	e8 ec e1 ff ff       	call   80104eba <wakeup>
80106cce:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106cd1:	83 ec 0c             	sub    $0xc,%esp
80106cd4:	68 00 6d 11 80       	push   $0x80116d00
80106cd9:	e8 c8 e5 ff ff       	call   801052a6 <release>
80106cde:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106ce1:	e8 a6 c4 ff ff       	call   8010318c <lapiceoi>
    break;
80106ce6:	e9 32 01 00 00       	jmp    80106e1d <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106ceb:	e8 d1 bc ff ff       	call   801029c1 <ideintr>
    lapiceoi();
80106cf0:	e8 97 c4 ff ff       	call   8010318c <lapiceoi>
    break;
80106cf5:	e9 23 01 00 00       	jmp    80106e1d <trap+0x1f1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106cfa:	e8 c3 c2 ff ff       	call   80102fc2 <kbdintr>
    lapiceoi();
80106cff:	e8 88 c4 ff ff       	call   8010318c <lapiceoi>
    break;
80106d04:	e9 14 01 00 00       	jmp    80106e1d <trap+0x1f1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d09:	e8 71 03 00 00       	call   8010707f <uartintr>
    lapiceoi();
80106d0e:	e8 79 c4 ff ff       	call   8010318c <lapiceoi>
    break;
80106d13:	e9 05 01 00 00       	jmp    80106e1d <trap+0x1f1>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d18:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d21:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d25:	0f b7 d8             	movzwl %ax,%ebx
80106d28:	e8 cf d6 ff ff       	call   801043fc <cpuid>
80106d2d:	56                   	push   %esi
80106d2e:	53                   	push   %ebx
80106d2f:	50                   	push   %eax
80106d30:	68 cc 91 10 80       	push   $0x801091cc
80106d35:	e8 de 96 ff ff       	call   80100418 <cprintf>
80106d3a:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106d3d:	e8 4a c4 ff ff       	call   8010318c <lapiceoi>
    break;
80106d42:	e9 d6 00 00 00       	jmp    80106e1d <trap+0x1f1>
  case T_PGFLT:
    //get the virtual address that caused the fault
    addr = (char*)rcr2();
80106d47:	e8 39 fd ff ff       	call   80106a85 <rcr2>
80106d4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (!mdecrypt(addr)) {
80106d4f:	83 ec 0c             	sub    $0xc,%esp
80106d52:	ff 75 e4             	pushl  -0x1c(%ebp)
80106d55:	e8 3d 1b 00 00       	call   80108897 <mdecrypt>
80106d5a:	83 c4 10             	add    $0x10,%esp
80106d5d:	85 c0                	test   %eax,%eax
80106d5f:	0f 84 b7 00 00 00    	je     80106e1c <trap+0x1f0>
      //default kills the process
      break;
    };
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106d65:	e8 2d d7 ff ff       	call   80104497 <myproc>
80106d6a:	85 c0                	test   %eax,%eax
80106d6c:	74 11                	je     80106d7f <trap+0x153>
80106d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d71:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d75:	0f b7 c0             	movzwl %ax,%eax
80106d78:	83 e0 03             	and    $0x3,%eax
80106d7b:	85 c0                	test   %eax,%eax
80106d7d:	75 39                	jne    80106db8 <trap+0x18c>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d7f:	e8 01 fd ff ff       	call   80106a85 <rcr2>
80106d84:	89 c3                	mov    %eax,%ebx
80106d86:	8b 45 08             	mov    0x8(%ebp),%eax
80106d89:	8b 70 38             	mov    0x38(%eax),%esi
80106d8c:	e8 6b d6 ff ff       	call   801043fc <cpuid>
80106d91:	8b 55 08             	mov    0x8(%ebp),%edx
80106d94:	8b 52 30             	mov    0x30(%edx),%edx
80106d97:	83 ec 0c             	sub    $0xc,%esp
80106d9a:	53                   	push   %ebx
80106d9b:	56                   	push   %esi
80106d9c:	50                   	push   %eax
80106d9d:	52                   	push   %edx
80106d9e:	68 f0 91 10 80       	push   $0x801091f0
80106da3:	e8 70 96 ff ff       	call   80100418 <cprintf>
80106da8:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106dab:	83 ec 0c             	sub    $0xc,%esp
80106dae:	68 22 92 10 80       	push   $0x80109222
80106db3:	e8 50 98 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106db8:	e8 c8 fc ff ff       	call   80106a85 <rcr2>
80106dbd:	89 c6                	mov    %eax,%esi
80106dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc2:	8b 40 38             	mov    0x38(%eax),%eax
80106dc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106dc8:	e8 2f d6 ff ff       	call   801043fc <cpuid>
80106dcd:	89 c3                	mov    %eax,%ebx
80106dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd2:	8b 48 34             	mov    0x34(%eax),%ecx
80106dd5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddb:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106dde:	e8 b4 d6 ff ff       	call   80104497 <myproc>
80106de3:	8d 50 6c             	lea    0x6c(%eax),%edx
80106de6:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106de9:	e8 a9 d6 ff ff       	call   80104497 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dee:	8b 40 10             	mov    0x10(%eax),%eax
80106df1:	56                   	push   %esi
80106df2:	ff 75 d4             	pushl  -0x2c(%ebp)
80106df5:	53                   	push   %ebx
80106df6:	ff 75 d0             	pushl  -0x30(%ebp)
80106df9:	57                   	push   %edi
80106dfa:	ff 75 cc             	pushl  -0x34(%ebp)
80106dfd:	50                   	push   %eax
80106dfe:	68 28 92 10 80       	push   $0x80109228
80106e03:	e8 10 96 ff ff       	call   80100418 <cprintf>
80106e08:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106e0b:	e8 87 d6 ff ff       	call   80104497 <myproc>
80106e10:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e17:	eb 04                	jmp    80106e1d <trap+0x1f1>
    break;
80106e19:	90                   	nop
80106e1a:	eb 01                	jmp    80106e1d <trap+0x1f1>
      break;
80106e1c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e1d:	e8 75 d6 ff ff       	call   80104497 <myproc>
80106e22:	85 c0                	test   %eax,%eax
80106e24:	74 23                	je     80106e49 <trap+0x21d>
80106e26:	e8 6c d6 ff ff       	call   80104497 <myproc>
80106e2b:	8b 40 24             	mov    0x24(%eax),%eax
80106e2e:	85 c0                	test   %eax,%eax
80106e30:	74 17                	je     80106e49 <trap+0x21d>
80106e32:	8b 45 08             	mov    0x8(%ebp),%eax
80106e35:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e39:	0f b7 c0             	movzwl %ax,%eax
80106e3c:	83 e0 03             	and    $0x3,%eax
80106e3f:	83 f8 03             	cmp    $0x3,%eax
80106e42:	75 05                	jne    80106e49 <trap+0x21d>
    exit();
80106e44:	e8 39 db ff ff       	call   80104982 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106e49:	e8 49 d6 ff ff       	call   80104497 <myproc>
80106e4e:	85 c0                	test   %eax,%eax
80106e50:	74 1d                	je     80106e6f <trap+0x243>
80106e52:	e8 40 d6 ff ff       	call   80104497 <myproc>
80106e57:	8b 40 0c             	mov    0xc(%eax),%eax
80106e5a:	83 f8 04             	cmp    $0x4,%eax
80106e5d:	75 10                	jne    80106e6f <trap+0x243>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e62:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106e65:	83 f8 20             	cmp    $0x20,%eax
80106e68:	75 05                	jne    80106e6f <trap+0x243>
    yield();
80106e6a:	e8 d4 de ff ff       	call   80104d43 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106e6f:	e8 23 d6 ff ff       	call   80104497 <myproc>
80106e74:	85 c0                	test   %eax,%eax
80106e76:	74 26                	je     80106e9e <trap+0x272>
80106e78:	e8 1a d6 ff ff       	call   80104497 <myproc>
80106e7d:	8b 40 24             	mov    0x24(%eax),%eax
80106e80:	85 c0                	test   %eax,%eax
80106e82:	74 1a                	je     80106e9e <trap+0x272>
80106e84:	8b 45 08             	mov    0x8(%ebp),%eax
80106e87:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e8b:	0f b7 c0             	movzwl %ax,%eax
80106e8e:	83 e0 03             	and    $0x3,%eax
80106e91:	83 f8 03             	cmp    $0x3,%eax
80106e94:	75 08                	jne    80106e9e <trap+0x272>
    exit();
80106e96:	e8 e7 da ff ff       	call   80104982 <exit>
80106e9b:	eb 01                	jmp    80106e9e <trap+0x272>
    return;
80106e9d:	90                   	nop
}
80106e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ea1:	5b                   	pop    %ebx
80106ea2:	5e                   	pop    %esi
80106ea3:	5f                   	pop    %edi
80106ea4:	5d                   	pop    %ebp
80106ea5:	c3                   	ret    

80106ea6 <inb>:
{
80106ea6:	55                   	push   %ebp
80106ea7:	89 e5                	mov    %esp,%ebp
80106ea9:	83 ec 14             	sub    $0x14,%esp
80106eac:	8b 45 08             	mov    0x8(%ebp),%eax
80106eaf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106eb3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106eb7:	89 c2                	mov    %eax,%edx
80106eb9:	ec                   	in     (%dx),%al
80106eba:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ebd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ec1:	c9                   	leave  
80106ec2:	c3                   	ret    

80106ec3 <outb>:
{
80106ec3:	55                   	push   %ebp
80106ec4:	89 e5                	mov    %esp,%ebp
80106ec6:	83 ec 08             	sub    $0x8,%esp
80106ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80106ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ecf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106ed3:	89 d0                	mov    %edx,%eax
80106ed5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ed8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106edc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ee0:	ee                   	out    %al,(%dx)
}
80106ee1:	90                   	nop
80106ee2:	c9                   	leave  
80106ee3:	c3                   	ret    

80106ee4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ee4:	f3 0f 1e fb          	endbr32 
80106ee8:	55                   	push   %ebp
80106ee9:	89 e5                	mov    %esp,%ebp
80106eeb:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106eee:	6a 00                	push   $0x0
80106ef0:	68 fa 03 00 00       	push   $0x3fa
80106ef5:	e8 c9 ff ff ff       	call   80106ec3 <outb>
80106efa:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106efd:	68 80 00 00 00       	push   $0x80
80106f02:	68 fb 03 00 00       	push   $0x3fb
80106f07:	e8 b7 ff ff ff       	call   80106ec3 <outb>
80106f0c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f0f:	6a 0c                	push   $0xc
80106f11:	68 f8 03 00 00       	push   $0x3f8
80106f16:	e8 a8 ff ff ff       	call   80106ec3 <outb>
80106f1b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106f1e:	6a 00                	push   $0x0
80106f20:	68 f9 03 00 00       	push   $0x3f9
80106f25:	e8 99 ff ff ff       	call   80106ec3 <outb>
80106f2a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106f2d:	6a 03                	push   $0x3
80106f2f:	68 fb 03 00 00       	push   $0x3fb
80106f34:	e8 8a ff ff ff       	call   80106ec3 <outb>
80106f39:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106f3c:	6a 00                	push   $0x0
80106f3e:	68 fc 03 00 00       	push   $0x3fc
80106f43:	e8 7b ff ff ff       	call   80106ec3 <outb>
80106f48:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106f4b:	6a 01                	push   $0x1
80106f4d:	68 f9 03 00 00       	push   $0x3f9
80106f52:	e8 6c ff ff ff       	call   80106ec3 <outb>
80106f57:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f5a:	68 fd 03 00 00       	push   $0x3fd
80106f5f:	e8 42 ff ff ff       	call   80106ea6 <inb>
80106f64:	83 c4 04             	add    $0x4,%esp
80106f67:	3c ff                	cmp    $0xff,%al
80106f69:	74 61                	je     80106fcc <uartinit+0xe8>
    return;
  uart = 1;
80106f6b:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80106f72:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106f75:	68 fa 03 00 00       	push   $0x3fa
80106f7a:	e8 27 ff ff ff       	call   80106ea6 <inb>
80106f7f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106f82:	68 f8 03 00 00       	push   $0x3f8
80106f87:	e8 1a ff ff ff       	call   80106ea6 <inb>
80106f8c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106f8f:	83 ec 08             	sub    $0x8,%esp
80106f92:	6a 00                	push   $0x0
80106f94:	6a 04                	push   $0x4
80106f96:	e8 d8 bc ff ff       	call   80102c73 <ioapicenable>
80106f9b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f9e:	c7 45 f4 34 93 10 80 	movl   $0x80109334,-0xc(%ebp)
80106fa5:	eb 19                	jmp    80106fc0 <uartinit+0xdc>
    uartputc(*p);
80106fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106faa:	0f b6 00             	movzbl (%eax),%eax
80106fad:	0f be c0             	movsbl %al,%eax
80106fb0:	83 ec 0c             	sub    $0xc,%esp
80106fb3:	50                   	push   %eax
80106fb4:	e8 16 00 00 00       	call   80106fcf <uartputc>
80106fb9:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106fbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc3:	0f b6 00             	movzbl (%eax),%eax
80106fc6:	84 c0                	test   %al,%al
80106fc8:	75 dd                	jne    80106fa7 <uartinit+0xc3>
80106fca:	eb 01                	jmp    80106fcd <uartinit+0xe9>
    return;
80106fcc:	90                   	nop
}
80106fcd:	c9                   	leave  
80106fce:	c3                   	ret    

80106fcf <uartputc>:

void
uartputc(int c)
{
80106fcf:	f3 0f 1e fb          	endbr32 
80106fd3:	55                   	push   %ebp
80106fd4:	89 e5                	mov    %esp,%ebp
80106fd6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106fd9:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80106fde:	85 c0                	test   %eax,%eax
80106fe0:	74 53                	je     80107035 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106fe2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fe9:	eb 11                	jmp    80106ffc <uartputc+0x2d>
    microdelay(10);
80106feb:	83 ec 0c             	sub    $0xc,%esp
80106fee:	6a 0a                	push   $0xa
80106ff0:	e8 b6 c1 ff ff       	call   801031ab <microdelay>
80106ff5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ff8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ffc:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107000:	7f 1a                	jg     8010701c <uartputc+0x4d>
80107002:	83 ec 0c             	sub    $0xc,%esp
80107005:	68 fd 03 00 00       	push   $0x3fd
8010700a:	e8 97 fe ff ff       	call   80106ea6 <inb>
8010700f:	83 c4 10             	add    $0x10,%esp
80107012:	0f b6 c0             	movzbl %al,%eax
80107015:	83 e0 20             	and    $0x20,%eax
80107018:	85 c0                	test   %eax,%eax
8010701a:	74 cf                	je     80106feb <uartputc+0x1c>
  outb(COM1+0, c);
8010701c:	8b 45 08             	mov    0x8(%ebp),%eax
8010701f:	0f b6 c0             	movzbl %al,%eax
80107022:	83 ec 08             	sub    $0x8,%esp
80107025:	50                   	push   %eax
80107026:	68 f8 03 00 00       	push   $0x3f8
8010702b:	e8 93 fe ff ff       	call   80106ec3 <outb>
80107030:	83 c4 10             	add    $0x10,%esp
80107033:	eb 01                	jmp    80107036 <uartputc+0x67>
    return;
80107035:	90                   	nop
}
80107036:	c9                   	leave  
80107037:	c3                   	ret    

80107038 <uartgetc>:

static int
uartgetc(void)
{
80107038:	f3 0f 1e fb          	endbr32 
8010703c:	55                   	push   %ebp
8010703d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010703f:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80107044:	85 c0                	test   %eax,%eax
80107046:	75 07                	jne    8010704f <uartgetc+0x17>
    return -1;
80107048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010704d:	eb 2e                	jmp    8010707d <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
8010704f:	68 fd 03 00 00       	push   $0x3fd
80107054:	e8 4d fe ff ff       	call   80106ea6 <inb>
80107059:	83 c4 04             	add    $0x4,%esp
8010705c:	0f b6 c0             	movzbl %al,%eax
8010705f:	83 e0 01             	and    $0x1,%eax
80107062:	85 c0                	test   %eax,%eax
80107064:	75 07                	jne    8010706d <uartgetc+0x35>
    return -1;
80107066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010706b:	eb 10                	jmp    8010707d <uartgetc+0x45>
  return inb(COM1+0);
8010706d:	68 f8 03 00 00       	push   $0x3f8
80107072:	e8 2f fe ff ff       	call   80106ea6 <inb>
80107077:	83 c4 04             	add    $0x4,%esp
8010707a:	0f b6 c0             	movzbl %al,%eax
}
8010707d:	c9                   	leave  
8010707e:	c3                   	ret    

8010707f <uartintr>:

void
uartintr(void)
{
8010707f:	f3 0f 1e fb          	endbr32 
80107083:	55                   	push   %ebp
80107084:	89 e5                	mov    %esp,%ebp
80107086:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107089:	83 ec 0c             	sub    $0xc,%esp
8010708c:	68 38 70 10 80       	push   $0x80107038
80107091:	e8 12 98 ff ff       	call   801008a8 <consoleintr>
80107096:	83 c4 10             	add    $0x10,%esp
}
80107099:	90                   	nop
8010709a:	c9                   	leave  
8010709b:	c3                   	ret    

8010709c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $0
8010709e:	6a 00                	push   $0x0
  jmp alltraps
801070a0:	e9 93 f9 ff ff       	jmp    80106a38 <alltraps>

801070a5 <vector1>:
.globl vector1
vector1:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $1
801070a7:	6a 01                	push   $0x1
  jmp alltraps
801070a9:	e9 8a f9 ff ff       	jmp    80106a38 <alltraps>

801070ae <vector2>:
.globl vector2
vector2:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $2
801070b0:	6a 02                	push   $0x2
  jmp alltraps
801070b2:	e9 81 f9 ff ff       	jmp    80106a38 <alltraps>

801070b7 <vector3>:
.globl vector3
vector3:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $3
801070b9:	6a 03                	push   $0x3
  jmp alltraps
801070bb:	e9 78 f9 ff ff       	jmp    80106a38 <alltraps>

801070c0 <vector4>:
.globl vector4
vector4:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $4
801070c2:	6a 04                	push   $0x4
  jmp alltraps
801070c4:	e9 6f f9 ff ff       	jmp    80106a38 <alltraps>

801070c9 <vector5>:
.globl vector5
vector5:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $5
801070cb:	6a 05                	push   $0x5
  jmp alltraps
801070cd:	e9 66 f9 ff ff       	jmp    80106a38 <alltraps>

801070d2 <vector6>:
.globl vector6
vector6:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $6
801070d4:	6a 06                	push   $0x6
  jmp alltraps
801070d6:	e9 5d f9 ff ff       	jmp    80106a38 <alltraps>

801070db <vector7>:
.globl vector7
vector7:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $7
801070dd:	6a 07                	push   $0x7
  jmp alltraps
801070df:	e9 54 f9 ff ff       	jmp    80106a38 <alltraps>

801070e4 <vector8>:
.globl vector8
vector8:
  pushl $8
801070e4:	6a 08                	push   $0x8
  jmp alltraps
801070e6:	e9 4d f9 ff ff       	jmp    80106a38 <alltraps>

801070eb <vector9>:
.globl vector9
vector9:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $9
801070ed:	6a 09                	push   $0x9
  jmp alltraps
801070ef:	e9 44 f9 ff ff       	jmp    80106a38 <alltraps>

801070f4 <vector10>:
.globl vector10
vector10:
  pushl $10
801070f4:	6a 0a                	push   $0xa
  jmp alltraps
801070f6:	e9 3d f9 ff ff       	jmp    80106a38 <alltraps>

801070fb <vector11>:
.globl vector11
vector11:
  pushl $11
801070fb:	6a 0b                	push   $0xb
  jmp alltraps
801070fd:	e9 36 f9 ff ff       	jmp    80106a38 <alltraps>

80107102 <vector12>:
.globl vector12
vector12:
  pushl $12
80107102:	6a 0c                	push   $0xc
  jmp alltraps
80107104:	e9 2f f9 ff ff       	jmp    80106a38 <alltraps>

80107109 <vector13>:
.globl vector13
vector13:
  pushl $13
80107109:	6a 0d                	push   $0xd
  jmp alltraps
8010710b:	e9 28 f9 ff ff       	jmp    80106a38 <alltraps>

80107110 <vector14>:
.globl vector14
vector14:
  pushl $14
80107110:	6a 0e                	push   $0xe
  jmp alltraps
80107112:	e9 21 f9 ff ff       	jmp    80106a38 <alltraps>

80107117 <vector15>:
.globl vector15
vector15:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $15
80107119:	6a 0f                	push   $0xf
  jmp alltraps
8010711b:	e9 18 f9 ff ff       	jmp    80106a38 <alltraps>

80107120 <vector16>:
.globl vector16
vector16:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $16
80107122:	6a 10                	push   $0x10
  jmp alltraps
80107124:	e9 0f f9 ff ff       	jmp    80106a38 <alltraps>

80107129 <vector17>:
.globl vector17
vector17:
  pushl $17
80107129:	6a 11                	push   $0x11
  jmp alltraps
8010712b:	e9 08 f9 ff ff       	jmp    80106a38 <alltraps>

80107130 <vector18>:
.globl vector18
vector18:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $18
80107132:	6a 12                	push   $0x12
  jmp alltraps
80107134:	e9 ff f8 ff ff       	jmp    80106a38 <alltraps>

80107139 <vector19>:
.globl vector19
vector19:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $19
8010713b:	6a 13                	push   $0x13
  jmp alltraps
8010713d:	e9 f6 f8 ff ff       	jmp    80106a38 <alltraps>

80107142 <vector20>:
.globl vector20
vector20:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $20
80107144:	6a 14                	push   $0x14
  jmp alltraps
80107146:	e9 ed f8 ff ff       	jmp    80106a38 <alltraps>

8010714b <vector21>:
.globl vector21
vector21:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $21
8010714d:	6a 15                	push   $0x15
  jmp alltraps
8010714f:	e9 e4 f8 ff ff       	jmp    80106a38 <alltraps>

80107154 <vector22>:
.globl vector22
vector22:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $22
80107156:	6a 16                	push   $0x16
  jmp alltraps
80107158:	e9 db f8 ff ff       	jmp    80106a38 <alltraps>

8010715d <vector23>:
.globl vector23
vector23:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $23
8010715f:	6a 17                	push   $0x17
  jmp alltraps
80107161:	e9 d2 f8 ff ff       	jmp    80106a38 <alltraps>

80107166 <vector24>:
.globl vector24
vector24:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $24
80107168:	6a 18                	push   $0x18
  jmp alltraps
8010716a:	e9 c9 f8 ff ff       	jmp    80106a38 <alltraps>

8010716f <vector25>:
.globl vector25
vector25:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $25
80107171:	6a 19                	push   $0x19
  jmp alltraps
80107173:	e9 c0 f8 ff ff       	jmp    80106a38 <alltraps>

80107178 <vector26>:
.globl vector26
vector26:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $26
8010717a:	6a 1a                	push   $0x1a
  jmp alltraps
8010717c:	e9 b7 f8 ff ff       	jmp    80106a38 <alltraps>

80107181 <vector27>:
.globl vector27
vector27:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $27
80107183:	6a 1b                	push   $0x1b
  jmp alltraps
80107185:	e9 ae f8 ff ff       	jmp    80106a38 <alltraps>

8010718a <vector28>:
.globl vector28
vector28:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $28
8010718c:	6a 1c                	push   $0x1c
  jmp alltraps
8010718e:	e9 a5 f8 ff ff       	jmp    80106a38 <alltraps>

80107193 <vector29>:
.globl vector29
vector29:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $29
80107195:	6a 1d                	push   $0x1d
  jmp alltraps
80107197:	e9 9c f8 ff ff       	jmp    80106a38 <alltraps>

8010719c <vector30>:
.globl vector30
vector30:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $30
8010719e:	6a 1e                	push   $0x1e
  jmp alltraps
801071a0:	e9 93 f8 ff ff       	jmp    80106a38 <alltraps>

801071a5 <vector31>:
.globl vector31
vector31:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $31
801071a7:	6a 1f                	push   $0x1f
  jmp alltraps
801071a9:	e9 8a f8 ff ff       	jmp    80106a38 <alltraps>

801071ae <vector32>:
.globl vector32
vector32:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $32
801071b0:	6a 20                	push   $0x20
  jmp alltraps
801071b2:	e9 81 f8 ff ff       	jmp    80106a38 <alltraps>

801071b7 <vector33>:
.globl vector33
vector33:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $33
801071b9:	6a 21                	push   $0x21
  jmp alltraps
801071bb:	e9 78 f8 ff ff       	jmp    80106a38 <alltraps>

801071c0 <vector34>:
.globl vector34
vector34:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $34
801071c2:	6a 22                	push   $0x22
  jmp alltraps
801071c4:	e9 6f f8 ff ff       	jmp    80106a38 <alltraps>

801071c9 <vector35>:
.globl vector35
vector35:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $35
801071cb:	6a 23                	push   $0x23
  jmp alltraps
801071cd:	e9 66 f8 ff ff       	jmp    80106a38 <alltraps>

801071d2 <vector36>:
.globl vector36
vector36:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $36
801071d4:	6a 24                	push   $0x24
  jmp alltraps
801071d6:	e9 5d f8 ff ff       	jmp    80106a38 <alltraps>

801071db <vector37>:
.globl vector37
vector37:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $37
801071dd:	6a 25                	push   $0x25
  jmp alltraps
801071df:	e9 54 f8 ff ff       	jmp    80106a38 <alltraps>

801071e4 <vector38>:
.globl vector38
vector38:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $38
801071e6:	6a 26                	push   $0x26
  jmp alltraps
801071e8:	e9 4b f8 ff ff       	jmp    80106a38 <alltraps>

801071ed <vector39>:
.globl vector39
vector39:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $39
801071ef:	6a 27                	push   $0x27
  jmp alltraps
801071f1:	e9 42 f8 ff ff       	jmp    80106a38 <alltraps>

801071f6 <vector40>:
.globl vector40
vector40:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $40
801071f8:	6a 28                	push   $0x28
  jmp alltraps
801071fa:	e9 39 f8 ff ff       	jmp    80106a38 <alltraps>

801071ff <vector41>:
.globl vector41
vector41:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $41
80107201:	6a 29                	push   $0x29
  jmp alltraps
80107203:	e9 30 f8 ff ff       	jmp    80106a38 <alltraps>

80107208 <vector42>:
.globl vector42
vector42:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $42
8010720a:	6a 2a                	push   $0x2a
  jmp alltraps
8010720c:	e9 27 f8 ff ff       	jmp    80106a38 <alltraps>

80107211 <vector43>:
.globl vector43
vector43:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $43
80107213:	6a 2b                	push   $0x2b
  jmp alltraps
80107215:	e9 1e f8 ff ff       	jmp    80106a38 <alltraps>

8010721a <vector44>:
.globl vector44
vector44:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $44
8010721c:	6a 2c                	push   $0x2c
  jmp alltraps
8010721e:	e9 15 f8 ff ff       	jmp    80106a38 <alltraps>

80107223 <vector45>:
.globl vector45
vector45:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $45
80107225:	6a 2d                	push   $0x2d
  jmp alltraps
80107227:	e9 0c f8 ff ff       	jmp    80106a38 <alltraps>

8010722c <vector46>:
.globl vector46
vector46:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $46
8010722e:	6a 2e                	push   $0x2e
  jmp alltraps
80107230:	e9 03 f8 ff ff       	jmp    80106a38 <alltraps>

80107235 <vector47>:
.globl vector47
vector47:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $47
80107237:	6a 2f                	push   $0x2f
  jmp alltraps
80107239:	e9 fa f7 ff ff       	jmp    80106a38 <alltraps>

8010723e <vector48>:
.globl vector48
vector48:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $48
80107240:	6a 30                	push   $0x30
  jmp alltraps
80107242:	e9 f1 f7 ff ff       	jmp    80106a38 <alltraps>

80107247 <vector49>:
.globl vector49
vector49:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $49
80107249:	6a 31                	push   $0x31
  jmp alltraps
8010724b:	e9 e8 f7 ff ff       	jmp    80106a38 <alltraps>

80107250 <vector50>:
.globl vector50
vector50:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $50
80107252:	6a 32                	push   $0x32
  jmp alltraps
80107254:	e9 df f7 ff ff       	jmp    80106a38 <alltraps>

80107259 <vector51>:
.globl vector51
vector51:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $51
8010725b:	6a 33                	push   $0x33
  jmp alltraps
8010725d:	e9 d6 f7 ff ff       	jmp    80106a38 <alltraps>

80107262 <vector52>:
.globl vector52
vector52:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $52
80107264:	6a 34                	push   $0x34
  jmp alltraps
80107266:	e9 cd f7 ff ff       	jmp    80106a38 <alltraps>

8010726b <vector53>:
.globl vector53
vector53:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $53
8010726d:	6a 35                	push   $0x35
  jmp alltraps
8010726f:	e9 c4 f7 ff ff       	jmp    80106a38 <alltraps>

80107274 <vector54>:
.globl vector54
vector54:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $54
80107276:	6a 36                	push   $0x36
  jmp alltraps
80107278:	e9 bb f7 ff ff       	jmp    80106a38 <alltraps>

8010727d <vector55>:
.globl vector55
vector55:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $55
8010727f:	6a 37                	push   $0x37
  jmp alltraps
80107281:	e9 b2 f7 ff ff       	jmp    80106a38 <alltraps>

80107286 <vector56>:
.globl vector56
vector56:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $56
80107288:	6a 38                	push   $0x38
  jmp alltraps
8010728a:	e9 a9 f7 ff ff       	jmp    80106a38 <alltraps>

8010728f <vector57>:
.globl vector57
vector57:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $57
80107291:	6a 39                	push   $0x39
  jmp alltraps
80107293:	e9 a0 f7 ff ff       	jmp    80106a38 <alltraps>

80107298 <vector58>:
.globl vector58
vector58:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $58
8010729a:	6a 3a                	push   $0x3a
  jmp alltraps
8010729c:	e9 97 f7 ff ff       	jmp    80106a38 <alltraps>

801072a1 <vector59>:
.globl vector59
vector59:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $59
801072a3:	6a 3b                	push   $0x3b
  jmp alltraps
801072a5:	e9 8e f7 ff ff       	jmp    80106a38 <alltraps>

801072aa <vector60>:
.globl vector60
vector60:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $60
801072ac:	6a 3c                	push   $0x3c
  jmp alltraps
801072ae:	e9 85 f7 ff ff       	jmp    80106a38 <alltraps>

801072b3 <vector61>:
.globl vector61
vector61:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $61
801072b5:	6a 3d                	push   $0x3d
  jmp alltraps
801072b7:	e9 7c f7 ff ff       	jmp    80106a38 <alltraps>

801072bc <vector62>:
.globl vector62
vector62:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $62
801072be:	6a 3e                	push   $0x3e
  jmp alltraps
801072c0:	e9 73 f7 ff ff       	jmp    80106a38 <alltraps>

801072c5 <vector63>:
.globl vector63
vector63:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $63
801072c7:	6a 3f                	push   $0x3f
  jmp alltraps
801072c9:	e9 6a f7 ff ff       	jmp    80106a38 <alltraps>

801072ce <vector64>:
.globl vector64
vector64:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $64
801072d0:	6a 40                	push   $0x40
  jmp alltraps
801072d2:	e9 61 f7 ff ff       	jmp    80106a38 <alltraps>

801072d7 <vector65>:
.globl vector65
vector65:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $65
801072d9:	6a 41                	push   $0x41
  jmp alltraps
801072db:	e9 58 f7 ff ff       	jmp    80106a38 <alltraps>

801072e0 <vector66>:
.globl vector66
vector66:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $66
801072e2:	6a 42                	push   $0x42
  jmp alltraps
801072e4:	e9 4f f7 ff ff       	jmp    80106a38 <alltraps>

801072e9 <vector67>:
.globl vector67
vector67:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $67
801072eb:	6a 43                	push   $0x43
  jmp alltraps
801072ed:	e9 46 f7 ff ff       	jmp    80106a38 <alltraps>

801072f2 <vector68>:
.globl vector68
vector68:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $68
801072f4:	6a 44                	push   $0x44
  jmp alltraps
801072f6:	e9 3d f7 ff ff       	jmp    80106a38 <alltraps>

801072fb <vector69>:
.globl vector69
vector69:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $69
801072fd:	6a 45                	push   $0x45
  jmp alltraps
801072ff:	e9 34 f7 ff ff       	jmp    80106a38 <alltraps>

80107304 <vector70>:
.globl vector70
vector70:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $70
80107306:	6a 46                	push   $0x46
  jmp alltraps
80107308:	e9 2b f7 ff ff       	jmp    80106a38 <alltraps>

8010730d <vector71>:
.globl vector71
vector71:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $71
8010730f:	6a 47                	push   $0x47
  jmp alltraps
80107311:	e9 22 f7 ff ff       	jmp    80106a38 <alltraps>

80107316 <vector72>:
.globl vector72
vector72:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $72
80107318:	6a 48                	push   $0x48
  jmp alltraps
8010731a:	e9 19 f7 ff ff       	jmp    80106a38 <alltraps>

8010731f <vector73>:
.globl vector73
vector73:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $73
80107321:	6a 49                	push   $0x49
  jmp alltraps
80107323:	e9 10 f7 ff ff       	jmp    80106a38 <alltraps>

80107328 <vector74>:
.globl vector74
vector74:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $74
8010732a:	6a 4a                	push   $0x4a
  jmp alltraps
8010732c:	e9 07 f7 ff ff       	jmp    80106a38 <alltraps>

80107331 <vector75>:
.globl vector75
vector75:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $75
80107333:	6a 4b                	push   $0x4b
  jmp alltraps
80107335:	e9 fe f6 ff ff       	jmp    80106a38 <alltraps>

8010733a <vector76>:
.globl vector76
vector76:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $76
8010733c:	6a 4c                	push   $0x4c
  jmp alltraps
8010733e:	e9 f5 f6 ff ff       	jmp    80106a38 <alltraps>

80107343 <vector77>:
.globl vector77
vector77:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $77
80107345:	6a 4d                	push   $0x4d
  jmp alltraps
80107347:	e9 ec f6 ff ff       	jmp    80106a38 <alltraps>

8010734c <vector78>:
.globl vector78
vector78:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $78
8010734e:	6a 4e                	push   $0x4e
  jmp alltraps
80107350:	e9 e3 f6 ff ff       	jmp    80106a38 <alltraps>

80107355 <vector79>:
.globl vector79
vector79:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $79
80107357:	6a 4f                	push   $0x4f
  jmp alltraps
80107359:	e9 da f6 ff ff       	jmp    80106a38 <alltraps>

8010735e <vector80>:
.globl vector80
vector80:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $80
80107360:	6a 50                	push   $0x50
  jmp alltraps
80107362:	e9 d1 f6 ff ff       	jmp    80106a38 <alltraps>

80107367 <vector81>:
.globl vector81
vector81:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $81
80107369:	6a 51                	push   $0x51
  jmp alltraps
8010736b:	e9 c8 f6 ff ff       	jmp    80106a38 <alltraps>

80107370 <vector82>:
.globl vector82
vector82:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $82
80107372:	6a 52                	push   $0x52
  jmp alltraps
80107374:	e9 bf f6 ff ff       	jmp    80106a38 <alltraps>

80107379 <vector83>:
.globl vector83
vector83:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $83
8010737b:	6a 53                	push   $0x53
  jmp alltraps
8010737d:	e9 b6 f6 ff ff       	jmp    80106a38 <alltraps>

80107382 <vector84>:
.globl vector84
vector84:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $84
80107384:	6a 54                	push   $0x54
  jmp alltraps
80107386:	e9 ad f6 ff ff       	jmp    80106a38 <alltraps>

8010738b <vector85>:
.globl vector85
vector85:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $85
8010738d:	6a 55                	push   $0x55
  jmp alltraps
8010738f:	e9 a4 f6 ff ff       	jmp    80106a38 <alltraps>

80107394 <vector86>:
.globl vector86
vector86:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $86
80107396:	6a 56                	push   $0x56
  jmp alltraps
80107398:	e9 9b f6 ff ff       	jmp    80106a38 <alltraps>

8010739d <vector87>:
.globl vector87
vector87:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $87
8010739f:	6a 57                	push   $0x57
  jmp alltraps
801073a1:	e9 92 f6 ff ff       	jmp    80106a38 <alltraps>

801073a6 <vector88>:
.globl vector88
vector88:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $88
801073a8:	6a 58                	push   $0x58
  jmp alltraps
801073aa:	e9 89 f6 ff ff       	jmp    80106a38 <alltraps>

801073af <vector89>:
.globl vector89
vector89:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $89
801073b1:	6a 59                	push   $0x59
  jmp alltraps
801073b3:	e9 80 f6 ff ff       	jmp    80106a38 <alltraps>

801073b8 <vector90>:
.globl vector90
vector90:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $90
801073ba:	6a 5a                	push   $0x5a
  jmp alltraps
801073bc:	e9 77 f6 ff ff       	jmp    80106a38 <alltraps>

801073c1 <vector91>:
.globl vector91
vector91:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $91
801073c3:	6a 5b                	push   $0x5b
  jmp alltraps
801073c5:	e9 6e f6 ff ff       	jmp    80106a38 <alltraps>

801073ca <vector92>:
.globl vector92
vector92:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $92
801073cc:	6a 5c                	push   $0x5c
  jmp alltraps
801073ce:	e9 65 f6 ff ff       	jmp    80106a38 <alltraps>

801073d3 <vector93>:
.globl vector93
vector93:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $93
801073d5:	6a 5d                	push   $0x5d
  jmp alltraps
801073d7:	e9 5c f6 ff ff       	jmp    80106a38 <alltraps>

801073dc <vector94>:
.globl vector94
vector94:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $94
801073de:	6a 5e                	push   $0x5e
  jmp alltraps
801073e0:	e9 53 f6 ff ff       	jmp    80106a38 <alltraps>

801073e5 <vector95>:
.globl vector95
vector95:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $95
801073e7:	6a 5f                	push   $0x5f
  jmp alltraps
801073e9:	e9 4a f6 ff ff       	jmp    80106a38 <alltraps>

801073ee <vector96>:
.globl vector96
vector96:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $96
801073f0:	6a 60                	push   $0x60
  jmp alltraps
801073f2:	e9 41 f6 ff ff       	jmp    80106a38 <alltraps>

801073f7 <vector97>:
.globl vector97
vector97:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $97
801073f9:	6a 61                	push   $0x61
  jmp alltraps
801073fb:	e9 38 f6 ff ff       	jmp    80106a38 <alltraps>

80107400 <vector98>:
.globl vector98
vector98:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $98
80107402:	6a 62                	push   $0x62
  jmp alltraps
80107404:	e9 2f f6 ff ff       	jmp    80106a38 <alltraps>

80107409 <vector99>:
.globl vector99
vector99:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $99
8010740b:	6a 63                	push   $0x63
  jmp alltraps
8010740d:	e9 26 f6 ff ff       	jmp    80106a38 <alltraps>

80107412 <vector100>:
.globl vector100
vector100:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $100
80107414:	6a 64                	push   $0x64
  jmp alltraps
80107416:	e9 1d f6 ff ff       	jmp    80106a38 <alltraps>

8010741b <vector101>:
.globl vector101
vector101:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $101
8010741d:	6a 65                	push   $0x65
  jmp alltraps
8010741f:	e9 14 f6 ff ff       	jmp    80106a38 <alltraps>

80107424 <vector102>:
.globl vector102
vector102:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $102
80107426:	6a 66                	push   $0x66
  jmp alltraps
80107428:	e9 0b f6 ff ff       	jmp    80106a38 <alltraps>

8010742d <vector103>:
.globl vector103
vector103:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $103
8010742f:	6a 67                	push   $0x67
  jmp alltraps
80107431:	e9 02 f6 ff ff       	jmp    80106a38 <alltraps>

80107436 <vector104>:
.globl vector104
vector104:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $104
80107438:	6a 68                	push   $0x68
  jmp alltraps
8010743a:	e9 f9 f5 ff ff       	jmp    80106a38 <alltraps>

8010743f <vector105>:
.globl vector105
vector105:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $105
80107441:	6a 69                	push   $0x69
  jmp alltraps
80107443:	e9 f0 f5 ff ff       	jmp    80106a38 <alltraps>

80107448 <vector106>:
.globl vector106
vector106:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $106
8010744a:	6a 6a                	push   $0x6a
  jmp alltraps
8010744c:	e9 e7 f5 ff ff       	jmp    80106a38 <alltraps>

80107451 <vector107>:
.globl vector107
vector107:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $107
80107453:	6a 6b                	push   $0x6b
  jmp alltraps
80107455:	e9 de f5 ff ff       	jmp    80106a38 <alltraps>

8010745a <vector108>:
.globl vector108
vector108:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $108
8010745c:	6a 6c                	push   $0x6c
  jmp alltraps
8010745e:	e9 d5 f5 ff ff       	jmp    80106a38 <alltraps>

80107463 <vector109>:
.globl vector109
vector109:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $109
80107465:	6a 6d                	push   $0x6d
  jmp alltraps
80107467:	e9 cc f5 ff ff       	jmp    80106a38 <alltraps>

8010746c <vector110>:
.globl vector110
vector110:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $110
8010746e:	6a 6e                	push   $0x6e
  jmp alltraps
80107470:	e9 c3 f5 ff ff       	jmp    80106a38 <alltraps>

80107475 <vector111>:
.globl vector111
vector111:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $111
80107477:	6a 6f                	push   $0x6f
  jmp alltraps
80107479:	e9 ba f5 ff ff       	jmp    80106a38 <alltraps>

8010747e <vector112>:
.globl vector112
vector112:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $112
80107480:	6a 70                	push   $0x70
  jmp alltraps
80107482:	e9 b1 f5 ff ff       	jmp    80106a38 <alltraps>

80107487 <vector113>:
.globl vector113
vector113:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $113
80107489:	6a 71                	push   $0x71
  jmp alltraps
8010748b:	e9 a8 f5 ff ff       	jmp    80106a38 <alltraps>

80107490 <vector114>:
.globl vector114
vector114:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $114
80107492:	6a 72                	push   $0x72
  jmp alltraps
80107494:	e9 9f f5 ff ff       	jmp    80106a38 <alltraps>

80107499 <vector115>:
.globl vector115
vector115:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $115
8010749b:	6a 73                	push   $0x73
  jmp alltraps
8010749d:	e9 96 f5 ff ff       	jmp    80106a38 <alltraps>

801074a2 <vector116>:
.globl vector116
vector116:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $116
801074a4:	6a 74                	push   $0x74
  jmp alltraps
801074a6:	e9 8d f5 ff ff       	jmp    80106a38 <alltraps>

801074ab <vector117>:
.globl vector117
vector117:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $117
801074ad:	6a 75                	push   $0x75
  jmp alltraps
801074af:	e9 84 f5 ff ff       	jmp    80106a38 <alltraps>

801074b4 <vector118>:
.globl vector118
vector118:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $118
801074b6:	6a 76                	push   $0x76
  jmp alltraps
801074b8:	e9 7b f5 ff ff       	jmp    80106a38 <alltraps>

801074bd <vector119>:
.globl vector119
vector119:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $119
801074bf:	6a 77                	push   $0x77
  jmp alltraps
801074c1:	e9 72 f5 ff ff       	jmp    80106a38 <alltraps>

801074c6 <vector120>:
.globl vector120
vector120:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $120
801074c8:	6a 78                	push   $0x78
  jmp alltraps
801074ca:	e9 69 f5 ff ff       	jmp    80106a38 <alltraps>

801074cf <vector121>:
.globl vector121
vector121:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $121
801074d1:	6a 79                	push   $0x79
  jmp alltraps
801074d3:	e9 60 f5 ff ff       	jmp    80106a38 <alltraps>

801074d8 <vector122>:
.globl vector122
vector122:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $122
801074da:	6a 7a                	push   $0x7a
  jmp alltraps
801074dc:	e9 57 f5 ff ff       	jmp    80106a38 <alltraps>

801074e1 <vector123>:
.globl vector123
vector123:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $123
801074e3:	6a 7b                	push   $0x7b
  jmp alltraps
801074e5:	e9 4e f5 ff ff       	jmp    80106a38 <alltraps>

801074ea <vector124>:
.globl vector124
vector124:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $124
801074ec:	6a 7c                	push   $0x7c
  jmp alltraps
801074ee:	e9 45 f5 ff ff       	jmp    80106a38 <alltraps>

801074f3 <vector125>:
.globl vector125
vector125:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $125
801074f5:	6a 7d                	push   $0x7d
  jmp alltraps
801074f7:	e9 3c f5 ff ff       	jmp    80106a38 <alltraps>

801074fc <vector126>:
.globl vector126
vector126:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $126
801074fe:	6a 7e                	push   $0x7e
  jmp alltraps
80107500:	e9 33 f5 ff ff       	jmp    80106a38 <alltraps>

80107505 <vector127>:
.globl vector127
vector127:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $127
80107507:	6a 7f                	push   $0x7f
  jmp alltraps
80107509:	e9 2a f5 ff ff       	jmp    80106a38 <alltraps>

8010750e <vector128>:
.globl vector128
vector128:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $128
80107510:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107515:	e9 1e f5 ff ff       	jmp    80106a38 <alltraps>

8010751a <vector129>:
.globl vector129
vector129:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $129
8010751c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107521:	e9 12 f5 ff ff       	jmp    80106a38 <alltraps>

80107526 <vector130>:
.globl vector130
vector130:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $130
80107528:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010752d:	e9 06 f5 ff ff       	jmp    80106a38 <alltraps>

80107532 <vector131>:
.globl vector131
vector131:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $131
80107534:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107539:	e9 fa f4 ff ff       	jmp    80106a38 <alltraps>

8010753e <vector132>:
.globl vector132
vector132:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $132
80107540:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107545:	e9 ee f4 ff ff       	jmp    80106a38 <alltraps>

8010754a <vector133>:
.globl vector133
vector133:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $133
8010754c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107551:	e9 e2 f4 ff ff       	jmp    80106a38 <alltraps>

80107556 <vector134>:
.globl vector134
vector134:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $134
80107558:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010755d:	e9 d6 f4 ff ff       	jmp    80106a38 <alltraps>

80107562 <vector135>:
.globl vector135
vector135:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $135
80107564:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107569:	e9 ca f4 ff ff       	jmp    80106a38 <alltraps>

8010756e <vector136>:
.globl vector136
vector136:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $136
80107570:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107575:	e9 be f4 ff ff       	jmp    80106a38 <alltraps>

8010757a <vector137>:
.globl vector137
vector137:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $137
8010757c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107581:	e9 b2 f4 ff ff       	jmp    80106a38 <alltraps>

80107586 <vector138>:
.globl vector138
vector138:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $138
80107588:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010758d:	e9 a6 f4 ff ff       	jmp    80106a38 <alltraps>

80107592 <vector139>:
.globl vector139
vector139:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $139
80107594:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107599:	e9 9a f4 ff ff       	jmp    80106a38 <alltraps>

8010759e <vector140>:
.globl vector140
vector140:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $140
801075a0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801075a5:	e9 8e f4 ff ff       	jmp    80106a38 <alltraps>

801075aa <vector141>:
.globl vector141
vector141:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $141
801075ac:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801075b1:	e9 82 f4 ff ff       	jmp    80106a38 <alltraps>

801075b6 <vector142>:
.globl vector142
vector142:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $142
801075b8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801075bd:	e9 76 f4 ff ff       	jmp    80106a38 <alltraps>

801075c2 <vector143>:
.globl vector143
vector143:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $143
801075c4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801075c9:	e9 6a f4 ff ff       	jmp    80106a38 <alltraps>

801075ce <vector144>:
.globl vector144
vector144:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $144
801075d0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801075d5:	e9 5e f4 ff ff       	jmp    80106a38 <alltraps>

801075da <vector145>:
.globl vector145
vector145:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $145
801075dc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801075e1:	e9 52 f4 ff ff       	jmp    80106a38 <alltraps>

801075e6 <vector146>:
.globl vector146
vector146:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $146
801075e8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801075ed:	e9 46 f4 ff ff       	jmp    80106a38 <alltraps>

801075f2 <vector147>:
.globl vector147
vector147:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $147
801075f4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801075f9:	e9 3a f4 ff ff       	jmp    80106a38 <alltraps>

801075fe <vector148>:
.globl vector148
vector148:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $148
80107600:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107605:	e9 2e f4 ff ff       	jmp    80106a38 <alltraps>

8010760a <vector149>:
.globl vector149
vector149:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $149
8010760c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107611:	e9 22 f4 ff ff       	jmp    80106a38 <alltraps>

80107616 <vector150>:
.globl vector150
vector150:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $150
80107618:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010761d:	e9 16 f4 ff ff       	jmp    80106a38 <alltraps>

80107622 <vector151>:
.globl vector151
vector151:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $151
80107624:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107629:	e9 0a f4 ff ff       	jmp    80106a38 <alltraps>

8010762e <vector152>:
.globl vector152
vector152:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $152
80107630:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107635:	e9 fe f3 ff ff       	jmp    80106a38 <alltraps>

8010763a <vector153>:
.globl vector153
vector153:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $153
8010763c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107641:	e9 f2 f3 ff ff       	jmp    80106a38 <alltraps>

80107646 <vector154>:
.globl vector154
vector154:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $154
80107648:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010764d:	e9 e6 f3 ff ff       	jmp    80106a38 <alltraps>

80107652 <vector155>:
.globl vector155
vector155:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $155
80107654:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107659:	e9 da f3 ff ff       	jmp    80106a38 <alltraps>

8010765e <vector156>:
.globl vector156
vector156:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $156
80107660:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107665:	e9 ce f3 ff ff       	jmp    80106a38 <alltraps>

8010766a <vector157>:
.globl vector157
vector157:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $157
8010766c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107671:	e9 c2 f3 ff ff       	jmp    80106a38 <alltraps>

80107676 <vector158>:
.globl vector158
vector158:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $158
80107678:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010767d:	e9 b6 f3 ff ff       	jmp    80106a38 <alltraps>

80107682 <vector159>:
.globl vector159
vector159:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $159
80107684:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107689:	e9 aa f3 ff ff       	jmp    80106a38 <alltraps>

8010768e <vector160>:
.globl vector160
vector160:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $160
80107690:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107695:	e9 9e f3 ff ff       	jmp    80106a38 <alltraps>

8010769a <vector161>:
.globl vector161
vector161:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $161
8010769c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801076a1:	e9 92 f3 ff ff       	jmp    80106a38 <alltraps>

801076a6 <vector162>:
.globl vector162
vector162:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $162
801076a8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801076ad:	e9 86 f3 ff ff       	jmp    80106a38 <alltraps>

801076b2 <vector163>:
.globl vector163
vector163:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $163
801076b4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801076b9:	e9 7a f3 ff ff       	jmp    80106a38 <alltraps>

801076be <vector164>:
.globl vector164
vector164:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $164
801076c0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801076c5:	e9 6e f3 ff ff       	jmp    80106a38 <alltraps>

801076ca <vector165>:
.globl vector165
vector165:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $165
801076cc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801076d1:	e9 62 f3 ff ff       	jmp    80106a38 <alltraps>

801076d6 <vector166>:
.globl vector166
vector166:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $166
801076d8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801076dd:	e9 56 f3 ff ff       	jmp    80106a38 <alltraps>

801076e2 <vector167>:
.globl vector167
vector167:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $167
801076e4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801076e9:	e9 4a f3 ff ff       	jmp    80106a38 <alltraps>

801076ee <vector168>:
.globl vector168
vector168:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $168
801076f0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801076f5:	e9 3e f3 ff ff       	jmp    80106a38 <alltraps>

801076fa <vector169>:
.globl vector169
vector169:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $169
801076fc:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107701:	e9 32 f3 ff ff       	jmp    80106a38 <alltraps>

80107706 <vector170>:
.globl vector170
vector170:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $170
80107708:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010770d:	e9 26 f3 ff ff       	jmp    80106a38 <alltraps>

80107712 <vector171>:
.globl vector171
vector171:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $171
80107714:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107719:	e9 1a f3 ff ff       	jmp    80106a38 <alltraps>

8010771e <vector172>:
.globl vector172
vector172:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $172
80107720:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107725:	e9 0e f3 ff ff       	jmp    80106a38 <alltraps>

8010772a <vector173>:
.globl vector173
vector173:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $173
8010772c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107731:	e9 02 f3 ff ff       	jmp    80106a38 <alltraps>

80107736 <vector174>:
.globl vector174
vector174:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $174
80107738:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010773d:	e9 f6 f2 ff ff       	jmp    80106a38 <alltraps>

80107742 <vector175>:
.globl vector175
vector175:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $175
80107744:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107749:	e9 ea f2 ff ff       	jmp    80106a38 <alltraps>

8010774e <vector176>:
.globl vector176
vector176:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $176
80107750:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107755:	e9 de f2 ff ff       	jmp    80106a38 <alltraps>

8010775a <vector177>:
.globl vector177
vector177:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $177
8010775c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107761:	e9 d2 f2 ff ff       	jmp    80106a38 <alltraps>

80107766 <vector178>:
.globl vector178
vector178:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $178
80107768:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010776d:	e9 c6 f2 ff ff       	jmp    80106a38 <alltraps>

80107772 <vector179>:
.globl vector179
vector179:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $179
80107774:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107779:	e9 ba f2 ff ff       	jmp    80106a38 <alltraps>

8010777e <vector180>:
.globl vector180
vector180:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $180
80107780:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107785:	e9 ae f2 ff ff       	jmp    80106a38 <alltraps>

8010778a <vector181>:
.globl vector181
vector181:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $181
8010778c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107791:	e9 a2 f2 ff ff       	jmp    80106a38 <alltraps>

80107796 <vector182>:
.globl vector182
vector182:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $182
80107798:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010779d:	e9 96 f2 ff ff       	jmp    80106a38 <alltraps>

801077a2 <vector183>:
.globl vector183
vector183:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $183
801077a4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801077a9:	e9 8a f2 ff ff       	jmp    80106a38 <alltraps>

801077ae <vector184>:
.globl vector184
vector184:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $184
801077b0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801077b5:	e9 7e f2 ff ff       	jmp    80106a38 <alltraps>

801077ba <vector185>:
.globl vector185
vector185:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $185
801077bc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801077c1:	e9 72 f2 ff ff       	jmp    80106a38 <alltraps>

801077c6 <vector186>:
.globl vector186
vector186:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $186
801077c8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801077cd:	e9 66 f2 ff ff       	jmp    80106a38 <alltraps>

801077d2 <vector187>:
.globl vector187
vector187:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $187
801077d4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801077d9:	e9 5a f2 ff ff       	jmp    80106a38 <alltraps>

801077de <vector188>:
.globl vector188
vector188:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $188
801077e0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801077e5:	e9 4e f2 ff ff       	jmp    80106a38 <alltraps>

801077ea <vector189>:
.globl vector189
vector189:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $189
801077ec:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801077f1:	e9 42 f2 ff ff       	jmp    80106a38 <alltraps>

801077f6 <vector190>:
.globl vector190
vector190:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $190
801077f8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801077fd:	e9 36 f2 ff ff       	jmp    80106a38 <alltraps>

80107802 <vector191>:
.globl vector191
vector191:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $191
80107804:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107809:	e9 2a f2 ff ff       	jmp    80106a38 <alltraps>

8010780e <vector192>:
.globl vector192
vector192:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $192
80107810:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107815:	e9 1e f2 ff ff       	jmp    80106a38 <alltraps>

8010781a <vector193>:
.globl vector193
vector193:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $193
8010781c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107821:	e9 12 f2 ff ff       	jmp    80106a38 <alltraps>

80107826 <vector194>:
.globl vector194
vector194:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $194
80107828:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010782d:	e9 06 f2 ff ff       	jmp    80106a38 <alltraps>

80107832 <vector195>:
.globl vector195
vector195:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $195
80107834:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107839:	e9 fa f1 ff ff       	jmp    80106a38 <alltraps>

8010783e <vector196>:
.globl vector196
vector196:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $196
80107840:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107845:	e9 ee f1 ff ff       	jmp    80106a38 <alltraps>

8010784a <vector197>:
.globl vector197
vector197:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $197
8010784c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107851:	e9 e2 f1 ff ff       	jmp    80106a38 <alltraps>

80107856 <vector198>:
.globl vector198
vector198:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $198
80107858:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010785d:	e9 d6 f1 ff ff       	jmp    80106a38 <alltraps>

80107862 <vector199>:
.globl vector199
vector199:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $199
80107864:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107869:	e9 ca f1 ff ff       	jmp    80106a38 <alltraps>

8010786e <vector200>:
.globl vector200
vector200:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $200
80107870:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107875:	e9 be f1 ff ff       	jmp    80106a38 <alltraps>

8010787a <vector201>:
.globl vector201
vector201:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $201
8010787c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107881:	e9 b2 f1 ff ff       	jmp    80106a38 <alltraps>

80107886 <vector202>:
.globl vector202
vector202:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $202
80107888:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010788d:	e9 a6 f1 ff ff       	jmp    80106a38 <alltraps>

80107892 <vector203>:
.globl vector203
vector203:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $203
80107894:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107899:	e9 9a f1 ff ff       	jmp    80106a38 <alltraps>

8010789e <vector204>:
.globl vector204
vector204:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $204
801078a0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801078a5:	e9 8e f1 ff ff       	jmp    80106a38 <alltraps>

801078aa <vector205>:
.globl vector205
vector205:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $205
801078ac:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801078b1:	e9 82 f1 ff ff       	jmp    80106a38 <alltraps>

801078b6 <vector206>:
.globl vector206
vector206:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $206
801078b8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801078bd:	e9 76 f1 ff ff       	jmp    80106a38 <alltraps>

801078c2 <vector207>:
.globl vector207
vector207:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $207
801078c4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801078c9:	e9 6a f1 ff ff       	jmp    80106a38 <alltraps>

801078ce <vector208>:
.globl vector208
vector208:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $208
801078d0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801078d5:	e9 5e f1 ff ff       	jmp    80106a38 <alltraps>

801078da <vector209>:
.globl vector209
vector209:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $209
801078dc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801078e1:	e9 52 f1 ff ff       	jmp    80106a38 <alltraps>

801078e6 <vector210>:
.globl vector210
vector210:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $210
801078e8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801078ed:	e9 46 f1 ff ff       	jmp    80106a38 <alltraps>

801078f2 <vector211>:
.globl vector211
vector211:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $211
801078f4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801078f9:	e9 3a f1 ff ff       	jmp    80106a38 <alltraps>

801078fe <vector212>:
.globl vector212
vector212:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $212
80107900:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107905:	e9 2e f1 ff ff       	jmp    80106a38 <alltraps>

8010790a <vector213>:
.globl vector213
vector213:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $213
8010790c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107911:	e9 22 f1 ff ff       	jmp    80106a38 <alltraps>

80107916 <vector214>:
.globl vector214
vector214:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $214
80107918:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010791d:	e9 16 f1 ff ff       	jmp    80106a38 <alltraps>

80107922 <vector215>:
.globl vector215
vector215:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $215
80107924:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107929:	e9 0a f1 ff ff       	jmp    80106a38 <alltraps>

8010792e <vector216>:
.globl vector216
vector216:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $216
80107930:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107935:	e9 fe f0 ff ff       	jmp    80106a38 <alltraps>

8010793a <vector217>:
.globl vector217
vector217:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $217
8010793c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107941:	e9 f2 f0 ff ff       	jmp    80106a38 <alltraps>

80107946 <vector218>:
.globl vector218
vector218:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $218
80107948:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010794d:	e9 e6 f0 ff ff       	jmp    80106a38 <alltraps>

80107952 <vector219>:
.globl vector219
vector219:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $219
80107954:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107959:	e9 da f0 ff ff       	jmp    80106a38 <alltraps>

8010795e <vector220>:
.globl vector220
vector220:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $220
80107960:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107965:	e9 ce f0 ff ff       	jmp    80106a38 <alltraps>

8010796a <vector221>:
.globl vector221
vector221:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $221
8010796c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107971:	e9 c2 f0 ff ff       	jmp    80106a38 <alltraps>

80107976 <vector222>:
.globl vector222
vector222:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $222
80107978:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010797d:	e9 b6 f0 ff ff       	jmp    80106a38 <alltraps>

80107982 <vector223>:
.globl vector223
vector223:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $223
80107984:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107989:	e9 aa f0 ff ff       	jmp    80106a38 <alltraps>

8010798e <vector224>:
.globl vector224
vector224:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $224
80107990:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107995:	e9 9e f0 ff ff       	jmp    80106a38 <alltraps>

8010799a <vector225>:
.globl vector225
vector225:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $225
8010799c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801079a1:	e9 92 f0 ff ff       	jmp    80106a38 <alltraps>

801079a6 <vector226>:
.globl vector226
vector226:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $226
801079a8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801079ad:	e9 86 f0 ff ff       	jmp    80106a38 <alltraps>

801079b2 <vector227>:
.globl vector227
vector227:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $227
801079b4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801079b9:	e9 7a f0 ff ff       	jmp    80106a38 <alltraps>

801079be <vector228>:
.globl vector228
vector228:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $228
801079c0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801079c5:	e9 6e f0 ff ff       	jmp    80106a38 <alltraps>

801079ca <vector229>:
.globl vector229
vector229:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $229
801079cc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801079d1:	e9 62 f0 ff ff       	jmp    80106a38 <alltraps>

801079d6 <vector230>:
.globl vector230
vector230:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $230
801079d8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801079dd:	e9 56 f0 ff ff       	jmp    80106a38 <alltraps>

801079e2 <vector231>:
.globl vector231
vector231:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $231
801079e4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801079e9:	e9 4a f0 ff ff       	jmp    80106a38 <alltraps>

801079ee <vector232>:
.globl vector232
vector232:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $232
801079f0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801079f5:	e9 3e f0 ff ff       	jmp    80106a38 <alltraps>

801079fa <vector233>:
.globl vector233
vector233:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $233
801079fc:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a01:	e9 32 f0 ff ff       	jmp    80106a38 <alltraps>

80107a06 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $234
80107a08:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a0d:	e9 26 f0 ff ff       	jmp    80106a38 <alltraps>

80107a12 <vector235>:
.globl vector235
vector235:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $235
80107a14:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a19:	e9 1a f0 ff ff       	jmp    80106a38 <alltraps>

80107a1e <vector236>:
.globl vector236
vector236:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $236
80107a20:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107a25:	e9 0e f0 ff ff       	jmp    80106a38 <alltraps>

80107a2a <vector237>:
.globl vector237
vector237:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $237
80107a2c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107a31:	e9 02 f0 ff ff       	jmp    80106a38 <alltraps>

80107a36 <vector238>:
.globl vector238
vector238:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $238
80107a38:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107a3d:	e9 f6 ef ff ff       	jmp    80106a38 <alltraps>

80107a42 <vector239>:
.globl vector239
vector239:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $239
80107a44:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107a49:	e9 ea ef ff ff       	jmp    80106a38 <alltraps>

80107a4e <vector240>:
.globl vector240
vector240:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $240
80107a50:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107a55:	e9 de ef ff ff       	jmp    80106a38 <alltraps>

80107a5a <vector241>:
.globl vector241
vector241:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $241
80107a5c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a61:	e9 d2 ef ff ff       	jmp    80106a38 <alltraps>

80107a66 <vector242>:
.globl vector242
vector242:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $242
80107a68:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107a6d:	e9 c6 ef ff ff       	jmp    80106a38 <alltraps>

80107a72 <vector243>:
.globl vector243
vector243:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $243
80107a74:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107a79:	e9 ba ef ff ff       	jmp    80106a38 <alltraps>

80107a7e <vector244>:
.globl vector244
vector244:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $244
80107a80:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107a85:	e9 ae ef ff ff       	jmp    80106a38 <alltraps>

80107a8a <vector245>:
.globl vector245
vector245:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $245
80107a8c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a91:	e9 a2 ef ff ff       	jmp    80106a38 <alltraps>

80107a96 <vector246>:
.globl vector246
vector246:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $246
80107a98:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a9d:	e9 96 ef ff ff       	jmp    80106a38 <alltraps>

80107aa2 <vector247>:
.globl vector247
vector247:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $247
80107aa4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107aa9:	e9 8a ef ff ff       	jmp    80106a38 <alltraps>

80107aae <vector248>:
.globl vector248
vector248:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $248
80107ab0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107ab5:	e9 7e ef ff ff       	jmp    80106a38 <alltraps>

80107aba <vector249>:
.globl vector249
vector249:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $249
80107abc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107ac1:	e9 72 ef ff ff       	jmp    80106a38 <alltraps>

80107ac6 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $250
80107ac8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107acd:	e9 66 ef ff ff       	jmp    80106a38 <alltraps>

80107ad2 <vector251>:
.globl vector251
vector251:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $251
80107ad4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ad9:	e9 5a ef ff ff       	jmp    80106a38 <alltraps>

80107ade <vector252>:
.globl vector252
vector252:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $252
80107ae0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107ae5:	e9 4e ef ff ff       	jmp    80106a38 <alltraps>

80107aea <vector253>:
.globl vector253
vector253:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $253
80107aec:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107af1:	e9 42 ef ff ff       	jmp    80106a38 <alltraps>

80107af6 <vector254>:
.globl vector254
vector254:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $254
80107af8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107afd:	e9 36 ef ff ff       	jmp    80106a38 <alltraps>

80107b02 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $255
80107b04:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b09:	e9 2a ef ff ff       	jmp    80106a38 <alltraps>

80107b0e <lgdt>:
{
80107b0e:	55                   	push   %ebp
80107b0f:	89 e5                	mov    %esp,%ebp
80107b11:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107b14:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b17:	83 e8 01             	sub    $0x1,%eax
80107b1a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b21:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107b25:	8b 45 08             	mov    0x8(%ebp),%eax
80107b28:	c1 e8 10             	shr    $0x10,%eax
80107b2b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107b2f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107b32:	0f 01 10             	lgdtl  (%eax)
}
80107b35:	90                   	nop
80107b36:	c9                   	leave  
80107b37:	c3                   	ret    

80107b38 <ltr>:
{
80107b38:	55                   	push   %ebp
80107b39:	89 e5                	mov    %esp,%ebp
80107b3b:	83 ec 04             	sub    $0x4,%esp
80107b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b41:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107b45:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b49:	0f 00 d8             	ltr    %ax
}
80107b4c:	90                   	nop
80107b4d:	c9                   	leave  
80107b4e:	c3                   	ret    

80107b4f <lcr3>:

static inline void
lcr3(uint val)
{
80107b4f:	55                   	push   %ebp
80107b50:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b52:	8b 45 08             	mov    0x8(%ebp),%eax
80107b55:	0f 22 d8             	mov    %eax,%cr3
}
80107b58:	90                   	nop
80107b59:	5d                   	pop    %ebp
80107b5a:	c3                   	ret    

80107b5b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b5b:	f3 0f 1e fb          	endbr32 
80107b5f:	55                   	push   %ebp
80107b60:	89 e5                	mov    %esp,%ebp
80107b62:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107b65:	e8 92 c8 ff ff       	call   801043fc <cpuid>
80107b6a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107b70:	05 20 48 11 80       	add    $0x80114820,%eax
80107b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b84:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b94:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b98:	83 e2 f0             	and    $0xfffffff0,%edx
80107b9b:	83 ca 0a             	or     $0xa,%edx
80107b9e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ba8:	83 ca 10             	or     $0x10,%edx
80107bab:	88 50 7d             	mov    %dl,0x7d(%eax)
80107bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107bb5:	83 e2 9f             	and    $0xffffff9f,%edx
80107bb8:	88 50 7d             	mov    %dl,0x7d(%eax)
80107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbe:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107bc2:	83 ca 80             	or     $0xffffff80,%edx
80107bc5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bcf:	83 ca 0f             	or     $0xf,%edx
80107bd2:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bdc:	83 e2 ef             	and    $0xffffffef,%edx
80107bdf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107be9:	83 e2 df             	and    $0xffffffdf,%edx
80107bec:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bf6:	83 ca 40             	or     $0x40,%edx
80107bf9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c03:	83 ca 80             	or     $0xffffff80,%edx
80107c06:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107c1a:	ff ff 
80107c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107c26:	00 00 
80107c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c3c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c3f:	83 ca 02             	or     $0x2,%edx
80107c42:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c52:	83 ca 10             	or     $0x10,%edx
80107c55:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c65:	83 e2 9f             	and    $0xffffff9f,%edx
80107c68:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c78:	83 ca 80             	or     $0xffffff80,%edx
80107c7b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c8b:	83 ca 0f             	or     $0xf,%edx
80107c8e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c97:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c9e:	83 e2 ef             	and    $0xffffffef,%edx
80107ca1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cb1:	83 e2 df             	and    $0xffffffdf,%edx
80107cb4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cc4:	83 ca 40             	or     $0x40,%edx
80107cc7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cd7:	83 ca 80             	or     $0xffffff80,%edx
80107cda:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107cf4:	ff ff 
80107cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107d00:	00 00 
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d16:	83 e2 f0             	and    $0xfffffff0,%edx
80107d19:	83 ca 0a             	or     $0xa,%edx
80107d1c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d25:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d2c:	83 ca 10             	or     $0x10,%edx
80107d2f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d3f:	83 ca 60             	or     $0x60,%edx
80107d42:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d52:	83 ca 80             	or     $0xffffff80,%edx
80107d55:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d65:	83 ca 0f             	or     $0xf,%edx
80107d68:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d78:	83 e2 ef             	and    $0xffffffef,%edx
80107d7b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d8b:	83 e2 df             	and    $0xffffffdf,%edx
80107d8e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d97:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d9e:	83 ca 40             	or     $0x40,%edx
80107da1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daa:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107db1:	83 ca 80             	or     $0xffffff80,%edx
80107db4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbd:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107dce:	ff ff 
80107dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107dda:	00 00 
80107ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddf:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107df0:	83 e2 f0             	and    $0xfffffff0,%edx
80107df3:	83 ca 02             	or     $0x2,%edx
80107df6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e06:	83 ca 10             	or     $0x10,%edx
80107e09:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e19:	83 ca 60             	or     $0x60,%edx
80107e1c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e2c:	83 ca 80             	or     $0xffffff80,%edx
80107e2f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e3f:	83 ca 0f             	or     $0xf,%edx
80107e42:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e52:	83 e2 ef             	and    $0xffffffef,%edx
80107e55:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e65:	83 e2 df             	and    $0xffffffdf,%edx
80107e68:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e78:	83 ca 40             	or     $0x40,%edx
80107e7b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e8b:	83 ca 80             	or     $0xffffff80,%edx
80107e8e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea1:	83 c0 70             	add    $0x70,%eax
80107ea4:	83 ec 08             	sub    $0x8,%esp
80107ea7:	6a 30                	push   $0x30
80107ea9:	50                   	push   %eax
80107eaa:	e8 5f fc ff ff       	call   80107b0e <lgdt>
80107eaf:	83 c4 10             	add    $0x10,%esp
}
80107eb2:	90                   	nop
80107eb3:	c9                   	leave  
80107eb4:	c3                   	ret    

80107eb5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eb5:	f3 0f 1e fb          	endbr32 
80107eb9:	55                   	push   %ebp
80107eba:	89 e5                	mov    %esp,%ebp
80107ebc:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ec2:	c1 e8 16             	shr    $0x16,%eax
80107ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80107ecf:	01 d0                	add    %edx,%eax
80107ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){//No need to check PTE_E here.
80107ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed7:	8b 00                	mov    (%eax),%eax
80107ed9:	83 e0 01             	and    $0x1,%eax
80107edc:	85 c0                	test   %eax,%eax
80107ede:	74 14                	je     80107ef4 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee3:	8b 00                	mov    (%eax),%eax
80107ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eea:	05 00 00 00 80       	add    $0x80000000,%eax
80107eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ef2:	eb 42                	jmp    80107f36 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ef4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ef8:	74 0e                	je     80107f08 <walkpgdir+0x53>
80107efa:	e8 fa ae ff ff       	call   80102df9 <kalloc>
80107eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f06:	75 07                	jne    80107f0f <walkpgdir+0x5a>
      return 0;
80107f08:	b8 00 00 00 00       	mov    $0x0,%eax
80107f0d:	eb 3e                	jmp    80107f4d <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f0f:	83 ec 04             	sub    $0x4,%esp
80107f12:	68 00 10 00 00       	push   $0x1000
80107f17:	6a 00                	push   $0x0
80107f19:	ff 75 f4             	pushl  -0xc(%ebp)
80107f1c:	e8 b2 d5 ff ff       	call   801054d3 <memset>
80107f21:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f27:	05 00 00 00 80       	add    $0x80000000,%eax
80107f2c:	83 c8 07             	or     $0x7,%eax
80107f2f:	89 c2                	mov    %eax,%edx
80107f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f34:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f39:	c1 e8 0c             	shr    $0xc,%eax
80107f3c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4b:	01 d0                	add    %edx,%eax
}
80107f4d:	c9                   	leave  
80107f4e:	c3                   	ret    

80107f4f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f4f:	f3 0f 1e fb          	endbr32 
80107f53:	55                   	push   %ebp
80107f54:	89 e5                	mov    %esp,%ebp
80107f56:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f64:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f67:	8b 45 10             	mov    0x10(%ebp),%eax
80107f6a:	01 d0                	add    %edx,%eax
80107f6c:	83 e8 01             	sub    $0x1,%eax
80107f6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f77:	83 ec 04             	sub    $0x4,%esp
80107f7a:	6a 01                	push   $0x1
80107f7c:	ff 75 f4             	pushl  -0xc(%ebp)
80107f7f:	ff 75 08             	pushl  0x8(%ebp)
80107f82:	e8 2e ff ff ff       	call   80107eb5 <walkpgdir>
80107f87:	83 c4 10             	add    $0x10,%esp
80107f8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f8d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f91:	75 07                	jne    80107f9a <mappages+0x4b>
      return -1;
80107f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f98:	eb 6f                	jmp    80108009 <mappages+0xba>
    if(*pte & (PTE_P | PTE_E))
80107f9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f9d:	8b 00                	mov    (%eax),%eax
80107f9f:	25 01 04 00 00       	and    $0x401,%eax
80107fa4:	85 c0                	test   %eax,%eax
80107fa6:	74 0d                	je     80107fb5 <mappages+0x66>
      panic("remap");
80107fa8:	83 ec 0c             	sub    $0xc,%esp
80107fab:	68 3c 93 10 80       	push   $0x8010933c
80107fb0:	e8 53 86 ff ff       	call   80100608 <panic>
    
    //"perm" is just the lower 12 bits of the PTE
    //if encrypted, then ensure that PTE_P is not set
    //This is somewhat redundant. If our code is correct,
    //we should just be able to say pa | perm
    if (perm & PTE_E)
80107fb5:	8b 45 18             	mov    0x18(%ebp),%eax
80107fb8:	25 00 04 00 00       	and    $0x400,%eax
80107fbd:	85 c0                	test   %eax,%eax
80107fbf:	74 17                	je     80107fd8 <mappages+0x89>
      *pte = (pa | perm | PTE_E) & ~PTE_P;
80107fc1:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc4:	0b 45 14             	or     0x14(%ebp),%eax
80107fc7:	25 fe fb ff ff       	and    $0xfffffbfe,%eax
80107fcc:	80 cc 04             	or     $0x4,%ah
80107fcf:	89 c2                	mov    %eax,%edx
80107fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fd4:	89 10                	mov    %edx,(%eax)
80107fd6:	eb 10                	jmp    80107fe8 <mappages+0x99>
    else
      *pte = pa | perm | PTE_P;
80107fd8:	8b 45 18             	mov    0x18(%ebp),%eax
80107fdb:	0b 45 14             	or     0x14(%ebp),%eax
80107fde:	83 c8 01             	or     $0x1,%eax
80107fe1:	89 c2                	mov    %eax,%edx
80107fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe6:	89 10                	mov    %edx,(%eax)


    if(a == last)
80107fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107feb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fee:	74 13                	je     80108003 <mappages+0xb4>
      break;
    a += PGSIZE;
80107ff0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ff7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ffe:	e9 74 ff ff ff       	jmp    80107f77 <mappages+0x28>
      break;
80108003:	90                   	nop
  }
  return 0;
80108004:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108009:	c9                   	leave  
8010800a:	c3                   	ret    

8010800b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010800b:	f3 0f 1e fb          	endbr32 
8010800f:	55                   	push   %ebp
80108010:	89 e5                	mov    %esp,%ebp
80108012:	53                   	push   %ebx
80108013:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108016:	e8 de ad ff ff       	call   80102df9 <kalloc>
8010801b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010801e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108022:	75 07                	jne    8010802b <setupkvm+0x20>
    return 0;
80108024:	b8 00 00 00 00       	mov    $0x0,%eax
80108029:	eb 78                	jmp    801080a3 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
8010802b:	83 ec 04             	sub    $0x4,%esp
8010802e:	68 00 10 00 00       	push   $0x1000
80108033:	6a 00                	push   $0x0
80108035:	ff 75 f0             	pushl  -0x10(%ebp)
80108038:	e8 96 d4 ff ff       	call   801054d3 <memset>
8010803d:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108040:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108047:	eb 4e                	jmp    80108097 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804c:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010804f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108052:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	8b 58 08             	mov    0x8(%eax),%ebx
8010805b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805e:	8b 40 04             	mov    0x4(%eax),%eax
80108061:	29 c3                	sub    %eax,%ebx
80108063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108066:	8b 00                	mov    (%eax),%eax
80108068:	83 ec 0c             	sub    $0xc,%esp
8010806b:	51                   	push   %ecx
8010806c:	52                   	push   %edx
8010806d:	53                   	push   %ebx
8010806e:	50                   	push   %eax
8010806f:	ff 75 f0             	pushl  -0x10(%ebp)
80108072:	e8 d8 fe ff ff       	call   80107f4f <mappages>
80108077:	83 c4 20             	add    $0x20,%esp
8010807a:	85 c0                	test   %eax,%eax
8010807c:	79 15                	jns    80108093 <setupkvm+0x88>
      freevm(pgdir);
8010807e:	83 ec 0c             	sub    $0xc,%esp
80108081:	ff 75 f0             	pushl  -0x10(%ebp)
80108084:	e8 13 05 00 00       	call   8010859c <freevm>
80108089:	83 c4 10             	add    $0x10,%esp
      return 0;
8010808c:	b8 00 00 00 00       	mov    $0x0,%eax
80108091:	eb 10                	jmp    801080a3 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108093:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108097:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
8010809e:	72 a9                	jb     80108049 <setupkvm+0x3e>
    }
  return pgdir;
801080a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080a6:	c9                   	leave  
801080a7:	c3                   	ret    

801080a8 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080a8:	f3 0f 1e fb          	endbr32 
801080ac:	55                   	push   %ebp
801080ad:	89 e5                	mov    %esp,%ebp
801080af:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080b2:	e8 54 ff ff ff       	call   8010800b <setupkvm>
801080b7:	a3 44 75 11 80       	mov    %eax,0x80117544
  switchkvm();
801080bc:	e8 03 00 00 00       	call   801080c4 <switchkvm>
}
801080c1:	90                   	nop
801080c2:	c9                   	leave  
801080c3:	c3                   	ret    

801080c4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080c4:	f3 0f 1e fb          	endbr32 
801080c8:	55                   	push   %ebp
801080c9:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801080cb:	a1 44 75 11 80       	mov    0x80117544,%eax
801080d0:	05 00 00 00 80       	add    $0x80000000,%eax
801080d5:	50                   	push   %eax
801080d6:	e8 74 fa ff ff       	call   80107b4f <lcr3>
801080db:	83 c4 04             	add    $0x4,%esp
}
801080de:	90                   	nop
801080df:	c9                   	leave  
801080e0:	c3                   	ret    

801080e1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080e1:	f3 0f 1e fb          	endbr32 
801080e5:	55                   	push   %ebp
801080e6:	89 e5                	mov    %esp,%ebp
801080e8:	56                   	push   %esi
801080e9:	53                   	push   %ebx
801080ea:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801080ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080f1:	75 0d                	jne    80108100 <switchuvm+0x1f>
    panic("switchuvm: no process");
801080f3:	83 ec 0c             	sub    $0xc,%esp
801080f6:	68 42 93 10 80       	push   $0x80109342
801080fb:	e8 08 85 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108100:	8b 45 08             	mov    0x8(%ebp),%eax
80108103:	8b 40 08             	mov    0x8(%eax),%eax
80108106:	85 c0                	test   %eax,%eax
80108108:	75 0d                	jne    80108117 <switchuvm+0x36>
    panic("switchuvm: no kstack");
8010810a:	83 ec 0c             	sub    $0xc,%esp
8010810d:	68 58 93 10 80       	push   $0x80109358
80108112:	e8 f1 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108117:	8b 45 08             	mov    0x8(%ebp),%eax
8010811a:	8b 40 04             	mov    0x4(%eax),%eax
8010811d:	85 c0                	test   %eax,%eax
8010811f:	75 0d                	jne    8010812e <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80108121:	83 ec 0c             	sub    $0xc,%esp
80108124:	68 6d 93 10 80       	push   $0x8010936d
80108129:	e8 da 84 ff ff       	call   80100608 <panic>

  pushcli();
8010812e:	e8 8d d2 ff ff       	call   801053c0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108133:	e8 e3 c2 ff ff       	call   8010441b <mycpu>
80108138:	89 c3                	mov    %eax,%ebx
8010813a:	e8 dc c2 ff ff       	call   8010441b <mycpu>
8010813f:	83 c0 08             	add    $0x8,%eax
80108142:	89 c6                	mov    %eax,%esi
80108144:	e8 d2 c2 ff ff       	call   8010441b <mycpu>
80108149:	83 c0 08             	add    $0x8,%eax
8010814c:	c1 e8 10             	shr    $0x10,%eax
8010814f:	88 45 f7             	mov    %al,-0x9(%ebp)
80108152:	e8 c4 c2 ff ff       	call   8010441b <mycpu>
80108157:	83 c0 08             	add    $0x8,%eax
8010815a:	c1 e8 18             	shr    $0x18,%eax
8010815d:	89 c2                	mov    %eax,%edx
8010815f:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108166:	67 00 
80108168:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010816f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108173:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108179:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108180:	83 e0 f0             	and    $0xfffffff0,%eax
80108183:	83 c8 09             	or     $0x9,%eax
80108186:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010818c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108193:	83 c8 10             	or     $0x10,%eax
80108196:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010819c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801081a3:	83 e0 9f             	and    $0xffffff9f,%eax
801081a6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801081ac:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801081b3:	83 c8 80             	or     $0xffffff80,%eax
801081b6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801081bc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081c3:	83 e0 f0             	and    $0xfffffff0,%eax
801081c6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081cc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081d3:	83 e0 ef             	and    $0xffffffef,%eax
801081d6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081dc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081e3:	83 e0 df             	and    $0xffffffdf,%eax
801081e6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081ec:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081f3:	83 c8 40             	or     $0x40,%eax
801081f6:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081fc:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108203:	83 e0 7f             	and    $0x7f,%eax
80108206:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010820c:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108212:	e8 04 c2 ff ff       	call   8010441b <mycpu>
80108217:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010821e:	83 e2 ef             	and    $0xffffffef,%edx
80108221:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108227:	e8 ef c1 ff ff       	call   8010441b <mycpu>
8010822c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108232:	8b 45 08             	mov    0x8(%ebp),%eax
80108235:	8b 40 08             	mov    0x8(%eax),%eax
80108238:	89 c3                	mov    %eax,%ebx
8010823a:	e8 dc c1 ff ff       	call   8010441b <mycpu>
8010823f:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108245:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108248:	e8 ce c1 ff ff       	call   8010441b <mycpu>
8010824d:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108253:	83 ec 0c             	sub    $0xc,%esp
80108256:	6a 28                	push   $0x28
80108258:	e8 db f8 ff ff       	call   80107b38 <ltr>
8010825d:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108260:	8b 45 08             	mov    0x8(%ebp),%eax
80108263:	8b 40 04             	mov    0x4(%eax),%eax
80108266:	05 00 00 00 80       	add    $0x80000000,%eax
8010826b:	83 ec 0c             	sub    $0xc,%esp
8010826e:	50                   	push   %eax
8010826f:	e8 db f8 ff ff       	call   80107b4f <lcr3>
80108274:	83 c4 10             	add    $0x10,%esp
  popcli();
80108277:	e8 95 d1 ff ff       	call   80105411 <popcli>
}
8010827c:	90                   	nop
8010827d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108280:	5b                   	pop    %ebx
80108281:	5e                   	pop    %esi
80108282:	5d                   	pop    %ebp
80108283:	c3                   	ret    

80108284 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108284:	f3 0f 1e fb          	endbr32 
80108288:	55                   	push   %ebp
80108289:	89 e5                	mov    %esp,%ebp
8010828b:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010828e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108295:	76 0d                	jbe    801082a4 <inituvm+0x20>
    panic("inituvm: more than a page");
80108297:	83 ec 0c             	sub    $0xc,%esp
8010829a:	68 81 93 10 80       	push   $0x80109381
8010829f:	e8 64 83 ff ff       	call   80100608 <panic>
  mem = kalloc();
801082a4:	e8 50 ab ff ff       	call   80102df9 <kalloc>
801082a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082ac:	83 ec 04             	sub    $0x4,%esp
801082af:	68 00 10 00 00       	push   $0x1000
801082b4:	6a 00                	push   $0x0
801082b6:	ff 75 f4             	pushl  -0xc(%ebp)
801082b9:	e8 15 d2 ff ff       	call   801054d3 <memset>
801082be:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801082c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c4:	05 00 00 00 80       	add    $0x80000000,%eax
801082c9:	83 ec 0c             	sub    $0xc,%esp
801082cc:	6a 06                	push   $0x6
801082ce:	50                   	push   %eax
801082cf:	68 00 10 00 00       	push   $0x1000
801082d4:	6a 00                	push   $0x0
801082d6:	ff 75 08             	pushl  0x8(%ebp)
801082d9:	e8 71 fc ff ff       	call   80107f4f <mappages>
801082de:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801082e1:	83 ec 04             	sub    $0x4,%esp
801082e4:	ff 75 10             	pushl  0x10(%ebp)
801082e7:	ff 75 0c             	pushl  0xc(%ebp)
801082ea:	ff 75 f4             	pushl  -0xc(%ebp)
801082ed:	e8 a8 d2 ff ff       	call   8010559a <memmove>
801082f2:	83 c4 10             	add    $0x10,%esp
}
801082f5:	90                   	nop
801082f6:	c9                   	leave  
801082f7:	c3                   	ret    

801082f8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082f8:	f3 0f 1e fb          	endbr32 
801082fc:	55                   	push   %ebp
801082fd:	89 e5                	mov    %esp,%ebp
801082ff:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108302:	8b 45 0c             	mov    0xc(%ebp),%eax
80108305:	25 ff 0f 00 00       	and    $0xfff,%eax
8010830a:	85 c0                	test   %eax,%eax
8010830c:	74 0d                	je     8010831b <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
8010830e:	83 ec 0c             	sub    $0xc,%esp
80108311:	68 9c 93 10 80       	push   $0x8010939c
80108316:	e8 ed 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010831b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108322:	e9 8f 00 00 00       	jmp    801083b6 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108327:	8b 55 0c             	mov    0xc(%ebp),%edx
8010832a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832d:	01 d0                	add    %edx,%eax
8010832f:	83 ec 04             	sub    $0x4,%esp
80108332:	6a 00                	push   $0x0
80108334:	50                   	push   %eax
80108335:	ff 75 08             	pushl  0x8(%ebp)
80108338:	e8 78 fb ff ff       	call   80107eb5 <walkpgdir>
8010833d:	83 c4 10             	add    $0x10,%esp
80108340:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108343:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108347:	75 0d                	jne    80108356 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108349:	83 ec 0c             	sub    $0xc,%esp
8010834c:	68 bf 93 10 80       	push   $0x801093bf
80108351:	e8 b2 82 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108356:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108359:	8b 00                	mov    (%eax),%eax
8010835b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108360:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108363:	8b 45 18             	mov    0x18(%ebp),%eax
80108366:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108369:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010836e:	77 0b                	ja     8010837b <loaduvm+0x83>
      n = sz - i;
80108370:	8b 45 18             	mov    0x18(%ebp),%eax
80108373:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108376:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108379:	eb 07                	jmp    80108382 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010837b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108382:	8b 55 14             	mov    0x14(%ebp),%edx
80108385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108388:	01 d0                	add    %edx,%eax
8010838a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010838d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108393:	ff 75 f0             	pushl  -0x10(%ebp)
80108396:	50                   	push   %eax
80108397:	52                   	push   %edx
80108398:	ff 75 10             	pushl  0x10(%ebp)
8010839b:	e8 71 9c ff ff       	call   80102011 <readi>
801083a0:	83 c4 10             	add    $0x10,%esp
801083a3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801083a6:	74 07                	je     801083af <loaduvm+0xb7>
      return -1;
801083a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083ad:	eb 18                	jmp    801083c7 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801083af:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b9:	3b 45 18             	cmp    0x18(%ebp),%eax
801083bc:	0f 82 65 ff ff ff    	jb     80108327 <loaduvm+0x2f>
  }
  return 0;
801083c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c7:	c9                   	leave  
801083c8:	c3                   	ret    

801083c9 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c9:	f3 0f 1e fb          	endbr32 
801083cd:	55                   	push   %ebp
801083ce:	89 e5                	mov    %esp,%ebp
801083d0:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083d3:	8b 45 10             	mov    0x10(%ebp),%eax
801083d6:	85 c0                	test   %eax,%eax
801083d8:	79 0a                	jns    801083e4 <allocuvm+0x1b>
    return 0;
801083da:	b8 00 00 00 00       	mov    $0x0,%eax
801083df:	e9 ec 00 00 00       	jmp    801084d0 <allocuvm+0x107>
  if(newsz < oldsz)
801083e4:	8b 45 10             	mov    0x10(%ebp),%eax
801083e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083ea:	73 08                	jae    801083f4 <allocuvm+0x2b>
    return oldsz;
801083ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ef:	e9 dc 00 00 00       	jmp    801084d0 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801083f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f7:	05 ff 0f 00 00       	add    $0xfff,%eax
801083fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108401:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108404:	e9 b8 00 00 00       	jmp    801084c1 <allocuvm+0xf8>
    mem = kalloc();
80108409:	e8 eb a9 ff ff       	call   80102df9 <kalloc>
8010840e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108411:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108415:	75 2e                	jne    80108445 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108417:	83 ec 0c             	sub    $0xc,%esp
8010841a:	68 dd 93 10 80       	push   $0x801093dd
8010841f:	e8 f4 7f ff ff       	call   80100418 <cprintf>
80108424:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108427:	83 ec 04             	sub    $0x4,%esp
8010842a:	ff 75 0c             	pushl  0xc(%ebp)
8010842d:	ff 75 10             	pushl  0x10(%ebp)
80108430:	ff 75 08             	pushl  0x8(%ebp)
80108433:	e8 9a 00 00 00       	call   801084d2 <deallocuvm>
80108438:	83 c4 10             	add    $0x10,%esp
      return 0;
8010843b:	b8 00 00 00 00       	mov    $0x0,%eax
80108440:	e9 8b 00 00 00       	jmp    801084d0 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108445:	83 ec 04             	sub    $0x4,%esp
80108448:	68 00 10 00 00       	push   $0x1000
8010844d:	6a 00                	push   $0x0
8010844f:	ff 75 f0             	pushl  -0x10(%ebp)
80108452:	e8 7c d0 ff ff       	call   801054d3 <memset>
80108457:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010845a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010845d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108466:	83 ec 0c             	sub    $0xc,%esp
80108469:	6a 06                	push   $0x6
8010846b:	52                   	push   %edx
8010846c:	68 00 10 00 00       	push   $0x1000
80108471:	50                   	push   %eax
80108472:	ff 75 08             	pushl  0x8(%ebp)
80108475:	e8 d5 fa ff ff       	call   80107f4f <mappages>
8010847a:	83 c4 20             	add    $0x20,%esp
8010847d:	85 c0                	test   %eax,%eax
8010847f:	79 39                	jns    801084ba <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108481:	83 ec 0c             	sub    $0xc,%esp
80108484:	68 f5 93 10 80       	push   $0x801093f5
80108489:	e8 8a 7f ff ff       	call   80100418 <cprintf>
8010848e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108491:	83 ec 04             	sub    $0x4,%esp
80108494:	ff 75 0c             	pushl  0xc(%ebp)
80108497:	ff 75 10             	pushl  0x10(%ebp)
8010849a:	ff 75 08             	pushl  0x8(%ebp)
8010849d:	e8 30 00 00 00       	call   801084d2 <deallocuvm>
801084a2:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801084a5:	83 ec 0c             	sub    $0xc,%esp
801084a8:	ff 75 f0             	pushl  -0x10(%ebp)
801084ab:	e8 ab a8 ff ff       	call   80102d5b <kfree>
801084b0:	83 c4 10             	add    $0x10,%esp
      return 0;
801084b3:	b8 00 00 00 00       	mov    $0x0,%eax
801084b8:	eb 16                	jmp    801084d0 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801084ba:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801084c7:	0f 82 3c ff ff ff    	jb     80108409 <allocuvm+0x40>
    }
  }
  return newsz;
801084cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084d0:	c9                   	leave  
801084d1:	c3                   	ret    

801084d2 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084d2:	f3 0f 1e fb          	endbr32 
801084d6:	55                   	push   %ebp
801084d7:	89 e5                	mov    %esp,%ebp
801084d9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084dc:	8b 45 10             	mov    0x10(%ebp),%eax
801084df:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084e2:	72 08                	jb     801084ec <deallocuvm+0x1a>
    return oldsz;
801084e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e7:	e9 ae 00 00 00       	jmp    8010859a <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
801084ec:	8b 45 10             	mov    0x10(%ebp),%eax
801084ef:	05 ff 0f 00 00       	add    $0xfff,%eax
801084f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084fc:	e9 8a 00 00 00       	jmp    8010858b <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108504:	83 ec 04             	sub    $0x4,%esp
80108507:	6a 00                	push   $0x0
80108509:	50                   	push   %eax
8010850a:	ff 75 08             	pushl  0x8(%ebp)
8010850d:	e8 a3 f9 ff ff       	call   80107eb5 <walkpgdir>
80108512:	83 c4 10             	add    $0x10,%esp
80108515:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108518:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010851c:	75 16                	jne    80108534 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010851e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108521:	c1 e8 16             	shr    $0x16,%eax
80108524:	83 c0 01             	add    $0x1,%eax
80108527:	c1 e0 16             	shl    $0x16,%eax
8010852a:	2d 00 10 00 00       	sub    $0x1000,%eax
8010852f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108532:	eb 50                	jmp    80108584 <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
80108534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108537:	8b 00                	mov    (%eax),%eax
80108539:	25 01 04 00 00       	and    $0x401,%eax
8010853e:	85 c0                	test   %eax,%eax
80108540:	74 42                	je     80108584 <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
80108542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108545:	8b 00                	mov    (%eax),%eax
80108547:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010854c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010854f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108553:	75 0d                	jne    80108562 <deallocuvm+0x90>
        panic("kfree");
80108555:	83 ec 0c             	sub    $0xc,%esp
80108558:	68 11 94 10 80       	push   $0x80109411
8010855d:	e8 a6 80 ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
80108562:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108565:	05 00 00 00 80       	add    $0x80000000,%eax
8010856a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010856d:	83 ec 0c             	sub    $0xc,%esp
80108570:	ff 75 e8             	pushl  -0x18(%ebp)
80108573:	e8 e3 a7 ff ff       	call   80102d5b <kfree>
80108578:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010857b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108584:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010858b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108591:	0f 82 6a ff ff ff    	jb     80108501 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108597:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010859a:	c9                   	leave  
8010859b:	c3                   	ret    

8010859c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010859c:	f3 0f 1e fb          	endbr32 
801085a0:	55                   	push   %ebp
801085a1:	89 e5                	mov    %esp,%ebp
801085a3:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801085a6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085aa:	75 0d                	jne    801085b9 <freevm+0x1d>
    panic("freevm: no pgdir");
801085ac:	83 ec 0c             	sub    $0xc,%esp
801085af:	68 17 94 10 80       	push   $0x80109417
801085b4:	e8 4f 80 ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085b9:	83 ec 04             	sub    $0x4,%esp
801085bc:	6a 00                	push   $0x0
801085be:	68 00 00 00 80       	push   $0x80000000
801085c3:	ff 75 08             	pushl  0x8(%ebp)
801085c6:	e8 07 ff ff ff       	call   801084d2 <deallocuvm>
801085cb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801085ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085d5:	eb 48                	jmp    8010861f <freevm+0x83>
    //you don't need to check for PTE_E here because
    //this is a pde_t, where PTE_E doesn't get set
    if(pgdir[i] & PTE_P){
801085d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085e1:	8b 45 08             	mov    0x8(%ebp),%eax
801085e4:	01 d0                	add    %edx,%eax
801085e6:	8b 00                	mov    (%eax),%eax
801085e8:	83 e0 01             	and    $0x1,%eax
801085eb:	85 c0                	test   %eax,%eax
801085ed:	74 2c                	je     8010861b <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801085ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085f9:	8b 45 08             	mov    0x8(%ebp),%eax
801085fc:	01 d0                	add    %edx,%eax
801085fe:	8b 00                	mov    (%eax),%eax
80108600:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108605:	05 00 00 00 80       	add    $0x80000000,%eax
8010860a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010860d:	83 ec 0c             	sub    $0xc,%esp
80108610:	ff 75 f0             	pushl  -0x10(%ebp)
80108613:	e8 43 a7 ff ff       	call   80102d5b <kfree>
80108618:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010861b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010861f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108626:	76 af                	jbe    801085d7 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108628:	83 ec 0c             	sub    $0xc,%esp
8010862b:	ff 75 08             	pushl  0x8(%ebp)
8010862e:	e8 28 a7 ff ff       	call   80102d5b <kfree>
80108633:	83 c4 10             	add    $0x10,%esp
}
80108636:	90                   	nop
80108637:	c9                   	leave  
80108638:	c3                   	ret    

80108639 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108639:	f3 0f 1e fb          	endbr32 
8010863d:	55                   	push   %ebp
8010863e:	89 e5                	mov    %esp,%ebp
80108640:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108643:	83 ec 04             	sub    $0x4,%esp
80108646:	6a 00                	push   $0x0
80108648:	ff 75 0c             	pushl  0xc(%ebp)
8010864b:	ff 75 08             	pushl  0x8(%ebp)
8010864e:	e8 62 f8 ff ff       	call   80107eb5 <walkpgdir>
80108653:	83 c4 10             	add    $0x10,%esp
80108656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010865d:	75 0d                	jne    8010866c <clearpteu+0x33>
    panic("clearpteu");
8010865f:	83 ec 0c             	sub    $0xc,%esp
80108662:	68 28 94 10 80       	push   $0x80109428
80108667:	e8 9c 7f ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
8010866c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866f:	8b 00                	mov    (%eax),%eax
80108671:	83 e0 fb             	and    $0xfffffffb,%eax
80108674:	89 c2                	mov    %eax,%edx
80108676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108679:	89 10                	mov    %edx,(%eax)
}
8010867b:	90                   	nop
8010867c:	c9                   	leave  
8010867d:	c3                   	ret    

8010867e <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010867e:	f3 0f 1e fb          	endbr32 
80108682:	55                   	push   %ebp
80108683:	89 e5                	mov    %esp,%ebp
80108685:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108688:	e8 7e f9 ff ff       	call   8010800b <setupkvm>
8010868d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108690:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108694:	75 0a                	jne    801086a0 <copyuvm+0x22>
    return 0;
80108696:	b8 00 00 00 00       	mov    $0x0,%eax
8010869b:	e9 fa 00 00 00       	jmp    8010879a <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801086a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a7:	e9 c9 00 00 00       	jmp    80108775 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086af:	83 ec 04             	sub    $0x4,%esp
801086b2:	6a 00                	push   $0x0
801086b4:	50                   	push   %eax
801086b5:	ff 75 08             	pushl  0x8(%ebp)
801086b8:	e8 f8 f7 ff ff       	call   80107eb5 <walkpgdir>
801086bd:	83 c4 10             	add    $0x10,%esp
801086c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086c7:	75 0d                	jne    801086d6 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801086c9:	83 ec 0c             	sub    $0xc,%esp
801086cc:	68 32 94 10 80       	push   $0x80109432
801086d1:	e8 32 7f ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
801086d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d9:	8b 00                	mov    (%eax),%eax
801086db:	25 01 04 00 00       	and    $0x401,%eax
801086e0:	85 c0                	test   %eax,%eax
801086e2:	75 0d                	jne    801086f1 <copyuvm+0x73>
      panic("copyuvm: page not present");
801086e4:	83 ec 0c             	sub    $0xc,%esp
801086e7:	68 4c 94 10 80       	push   $0x8010944c
801086ec:	e8 17 7f ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801086f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f4:	8b 00                	mov    (%eax),%eax
801086f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108701:	8b 00                	mov    (%eax),%eax
80108703:	25 ff 0f 00 00       	and    $0xfff,%eax
80108708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010870b:	e8 e9 a6 ff ff       	call   80102df9 <kalloc>
80108710:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108713:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108717:	74 6d                	je     80108786 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108719:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010871c:	05 00 00 00 80       	add    $0x80000000,%eax
80108721:	83 ec 04             	sub    $0x4,%esp
80108724:	68 00 10 00 00       	push   $0x1000
80108729:	50                   	push   %eax
8010872a:	ff 75 e0             	pushl  -0x20(%ebp)
8010872d:	e8 68 ce ff ff       	call   8010559a <memmove>
80108732:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80108735:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108738:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010873b:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108744:	83 ec 0c             	sub    $0xc,%esp
80108747:	52                   	push   %edx
80108748:	51                   	push   %ecx
80108749:	68 00 10 00 00       	push   $0x1000
8010874e:	50                   	push   %eax
8010874f:	ff 75 f0             	pushl  -0x10(%ebp)
80108752:	e8 f8 f7 ff ff       	call   80107f4f <mappages>
80108757:	83 c4 20             	add    $0x20,%esp
8010875a:	85 c0                	test   %eax,%eax
8010875c:	79 10                	jns    8010876e <copyuvm+0xf0>
      kfree(mem);
8010875e:	83 ec 0c             	sub    $0xc,%esp
80108761:	ff 75 e0             	pushl  -0x20(%ebp)
80108764:	e8 f2 a5 ff ff       	call   80102d5b <kfree>
80108769:	83 c4 10             	add    $0x10,%esp
      goto bad;
8010876c:	eb 19                	jmp    80108787 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010876e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108778:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010877b:	0f 82 2b ff ff ff    	jb     801086ac <copyuvm+0x2e>
    }
  }
  return d;
80108781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108784:	eb 14                	jmp    8010879a <copyuvm+0x11c>
      goto bad;
80108786:	90                   	nop

bad:
  freevm(d);
80108787:	83 ec 0c             	sub    $0xc,%esp
8010878a:	ff 75 f0             	pushl  -0x10(%ebp)
8010878d:	e8 0a fe ff ff       	call   8010859c <freevm>
80108792:	83 c4 10             	add    $0x10,%esp
  return 0;
80108795:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010879a:	c9                   	leave  
8010879b:	c3                   	ret    

8010879c <uva2ka>:
// KVA -> PA
// PA -> KVA
// KVA = PA + KERNBASE
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010879c:	f3 0f 1e fb          	endbr32 
801087a0:	55                   	push   %ebp
801087a1:	89 e5                	mov    %esp,%ebp
801087a3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087a6:	83 ec 04             	sub    $0x4,%esp
801087a9:	6a 00                	push   $0x0
801087ab:	ff 75 0c             	pushl  0xc(%ebp)
801087ae:	ff 75 08             	pushl  0x8(%ebp)
801087b1:	e8 ff f6 ff ff       	call   80107eb5 <walkpgdir>
801087b6:	83 c4 10             	add    $0x10,%esp
801087b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //TODO: uva2ka says not present if PTE_P is 0
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
801087bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bf:	8b 00                	mov    (%eax),%eax
801087c1:	25 01 04 00 00       	and    $0x401,%eax
801087c6:	85 c0                	test   %eax,%eax
801087c8:	75 07                	jne    801087d1 <uva2ka+0x35>
    return 0;
801087ca:	b8 00 00 00 00       	mov    $0x0,%eax
801087cf:	eb 22                	jmp    801087f3 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
801087d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d4:	8b 00                	mov    (%eax),%eax
801087d6:	83 e0 04             	and    $0x4,%eax
801087d9:	85 c0                	test   %eax,%eax
801087db:	75 07                	jne    801087e4 <uva2ka+0x48>
    return 0;
801087dd:	b8 00 00 00 00       	mov    $0x0,%eax
801087e2:	eb 0f                	jmp    801087f3 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
801087e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e7:	8b 00                	mov    (%eax),%eax
801087e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ee:	05 00 00 00 80       	add    $0x80000000,%eax
}
801087f3:	c9                   	leave  
801087f4:	c3                   	ret    

801087f5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087f5:	f3 0f 1e fb          	endbr32 
801087f9:	55                   	push   %ebp
801087fa:	89 e5                	mov    %esp,%ebp
801087fc:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087ff:	8b 45 10             	mov    0x10(%ebp),%eax
80108802:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108805:	eb 7f                	jmp    80108886 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108807:	8b 45 0c             	mov    0xc(%ebp),%eax
8010880a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010880f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //TODO: what happens if you copyout to an encrypted page?
    pa0 = uva2ka(pgdir, (char*)va0);
80108812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108815:	83 ec 08             	sub    $0x8,%esp
80108818:	50                   	push   %eax
80108819:	ff 75 08             	pushl  0x8(%ebp)
8010881c:	e8 7b ff ff ff       	call   8010879c <uva2ka>
80108821:	83 c4 10             	add    $0x10,%esp
80108824:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0) {
80108827:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010882b:	75 07                	jne    80108834 <copyout+0x3f>
      return -1;
8010882d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108832:	eb 61                	jmp    80108895 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108834:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108837:	2b 45 0c             	sub    0xc(%ebp),%eax
8010883a:	05 00 10 00 00       	add    $0x1000,%eax
8010883f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108845:	3b 45 14             	cmp    0x14(%ebp),%eax
80108848:	76 06                	jbe    80108850 <copyout+0x5b>
      n = len;
8010884a:	8b 45 14             	mov    0x14(%ebp),%eax
8010884d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108850:	8b 45 0c             	mov    0xc(%ebp),%eax
80108853:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108856:	89 c2                	mov    %eax,%edx
80108858:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010885b:	01 d0                	add    %edx,%eax
8010885d:	83 ec 04             	sub    $0x4,%esp
80108860:	ff 75 f0             	pushl  -0x10(%ebp)
80108863:	ff 75 f4             	pushl  -0xc(%ebp)
80108866:	50                   	push   %eax
80108867:	e8 2e cd ff ff       	call   8010559a <memmove>
8010886c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010886f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108872:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108878:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010887b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010887e:	05 00 10 00 00       	add    $0x1000,%eax
80108883:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108886:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010888a:	0f 85 77 ff ff ff    	jne    80108807 <copyout+0x12>
  }
  return 0;
80108890:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108895:	c9                   	leave  
80108896:	c3                   	ret    

80108897 <mdecrypt>:


//returns 0 on success
int mdecrypt(char *virtual_addr) {
80108897:	f3 0f 1e fb          	endbr32 
8010889b:	55                   	push   %ebp
8010889c:	89 e5                	mov    %esp,%ebp
8010889e:	83 ec 28             	sub    $0x28,%esp
  //cprintf("mdecrypt: VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
801088a1:	e8 f1 bb ff ff       	call   80104497 <myproc>
801088a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t* mypd = p->pgdir;
801088a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ac:	8b 40 04             	mov    0x4(%eax),%eax
801088af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
801088b2:	83 ec 04             	sub    $0x4,%esp
801088b5:	6a 00                	push   $0x0
801088b7:	ff 75 08             	pushl  0x8(%ebp)
801088ba:	ff 75 e8             	pushl  -0x18(%ebp)
801088bd:	e8 f3 f5 ff ff       	call   80107eb5 <walkpgdir>
801088c2:	83 c4 10             	add    $0x10,%esp
801088c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (!pte || *pte == 0) {
801088c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801088cc:	74 09                	je     801088d7 <mdecrypt+0x40>
801088ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088d1:	8b 00                	mov    (%eax),%eax
801088d3:	85 c0                	test   %eax,%eax
801088d5:	75 07                	jne    801088de <mdecrypt+0x47>
    return -1;
801088d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088dc:	eb 5d                	jmp    8010893b <mdecrypt+0xa4>
  }

  *pte = *pte & ~PTE_E;
801088de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088e1:	8b 00                	mov    (%eax),%eax
801088e3:	80 e4 fb             	and    $0xfb,%ah
801088e6:	89 c2                	mov    %eax,%edx
801088e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088eb:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
801088ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088f0:	8b 00                	mov    (%eax),%eax
801088f2:	83 c8 01             	or     $0x1,%eax
801088f5:	89 c2                	mov    %eax,%edx
801088f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088fa:	89 10                	mov    %edx,(%eax)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
801088fc:	8b 45 08             	mov    0x8(%ebp),%eax
801088ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108904:	89 45 08             	mov    %eax,0x8(%ebp)

  char * slider = virtual_addr;
80108907:	8b 45 08             	mov    0x8(%ebp),%eax
8010890a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
8010890d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108914:	eb 17                	jmp    8010892d <mdecrypt+0x96>
    *slider = ~*slider;
80108916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108919:	0f b6 00             	movzbl (%eax),%eax
8010891c:	f7 d0                	not    %eax
8010891e:	89 c2                	mov    %eax,%edx
80108920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108923:	88 10                	mov    %dl,(%eax)
    slider++;
80108925:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108929:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010892d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108934:	7e e0                	jle    80108916 <mdecrypt+0x7f>
  }

  return 0;
80108936:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010893b:	c9                   	leave  
8010893c:	c3                   	ret    

8010893d <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
8010893d:	f3 0f 1e fb          	endbr32 
80108941:	55                   	push   %ebp
80108942:	89 e5                	mov    %esp,%ebp
80108944:	83 ec 28             	sub    $0x28,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108947:	e8 4b bb ff ff       	call   80104497 <myproc>
8010894c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
8010894f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108952:	8b 40 04             	mov    0x4(%eax),%eax
80108955:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108958:	8b 45 08             	mov    0x8(%ebp),%eax
8010895b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108960:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108963:	8b 45 08             	mov    0x8(%ebp),%eax
80108966:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108969:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108970:	eb 3f                	jmp    801089b1 <mencrypt+0x74>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108972:	83 ec 08             	sub    $0x8,%esp
80108975:	ff 75 f4             	pushl  -0xc(%ebp)
80108978:	ff 75 e0             	pushl  -0x20(%ebp)
8010897b:	e8 1c fe ff ff       	call   8010879c <uva2ka>
80108980:	83 c4 10             	add    $0x10,%esp
80108983:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!kvp) {
80108986:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010898a:	75 1a                	jne    801089a6 <mencrypt+0x69>
      cprintf("mencrypt: Could not access address\n");
8010898c:	83 ec 0c             	sub    $0xc,%esp
8010898f:	68 68 94 10 80       	push   $0x80109468
80108994:	e8 7f 7a ff ff       	call   80100418 <cprintf>
80108999:	83 c4 10             	add    $0x10,%esp
      return -1;
8010899c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089a1:	e9 b8 00 00 00       	jmp    80108a5e <mencrypt+0x121>
    }
    slider = slider + PGSIZE;
801089a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
801089ad:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089b7:	7c b9                	jl     80108972 <mencrypt+0x35>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
801089b9:	8b 45 08             	mov    0x8(%ebp),%eax
801089bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
801089bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801089c6:	eb 78                	jmp    80108a40 <mencrypt+0x103>
    //we get the page table entry that corresponds to this VA
    pte_t * mypte = walkpgdir(mypd, slider, 0);
801089c8:	83 ec 04             	sub    $0x4,%esp
801089cb:	6a 00                	push   $0x0
801089cd:	ff 75 f4             	pushl  -0xc(%ebp)
801089d0:	ff 75 e0             	pushl  -0x20(%ebp)
801089d3:	e8 dd f4 ff ff       	call   80107eb5 <walkpgdir>
801089d8:	83 c4 10             	add    $0x10,%esp
801089db:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (*mypte & PTE_E) {//already encrypted
801089de:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089e1:	8b 00                	mov    (%eax),%eax
801089e3:	25 00 04 00 00       	and    $0x400,%eax
801089e8:	85 c0                	test   %eax,%eax
801089ea:	74 09                	je     801089f5 <mencrypt+0xb8>
      slider += PGSIZE;
801089ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
801089f3:	eb 47                	jmp    80108a3c <mencrypt+0xff>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
801089f5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801089fc:	eb 17                	jmp    80108a15 <mencrypt+0xd8>
      *slider = ~*slider;
801089fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a01:	0f b6 00             	movzbl (%eax),%eax
80108a04:	f7 d0                	not    %eax
80108a06:	89 c2                	mov    %eax,%edx
80108a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0b:	88 10                	mov    %dl,(%eax)
      slider++;
80108a0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108a11:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108a15:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108a1c:	7e e0                	jle    801089fe <mencrypt+0xc1>
    }
    *mypte = *mypte & ~PTE_P;
80108a1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a21:	8b 00                	mov    (%eax),%eax
80108a23:	83 e0 fe             	and    $0xfffffffe,%eax
80108a26:	89 c2                	mov    %eax,%edx
80108a28:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a2b:	89 10                	mov    %edx,(%eax)
    *mypte = *mypte | PTE_E;
80108a2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a30:	8b 00                	mov    (%eax),%eax
80108a32:	80 cc 04             	or     $0x4,%ah
80108a35:	89 c2                	mov    %eax,%edx
80108a37:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a3a:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) { 
80108a3c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108a40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a43:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a46:	7c 80                	jl     801089c8 <mencrypt+0x8b>
  }

  switchuvm(myproc());
80108a48:	e8 4a ba ff ff       	call   80104497 <myproc>
80108a4d:	83 ec 0c             	sub    $0xc,%esp
80108a50:	50                   	push   %eax
80108a51:	e8 8b f6 ff ff       	call   801080e1 <switchuvm>
80108a56:	83 c4 10             	add    $0x10,%esp
  return 0;
80108a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a5e:	c9                   	leave  
80108a5f:	c3                   	ret    

80108a60 <getpgtable>:

int getpgtable(struct pt_entry* entries, int num, int wsetOnly) {
80108a60:	f3 0f 1e fb          	endbr32 
80108a64:	55                   	push   %ebp
80108a65:	89 e5                	mov    %esp,%ebp
80108a67:	83 ec 18             	sub    $0x18,%esp
  //p5 melody changes
  if(wsetOnly!=0 || wsetOnly!=1) return -1;
80108a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a6e:	75 06                	jne    80108a76 <getpgtable+0x16>
80108a70:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
80108a74:	74 0a                	je     80108a80 <getpgtable+0x20>
80108a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a7b:	e9 9f 01 00 00       	jmp    80108c1f <getpgtable+0x1bf>
  //
  struct proc * me = myproc();
80108a80:	e8 12 ba ff ff       	call   80104497 <myproc>
80108a85:	89 45 ec             	mov    %eax,-0x14(%ebp)

  int index = 0;
80108a88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t * curr_pte;
  //reverse order

  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80108a8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a92:	8b 00                	mov    (%eax),%eax
80108a94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a9c:	e9 6f 01 00 00       	jmp    80108c10 <getpgtable+0x1b0>
    //walk through the page table and read the entries
    //Those entries contain the physical page number + flags
    curr_pte = walkpgdir(me->pgdir, i, 0);
80108aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aa4:	8b 40 04             	mov    0x4(%eax),%eax
80108aa7:	83 ec 04             	sub    $0x4,%esp
80108aaa:	6a 00                	push   $0x0
80108aac:	ff 75 f0             	pushl  -0x10(%ebp)
80108aaf:	50                   	push   %eax
80108ab0:	e8 00 f4 ff ff       	call   80107eb5 <walkpgdir>
80108ab5:	83 c4 10             	add    $0x10,%esp
80108ab8:	89 45 e8             	mov    %eax,-0x18(%ebp)


    //currPage is 0 if page is not allocated
    //see deallocuvm
    if(wsetOnly){
80108abb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108abf:	0f 85 44 01 00 00    	jne    80108c09 <getpgtable+0x1a9>
      //filling with the pte in the working queue
      ;
    }else{
      if (curr_pte && *curr_pte) {//this page is allocated
80108ac5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ac9:	0f 84 3a 01 00 00    	je     80108c09 <getpgtable+0x1a9>
80108acf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ad2:	8b 00                	mov    (%eax),%eax
80108ad4:	85 c0                	test   %eax,%eax
80108ad6:	0f 84 2d 01 00 00    	je     80108c09 <getpgtable+0x1a9>
        //this is the same for all pt_entries... right?
        entries[index].pdx = PDX(i); 
80108adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108adf:	c1 e8 16             	shr    $0x16,%eax
80108ae2:	89 c1                	mov    %eax,%ecx
80108ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108aee:	8b 45 08             	mov    0x8(%ebp),%eax
80108af1:	01 c2                	add    %eax,%edx
80108af3:	89 c8                	mov    %ecx,%eax
80108af5:	66 25 ff 03          	and    $0x3ff,%ax
80108af9:	66 25 ff 03          	and    $0x3ff,%ax
80108afd:	89 c1                	mov    %eax,%ecx
80108aff:	0f b7 02             	movzwl (%edx),%eax
80108b02:	66 25 00 fc          	and    $0xfc00,%ax
80108b06:	09 c8                	or     %ecx,%eax
80108b08:	66 89 02             	mov    %ax,(%edx)
        entries[index].ptx = PTX(i);
80108b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0e:	c1 e8 0c             	shr    $0xc,%eax
80108b11:	89 c1                	mov    %eax,%ecx
80108b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b16:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b20:	01 c2                	add    %eax,%edx
80108b22:	89 c8                	mov    %ecx,%eax
80108b24:	66 25 ff 03          	and    $0x3ff,%ax
80108b28:	0f b7 c0             	movzwl %ax,%eax
80108b2b:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b30:	c1 e0 0a             	shl    $0xa,%eax
80108b33:	89 c1                	mov    %eax,%ecx
80108b35:	8b 02                	mov    (%edx),%eax
80108b37:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108b3c:	09 c8                	or     %ecx,%eax
80108b3e:	89 02                	mov    %eax,(%edx)
        //convert to physical addr then shift to get PPN 
        entries[index].ppage = PPN(*curr_pte);
80108b40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b43:	8b 00                	mov    (%eax),%eax
80108b45:	c1 e8 0c             	shr    $0xc,%eax
80108b48:	89 c2                	mov    %eax,%edx
80108b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108b54:	8b 45 08             	mov    0x8(%ebp),%eax
80108b57:	01 c8                	add    %ecx,%eax
80108b59:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80108b5f:	89 d1                	mov    %edx,%ecx
80108b61:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
80108b67:	8b 50 04             	mov    0x4(%eax),%edx
80108b6a:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80108b70:	09 ca                	or     %ecx,%edx
80108b72:	89 50 04             	mov    %edx,0x4(%eax)
        //have to set it like this because these are 1 bit wide fields
        entries[index].present = (*curr_pte & PTE_P) ? 1 : 0;
80108b75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b78:	8b 08                	mov    (%eax),%ecx
80108b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108b84:	8b 45 08             	mov    0x8(%ebp),%eax
80108b87:	01 c2                	add    %eax,%edx
80108b89:	89 c8                	mov    %ecx,%eax
80108b8b:	83 e0 01             	and    $0x1,%eax
80108b8e:	83 e0 01             	and    $0x1,%eax
80108b91:	c1 e0 04             	shl    $0x4,%eax
80108b94:	89 c1                	mov    %eax,%ecx
80108b96:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108b9a:	83 e0 ef             	and    $0xffffffef,%eax
80108b9d:	09 c8                	or     %ecx,%eax
80108b9f:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].writable = (*curr_pte & PTE_W) ? 1 : 0;
80108ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba5:	8b 00                	mov    (%eax),%eax
80108ba7:	d1 e8                	shr    %eax
80108ba9:	89 c1                	mov    %eax,%ecx
80108bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb8:	01 c2                	add    %eax,%edx
80108bba:	89 c8                	mov    %ecx,%eax
80108bbc:	83 e0 01             	and    $0x1,%eax
80108bbf:	83 e0 01             	and    $0x1,%eax
80108bc2:	c1 e0 05             	shl    $0x5,%eax
80108bc5:	89 c1                	mov    %eax,%ecx
80108bc7:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108bcb:	83 e0 df             	and    $0xffffffdf,%eax
80108bce:	09 c8                	or     %ecx,%eax
80108bd0:	88 42 06             	mov    %al,0x6(%edx)
        entries[index].encrypted = (*curr_pte & PTE_E) ? 1 : 0;
80108bd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bd6:	8b 00                	mov    (%eax),%eax
80108bd8:	c1 e8 0a             	shr    $0xa,%eax
80108bdb:	89 c1                	mov    %eax,%ecx
80108bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108be7:	8b 45 08             	mov    0x8(%ebp),%eax
80108bea:	01 c2                	add    %eax,%edx
80108bec:	89 c8                	mov    %ecx,%eax
80108bee:	83 e0 01             	and    $0x1,%eax
80108bf1:	83 e0 01             	and    $0x1,%eax
80108bf4:	c1 e0 06             	shl    $0x6,%eax
80108bf7:	89 c1                	mov    %eax,%ecx
80108bf9:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80108bfd:	83 e0 bf             	and    $0xffffffbf,%eax
80108c00:	09 c8                	or     %ecx,%eax
80108c02:	88 42 06             	mov    %al,0x6(%edx)
        index++;
80108c05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (void * i = (void*) PGROUNDDOWN(((int)me->sz)); i >= 0 && index < num; i-=PGSIZE) {
80108c09:	81 6d f0 00 10 00 00 	subl   $0x1000,-0x10(%ebp)
80108c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c13:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c16:	0f 8c 85 fe ff ff    	jl     80108aa1 <getpgtable+0x41>
      }
    }
  }
  //index is the number of ptes copied
  return index;
80108c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108c1f:	c9                   	leave  
80108c20:	c3                   	ret    

80108c21 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
80108c21:	f3 0f 1e fb          	endbr32 
80108c25:	55                   	push   %ebp
80108c26:	89 e5                	mov    %esp,%ebp
80108c28:	56                   	push   %esi
80108c29:	53                   	push   %ebx
80108c2a:	83 ec 10             	sub    $0x10,%esp
  //note that copyout converts buffer to a kva and then copies
  //which means that if buffer is encrypted, it won't trigger a decryption request
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) P2V(physical_addr), PGSIZE);
80108c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80108c30:	05 00 00 00 80       	add    $0x80000000,%eax
80108c35:	89 c6                	mov    %eax,%esi
80108c37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80108c3a:	e8 58 b8 ff ff       	call   80104497 <myproc>
80108c3f:	8b 40 04             	mov    0x4(%eax),%eax
80108c42:	68 00 10 00 00       	push   $0x1000
80108c47:	56                   	push   %esi
80108c48:	53                   	push   %ebx
80108c49:	50                   	push   %eax
80108c4a:	e8 a6 fb ff ff       	call   801087f5 <copyout>
80108c4f:	83 c4 10             	add    $0x10,%esp
80108c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80108c55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c59:	74 07                	je     80108c62 <dump_rawphymem+0x41>
    return -1;
80108c5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c60:	eb 05                	jmp    80108c67 <dump_rawphymem+0x46>
  return 0;
80108c62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c67:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108c6a:	5b                   	pop    %ebx
80108c6b:	5e                   	pop    %esi
80108c6c:	5d                   	pop    %ebp
80108c6d:	c3                   	ret    
