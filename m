From: Jeremy Fox <jerfox@Stanford.EDU>
Date: Wed, 03 Apr 2002 00:17:38 +0000
Subject: Re: [Linux-ia64] Basic Advice Needed
Message-Id: <marc-linux-ia64-105590701905367@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905348@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905348@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 02, 2002 at 09:14:10AM -0600, Van Maren, Kevin wrote:

> Use the latest Adaptec driver from Justin Gibbs.  There was a bug in the
> early 39-bit DMA support that caused the kernel to crash periodically
> [if the address just happened to overlab the swiotlb in the low 32 bits].
> 
> He incorporated my fix in Change 420:

I appreciate your work on tracking down these hardware problems, and
everyone else who responded.

Well, the end (for now) of this story is that the seller was mistaken
about the DIMM configuration of the machine, and so it was not worth
the money I was paying for it because I could not upgrade the RAM
without yanking existing DIMMs. So I canceled my order, although the
last thing I was hearing was that the Debian disc was working, perhaps
because it uses a newer version of the kernel (2.4.17 according to the
docs), incorporating bug fixes to drivers (like the one Kevin
submitted) and the like.

I still have an unmet computational need, and I may have to get
another Itanium; and if I do so I'll put Debian on it, unless of
course other distributions upgrade their versions with newer
kernels. :)

If anyone is working on the Debian distro, one minor problem you might
fix is that the iso image does not uncompress properly on a Windows
machine.

-- 
------------------------
Jeremy T. Fox
jerfox@stanford.edu

