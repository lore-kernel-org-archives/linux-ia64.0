From: Matthew Wilcox <willy@debian.org>
Date: Wed, 21 Aug 2002 11:51:40 +0000
Subject: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The MCA handler is completely useless.  If I crash the machine and
forget to clear the MCA dump in firmware, at the next boot Linux dumps
the registers (in a hard-to-understand style) and hangs.  In its current
state, I'd rather it simply weren't in the kernel at all.

Do any platforms not have MCA handling facilities in firmware?

-- 
Revolutions do not require corporate support.

