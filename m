From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 12 Jun 2001 08:44:12 +0000
Subject: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005716@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

it is becoming apparent that the limited bounce buffer space is the reason
for the crashes with the new aic7xxx driver and linux-IA64 with >=4GB RAM
that I reported previously.

If I understand it right,
the driver uses up to 253 buffers per device, each of which can be 8kB in
size. Consequently, it almost completely fills up the available IO/TLB
space.

Question: Would it hurt to increase IO/TLB space on machines with large
memory? Would it be possible and make sense to make IO/TLB space size a
kernel configuration option?

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




