From: Fujio Ikegami <ikegami@cs.fujitsu.co.jp>
Date: Tue, 19 Sep 2000 00:54:49 +0000
Subject: [Linux-ia64] big endian code of NUE gcc
Message-Id: <marc-linux-ia64-105590678205500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

  I tried to get big endian code by using NUE gcc under IA-32 Linux as follows:
	gcc -mbig-endian -o endian endian.c
  But the code I got was not big endian. 
  Question:
    Is the compiler option of -mbig-endian effective?
    Does Red Hat support big endian code?

Best Regards,
Fujio Ikegami

<attachement>
1. Operation
[ikegami@alfard hit]$ nue
bash$ gcc -mbig-endian -o endian endian.c
bash$ endian
u1634 u32345678 u6434567890ABCDEF
u16
FFFFF98E   3412                                |4 |
u32
FFFFF988   78563412                            |xV4 |
u64
FFFFF980   EFCDAB90 78563412                   |    xV4 |
bash$

2. endian.c
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
void dump(char *title,void *vp,int len);
int main() {
  unsigned short int u16;
  unsigned int u32;
  unsigned long long int u64;
  u16=0x1234;
  u32=0x12345678;
  u64=0x1234567890abcdef;
  printf("u16=%x u32=%x u64=%lX\n",u16,u32,u64);
  dump("u16",&u16,2);
  dump("u32",&u32,4);
  dump("u64",&u64,8);
  return 0;
}
void dump(char *title,void *vp,int len) {
  // hex dump */
     unsigned char *p;
     int i,j,c;
     char buf[32];

     p=(unsigned char *)vp;
     printf("%s\n",title);
     for(i=j=0;i<len;i++) {
       c=p[i];
       if (i%16=0) {
         if (i>0) printf(" |%s|\n",buf);
         printf("%08X  ",p+i);
         j=0;
       }
       if (i%4=0) printf(" ");
       printf("%02X",c);
       sprintf(&buf[j++],"%c",to_char(c));
     }
     for(i=j;i<16;i++) {
       if (i%4=0) printf(" ");
       printf("  ");
     }
     printf(" |%s|\n",buf);
     return;
}
int to_char(int c) {
  if (c<' ' || c>0x7f) return ' ';
  return c;
}

