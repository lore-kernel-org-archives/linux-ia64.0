From: "Duraid Madina" <duraid@fl.net.au>
Date: Wed, 30 Jan 2002 10:04:29 +0000
Subject: RE: [Linux-ia64] What's taking all the system time..? The unaligned accesses are!
Message-Id: <marc-linux-ia64-105590698805961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Okay, sorry for not figuring this one out *before* spamming the list:
the unaligned accesses were really killing things. Now everything's
running five times faster. Yay!

	Duraid



