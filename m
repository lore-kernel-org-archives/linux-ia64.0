From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 20 Feb 2002 00:22:29 +0000
Subject: Re: [Linux-ia64] null pointer dereference patch
Message-Id: <marc-linux-ia64-105590701905138@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806040@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806040@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Feb 2002 14:09:43 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Tue, 12 Feb 2002 14:51:22 -0700, Bjorn Helgaas <bjorn_helgaas@hp.com> said:
>
>  Bjorn> Without the attached patch, unaligned references before
>  Bjorn> init_modules() is called result in null pointer dereferences.
>  Bjorn> This is against 2.4.17-ia64-011226.
>
>I wonder whether module_list shouldn't be made to be NULL until
>init_modules() has had a chance to initialize it.  Keith?

Some arch dependent init code relies on extable working right from the
start, to catch kernel operations that may or may not be valid,
depending on the precise hardware.  Changing module_list to NULL breaks
that code, the patch is correct.


