From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Apr 2006 17:31:36 +0000
Subject: RE: booting with `mem=' on an Altix (or other NUMA machine)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06349A4E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17467.2252.70039.423224@wombat.chubb.wattle.id.au>
In-Reply-To: <17467.2252.70039.423224@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> that was discussed before:
>> http://marc.theaimsgroup.com/?l=linux-ia64&m9718964113183&w=2
>
>I only see a patch there but no discussion.

It doesn't look like this would solve the NUMA issue.  Maybe you'd
want a "mempernode=" boot parameter?  But this would likely get complex
in a hurry as various people add more options to meet their specific
needs.

-Tony
