From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 23 Sep 2003 19:10:11 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479111284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Traditionally, if the NIC driver is accessing unaligned data, it should
be using get/put_unaligned().

	Jeff



