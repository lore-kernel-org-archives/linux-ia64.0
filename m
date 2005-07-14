From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Thu, 14 Jul 2005 15:23:38 +0000
Subject: RE: autocompilation hosed?
Message-Id: <516F50407E01324991DD6D07B0531AD54FA7C2@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > No ... I saw it too without gcc-4.  See 
> http://tinyurl.com/clzbu where I
> > identified the patch that seems to be the cause.
> 
> Patch below fixes the problem.  Moral of the story: don't add
> "attributed(packed)" lightly!

IIRC as of gcc3.2, attribute(packed) on ia64 meant roughly the
equivalent of specifying "generate the worst case possible
code even for things that are aligned".  Is that still the
case in gcc-4?
