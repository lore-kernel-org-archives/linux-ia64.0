From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Tue, 29 Jun 2004 16:20:49 +0000
Subject: RE: Why large stack frame for PAL call
Message-Id: <9AB83E4717F13F419BD880F5254709E502FF6803@scsmsx402.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
In-Reply-To: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W <> wrote on Tuesday, June 29, 2004 8:14 AM:

> David Mosberger wrote on Monday, June 28, 2004 10:50 PM
>> 
>>   Ken> Does anyone know why we need such large stack frame for PAL
>>   Ken> static call?  PAL isn't even suppose to touch any stack
>>   Ken> register for static calling convention.  Is it for legacy
Ken>
>> reason or something? 
>> 
>> Good question.  I was able to track the source down to a patch that
>> was sent to me by Walt Drummond on Aug 11, 1999.  The authors listed
>> in the relevant file (it was called palcall.S back then) were Don
>> Dugger and Walt Drummond (in this order), so my guess is the code was
>> originally written by Don.  At that time, the primary target for Don
>> would have been SoftSDV.  Perhaps it was to work around a bug in
>> SoftSDV, though I suspect it's just as likely that the code came
about
>> by a misunderstood/misdocumented PAL-requirement.
>> 
>> Perhaps Don or Asit remember how this came about?
>> 
>> I also cannot find a requirement that would demand allocating 96
>> stacked registers before making a PAL call and I'd be in favor of
>> cleaning that up.
> 
> Checked with Asit. Yes, this was more of a conservative code just like
> what Don said.  Patch to clean it up.

I rechecked some of my old documents and found that there was version of
the SDM that stated that the caller should ensure that all 96 stacked
registers are available before calling PAL procedure. However, this
restriction was removed in subsequent documents and is no longer needed.
The code did not get updated. So, Ken's patch should be fine.

Thanks,
Asit
