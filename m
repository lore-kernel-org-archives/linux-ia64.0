From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 26 Jan 2001 09:40:22 +0000
Subject: Re: [Linux-ia64] gcc bug
Message-Id: <marc-linux-ia64-105590693005106@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005105@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005105@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 26 Jan 2001 00:09:55 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The attached program demonstrates a gcc code generation bug.
>
>struct f {
>  unsigned long lo : 32;
>  unsigned long hi : 32;
>};

K&R says "Fields may be declared only as ints".  The C99 rational says
"Three types of bit fields are now defined: plain int calls for
implementation-defined signedness (as in K&R), signed int calls for
assuredly signed fields, and unsigned int calls for unsigned fields".
I am surprised that the compiler accepted unsigned long, it is not
listed as a gcc extension.  Do you get the same error when those fields
are changed to unsigned int?


