From: Keith Owens <kaos@sgi.com>
Date: Thu, 09 Dec 2004 01:10:26 +0000
Subject: Re: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <4111.1102554626@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Dec 2004 09:11:32 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>+	for (i = 1; i < 3; ++i) {
>>+		switch (i) {
>>+		case 1: t = find_task_by_pid(pid); break;
>>+		case 2: t = current; break;
>>+		default: t = idle_task(smp_processor_id()); break;
>>+		}
>
>"i" only takes the values "1", "2" in this loop, so we can't
>get to the default case.  s/</<=/ ???

/me dons brown paper bag.

