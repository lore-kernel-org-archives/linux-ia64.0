From: Matt_Domsch@Dell.com
Date: Tue, 11 Dec 2001 15:40:41 +0000
Subject: [Linux-ia64] RE: new GPT and uuid patches
Message-Id: <marc-linux-ia64-105590698805682@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805681@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805681@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, I'll look at it some more.

> The *only* thing that needs to be endian aware is the
> parsing/printing routines.  Those will be EFI GUID specific and will
> have to make up for the mistake Intel made when defining the external
> representation in the weird mixed byteorder (well, I'm assuming it was
> a mistake; I don't assume someone would willfully do such a thing ;-).

It's these two conflicting things that I think can now be reconciled:
EFI Spec references Wired for Management Baseline Spec 2.0: Page A-7 -
section describing UUIDs and GUIDs (based on proposed RFC):

In the absence of explicit application or presentation protocol
specification to the contrary, a
UUID is encoded as a 128-bit object, as follows: the fields are encoded as
16 octets, with the
sizes and order of the fields defined in Section 3.1, and with each field
encoded with the Most
Significant Byte first (also known as network byte order). [big endian]

Intel EFI Spec also has, in section 1.8.1:
All implementations designed to conform to this specification
will use "little endian" operation.

If I read this right, I'd say that GUIDs are in fact big endian, even though
the processor is in little-endian mode.  Would Intel be willing to state
this explicity in the EFI Spec, appendix A?  Elsewhere in the spec,
particularly in the PXE section, they do this already.

> The other benefit is that this will make GUIDs identical to UUIDs
> (which they ought be), except for the external representation.

Hopefully now even the external representation can be identical.

I'll work up a patch.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#1 US Linux Server provider with 24% (IDC Sept 2001)
#2 Worldwide Linux Server provider with 17% (IDC Sept 2001)
#3 Unix provider with 18% in the US (Dataquest)!

