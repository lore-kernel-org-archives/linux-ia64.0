From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 Jan 2004 17:57:43 +0000
Subject: RE: Link error with linux-2.5 bk
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FB0D3@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Andrew sent me the attached.  He seems to agree with your analysis & fix.

Why didn't this show up on other architecture builds?  Doesn't anyone
else discard .exit.text?  Or does everyone else have the default
for CONFIG_DUMMY set to 'n' or 'm' rather than 'y'?

I'd also like to nominate:

 local symbol 0: discarded in section `.exit.text' from drivers/built-in.o

for the "Least helpful error message" award(*).  From previous
experience I know that this is caused by improper use of
__exit ... but it would really help a lot if the message
had an actual symbol name, rather than "local symbol 0".

I found this by the brute force tactic of scanning backwards
through 2.6.1-bk* patches, building each one until the error
went away, and then getting a diff between the last good and
first bad version, and looking for __exit.  But there ought
to be a better way :-)

-Tony

* Previous held by "values of B will give rise to dom!"
