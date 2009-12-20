From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:25:17 +0000
Subject: Re: [PATCH 00/11] ACPI: early _PDC eval and unify x86/ia64
Message-Id: <20091220192517.GA2016@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

* Alex Chiang <achiang@hp.com>:
> It was recently discovered that some BIOS implementations load
> dynamic SSDTs when a processor's _PDC method is evaluated.

D'oh, I knew I'd forget something. Here are some bz references:

	http://bugzilla.kernel.org/show_bug.cgi?id824
	http://bugzilla.kernel.org/show_bug.cgi?id710

/ac

