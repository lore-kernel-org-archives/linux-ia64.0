From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 22 Jun 2004 22:38:19 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <40D8B4DB.7020901@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/22/2004 2:23 PM, Bjorn Helgaas wrote:

> On Tuesday 22 June 2004 3:16 pm, Grant Grundler wrote:
>> On Tue, Jun 22, 2004 at 09:59:11AM -0600, Bjorn Helgaas wrote:
>> > David saw this late last week on a 2.6.7 kernel compiled for UP,
>> 
>> This is for SMP
> 
> Yeah, I saw it with slightly different "console=" parameters than
> David did.  So I think it's just a heisenbug and he happened to
> trip over it with a UP kernel.

I saw it on a 4 way Tiger as well. The kernel was compiled using the RHEL3 toolchain.
Saw the machine sitting in dispatch_to_fault_handler: with the IIP pointing to count_reserved_pages(). I think IFA was 0.

Didn't get a chance to debug this further.

	-Arun

