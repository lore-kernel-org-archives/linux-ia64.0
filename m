From: Keith Owens <kaos@sgi.com>
Date: Mon, 17 Jan 2005 21:18:47 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <7557.1105996727@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 17 Jan 2005 15:07:21 -0600 (CST), 
Russ Anderson <rja@sgi.com> wrote:
>Hidetoshi Seto wrote:
>My only real complaint about the array is that the current size
>is too small.  The Altix error injection test (which can modify
>the ECC to create true memory uncorrectables) can recover from 
>several hundred memory uncorrectable errors, when the array 
>limitation is removed.  Making the array dynamic (linked list or 
>something), so the size can be expanded would be a sufficient 
>solution, too.

Do not even think about making the array a dynamic size.  MCA events
can occur even when interrupts are disabled, which means that in an MCA
you have no idea if any of the kernel structures are in a safe state or
not.  That in turn means that you cannot extend the array from MCA
context.  Page flags that indicate bad memory are the best way to go.

