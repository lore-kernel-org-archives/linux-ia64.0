From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Wed, 14 Nov 2001 18:16:46 +0000
Subject: [Linux-ia64] ia-64 cast warning??
Message-Id: <marc-linux-ia64-105590698805513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi
Consider the following macro : executing in a program , on linux ia-64
machine: 
ifdef CIRC_DEBUG
#define CBUFSIZE 32768 
#define CHECK_CIRC_ALIGNMENT( A ) \
if (((unsigned int)(circbuff + A))%sizeof(caddr_t)) { A += (sizeof(caddr_t)
- (((unsigned int)(circbuff + A))%sizeof(caddr_t)))/sizeof(unsigned short);
}

#define CIRCADDR( A ) \
CHECK_CIRC_ALIGNMENT(CBptr) \
*(caddr_t *)(circbuff + CBptr) = A; \
CBptr = (CBptr + sizeof(caddr_t)/sizeof(short)) % CBUFSIZE;

#endif


int main(){
  unsigned int volatile* mask;
  unsigned short circbuff[CBUFSIZE];
  unsigned int CBptr;
  unsigned int current;
.....
  CHECK_CIRC_ALIGNMENT(current);
.....
}

I always get the warning : 
warning : cast from pointer to integer of different size  on the line
CHECK_CIRC_ALIGNMENT(current);

when I compile the above program.I want to get rid of the warning.I am not
able to figure out why I get this warning.??
Please let me know 

D'laila

