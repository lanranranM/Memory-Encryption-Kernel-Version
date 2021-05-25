# os-Memory-Encryption-Kernel-Version

## questions
1. data structure of the queue?
2. where to put the queue management?
3. What files need to be modified to ensure the system working

## todo  
| description | progess |
| ----------- | ----------- |
| 1, init all the user pages as the encrypted state | finished |
| 1.5, update getpgtable(), dump_rawphymem() | finished |
| 2, add the clock queue mechanism<br />| finished |
| 3, manage the fork()| finished |

## todo 1
1. encrypt pages in growpoc() and extra pages in exec() √

## todo 1.5
1. update getpgtable() with new ptentry.h  
  - updated new ptentry.h √  
  - build the logical frame √  
2. update dump_raw() with decrypted pages  √

## todo 2
1, ensure correctness on user level √
2, insert into kernal part √

## todo 3
