From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Thu, 08 Mar 2001 09:07:08 +0000
Subject: [Linux-ia64] Pointer to function has a bad value
Message-Id: <marc-linux-ia64-105590693005265@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is this a known bug or fixed in a later compiler?  Using gcc version
2.9-ia64-000216-final, assigning the address of a function to a pointer
gives the wrong value.  In the following program, the address of twiddle is
0x40000000000003f0, but the value of the pointer i is 0x4000000000078300.

void twiddle(void)
{
	int i = 34;
}
main()
{
	unsigned long i = (unsigned long)twiddle;
	printf("i=%lx\n", i);
}

 - David Robboy


