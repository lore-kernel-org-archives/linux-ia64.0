From: Matthew Wilcox <willy@debian.org>
Date: Mon, 03 May 2004 13:25:11 +0000
Subject: Re: shared memory between 32bit & 64bit applications
Message-Id: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 03, 2004 at 06:46:09PM +0530, ARADHYA, CHINMAYA TM (STSD) wrote:
> The information which is held in the shared memory
> is interpreted as in the structure
> typedef struct shmtest
> {
>         int req;
>         long long id;
>         int abc;
> }shmtest_t;
> 
> The 64 bit application fills in {1,5,5} in the shared
> memory and when I access these values from a 32 bit application
> I get it as {1,21474836480,0}. I guess this is due to 
> switch  of lower and upper significant bytes. 

Nope.  You're being bitten by different struct padding rules.

#include <stdio.h>

struct foo {
        int req;
        long long id;
        int abc;
};

int main(void) { return printf("%d\n", sizeof(struct foo)); }

On ia64, this prints 24; on i386 it prints 16.

You could declare it __attribute__((packed)) or you could reorder the
elements in the struct to put the largest elements first.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
