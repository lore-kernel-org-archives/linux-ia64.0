From: Arjan van de Ven <arjanv@redhat.com>
Date: Sun, 18 May 2003 09:43:41 +0000
Subject: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705932@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 18, 2003 at 02:35:33AM -0700, David S. Miller wrote:

> WHile logically you are correct, the probing code is going to
> look basically identical.

For most drivers I don't think it will. Most drivers will just say "look I
can do THIS much. I don't give a flying fish about how much of
that you actually use". At least in the probing code. 

In code of say a scsi driver that has to pick some dma descriptor format it's a different
matter of course, but there you have to check SOMETHING, either a variable
you stored during probing, or now the effective mask....

