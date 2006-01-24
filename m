From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 24 Jan 2006 23:36:36 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601242336.k0ONaag16228@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 3:29 PM
> Take 4.  Moved "really migrated?" check as late as possible in
> __switch_task(), and moved thread_info last_cpu field closer to
> flags and cpu fields.  Some nomenclature changes as well.

I think you should seriously consider my other proposal :-)

- Ken

