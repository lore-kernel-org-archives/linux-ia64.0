From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 11 Dec 2001 05:44:33 +0000
Subject: [Linux-ia64] Re: new GPT and uuid patches
Message-Id: <marc-linux-ia64-105590698805681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Dec 2001 22:17:06 -0600, Matt_Domsch@Dell.com said:

  Matt> to be useful in more places.  I withdraw my previous patch
  Matt> implementing uuid.[ch] as libraries, letting efi_guid_t remain
  Matt> it's own unique thing.  It was hard enough getting the crc32
  Matt> library patch submitted, making other non-critical library
  Matt> cleanups is more than I can handle ATM.

Most of the patch looks good to me, but I do not understand why you
want to use a structured type for GUID.  This really does make the
whole store much more complicated than it has to be.  As per our
earlier discussion with Linus and Alan, the GUID should be just an
unstructured sequence of 16 bytes.  If you do that, all those ugly
conversion routines can go away and your head doesn't spin trying to
figure out what needs to be big-endian and what needs to be little
endian.  The *only* thing that needs to be endian aware is the
parsing/printing routines.  Those will be EFI GUID specific and will
have to make up for the mistake Intel made when defining the external
representation in the weird mixed byteorder (well, I'm assuming it was
a mistake; I don't assume someone would willfully do such a thing ;-).
The other benefit is that this will make GUIDs identical to UUIDs
(which they ought be), except for the external representation.

	--david

