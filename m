From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Mon, 03 Feb 2003 16:37:48 +0000
Subject: [Linux-ia64] Question about .opd section
Message-Id: <marc-linux-ia64-105590709805798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The gnu toolchain (well, binutils) emits a .opd section
for  architectures which use function descriptors -
it's not unique to Itanium.

But I can't find much information about it.  Google
has been unhelpful (to me, anyway) on this one. It's
described as holding function descriptors, but I'm not 
clear who uses this information - is this used at
runtime?

Is this section considered normal/required for
Linux/ia64?  I'm asking because it wasn't in the
Itanium psABI, and thus didn't make it into the
current version of the Itanium LSB spec; our
application checker tool is flagging this as an
unknown section.

Thanks,

Mats

