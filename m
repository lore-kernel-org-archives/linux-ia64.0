From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 23 Apr 2002 21:05:56 +0000
Subject: Re: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590701905498@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Have you chatr'd your X executable?  Stack pages are not
executable by default starting in 2.4.18.  See David's patch
announcement for the fix.
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard

