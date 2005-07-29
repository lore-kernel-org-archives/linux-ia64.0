From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 01:53:33 +0000
Subject: RE: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <200507290153.j6T1rYg03861@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <42E98A6B.2090305@yahoo.com.au>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, July 28, 2005 6:46 PM
> I'd like to try making them less aggressive first if possible.

Well, that's exactly what I'm trying to do: make them not aggressive
at all by not performing any load balance :-)  The workload gets maximum
benefit with zero aggressiveness.

