From: "ARADHYA, CHINMAYA TM (STSD)" <chinmaya@hp.com>
Date: Mon, 03 May 2004 13:28:09 +0000
Subject: shared memory between 32bit & 64bit applications
Message-Id: <8BF7471D09AA9B4190A9C96778BC2A170108B6EA@qcaexc02.asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi,

I am seeing this weird problem when I am trying
to pass on some data from a 64bit application to 
a 32bit application via shared memory. 

The information which is held in the shared memory
is interpreted as in the structure
typedef struct shmtest
{
        int req;
        long long id;
        int abc;
}shmtest_t;

The 64 bit application fills in {1,5,5} in the shared
memory and when I access these values from a 32 bit application
I get it as {1,21474836480,0}. I guess this is due to 
switch  of lower and upper significant bytes. 
Strangely when the 64bit application fills in 
{2,69472139471924,6} the value read by the 32bit application
would be {2,4481622812292808704,16175}.

Could somebody tell me whether I need to do something different
to handle shared memory b/w 32-64bit applications..or am I missing
out some thing basic.

Kernel version: 2.4.21-4.EL

TIA
-Chinmaya

PS: Please point me to the right group if this question does
not belong here.


 
