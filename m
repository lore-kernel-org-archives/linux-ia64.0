From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 04 May 2004 02:04:11 +0000
Subject: Re: shared memory between 32bit & 64bit applications
Message-Id: <6869.1083636251@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 3 May 2004 14:25:11 +0100, 
Matthew Wilcox <willy@debian.org> wrote:
>Nope.  You're being bitten by different struct padding rules.
>
>#include <stdio.h>
>
>struct foo {
>        int req;
>        long long id;
>        int abc;
>};
>
>int main(void) { return printf("%d\n", sizeof(struct foo)); }
>
>On ia64, this prints 24; on i386 it prints 16.
>
>You could declare it __attribute__((packed)) or you could reorder the
>elements in the struct to put the largest elements first.

Or compile i386 code with -malign-double which will align i386 long
long values on 8 byte boundaries, the same as ia64.

