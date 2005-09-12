From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Sep 2005 01:11:22 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F045A8EA4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>I took a look, and quite frankly, I'm not at all happy about this.
>>
>>What's going on? Why would machine check interrupts muck with these 
>>things? Pls explain.. This is a total violation of all layering, and 
>>anybody who uses these things is just going to cause strange oopses etc 
>>crap.
>>
>>Wazzup?
>
>http://lkml.org/lkml/2005/9/8/315/.

Sorry.  I should have put that link into the original "please-pull"
message (or even better, checked to see if you'd seen this thread
before putting it into my release tree ... silence on LKML often
means that you didn't read the thread).

Does it help to lower your unhappiness level?

Can you see a better way to do this?

-Tony
