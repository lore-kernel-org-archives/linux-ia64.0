From: liuduo <liuduo@sinosoft.com.cn>
Date: Fri, 16 Jan 2004 03:03:00 +0000
Subject: a question about memory access on IA64
Message-Id: <40075464.6010202@sinosoft.com.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Sir:
nice to see you !
here is a problem about accessing memory on IA64 as follows,
 we define a structrue is :
typedef struct b{
unsigned short  b1;
unsigned short  b2;
unsigned char   b3;
unsigned char  b4;
unsigned char  b5;
unsigned char  b6;
}B;

typedef struct  a{
struct b bb[512];
int c;}A;

when we use  the struct A on IA64, the segmentation fault occurs ,
and then we modify the struct A as follows :
typedef struct  a{
int c;
struct b bb[512];
}A;
we can use it normally .
can you  explain why ?
thanks a lot , and expect your reply urgently

yours : calis






-- 
===================Liu duo
tel:(010)62570007-509
email:liuduo@sinosoft.com.cn
Sinosoft Software.Co.Ltd.
Esmpro Group.Secic Department
===================

