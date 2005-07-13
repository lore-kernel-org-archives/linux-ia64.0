From: Andrew Morton <akpm@osdl.org>
Date: Wed, 13 Jul 2005 02:02:31 +0000
Subject: Re: [PATCH]Kprobes IA64 - Fix race when break hits and kprobe not
Message-Id: <20050712190231.789da83c.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050712185230.A8528@unix-os.sc.intel.com>
In-Reply-To: <20050712185230.A8528@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, prasanna@in.ibm.com

Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com> wrote:
>
> This patch applies on top of  "Prasanna S Panchamukhi's" recent postings
>  Kprobes: Prevent possible race condition ia64 changes

I am not aware of such a patch.  Your patch hit a reject when I tried to
apply it to Linus's tree.  So I don't know what's going on..
