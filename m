From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Oct 2003 20:36:32 +0000
Subject: RE: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106702782513709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> One other neat thing about Itanium architecture is the capability of
>> it's performance counter.  It has capability to do cycle accounting
that
>> break-down the number of cycles that are lost due to various kinds of
>> micro-architectural events, it is based on CPU's actual stall cycles
in
>> the pipeline so you can see exactly where the stall is coming from to
>> eliminate any guess work.
>
>Are qprof and pfmon enough to do this ?

Yes.

>> See electron compiler user's guide for PGO methodology:
>>
http://www.intel.com/software/products/compilers/c60l/resources/c_ug_lnx
>> .pdf
>
>Is this the same for 7.x ?

I think so.

- Ken
