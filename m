From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 03 Jun 2008 06:02:09 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0806022302w50f36d28m33c5039d83e08228@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	 <20080526001527.81E1126FA9E@magilla.localdomain>
	 <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
	 <3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
	 <20080527040454.053C526FA9E@magilla.localdomain>
	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	 <20080527061209.9A24426FAA6@magilla.localdomain>
	 <3877989d0805270148h1b9e7972w880e380c2c4c9b09@mail.gmail.com>
	 <3877989d0805280214y645c7e0ex91a95f1fe47a6abf@mail.gmail.com>
In-Reply-To: <3877989d0805280214y645c7e0ex91a95f1fe47a6abf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> I'm trying upstream kdump to get more detailed data for help analysis
> the scenario..
Upstream kdump doesn't work! don't know what cause the regression,
possibly kexec-tools...
Need investigation here!
