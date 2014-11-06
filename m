From: Dave Hansen <dave.hansen@intel.com>
Date: Thu, 06 Nov 2014 21:50:03 +0000
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
Message-Id: <545BED0B.8000001@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241451280.5308@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

Instead of all of these games with dropping and reacquiring mmap_sem and
adding other locks, or deferring the work, why don't we just do a
get_user_pages()?  Something along the lines of:

while (1) {
	ret = cmpxchg(addr)
	if (!ret)
		break;
	if (ret = -EFAULT)
		get_user_pages(addr);
}

Does anybody see a problem with that?
