From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 21 Jan 2004 17:57:14 +0000
Subject: Re: Link error with linux-2.5 bk
Message-Id: <20040121095714.5e20b015.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Jan 2004 09:57:43 -0800 "Luck, Tony" <tony.luck@intel.com> wrote:

| > Andrew sent me the attached.  He seems to agree with your analysis & fix.
| 
| Why didn't this show up on other architecture builds?  Doesn't anyone
| else discard .exit.text?  Or does everyone else have the default
| for CONFIG_DUMMY set to 'n' or 'm' rather than 'y'?
| 
| I'd also like to nominate:
| 
|  local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
| 
| for the "Least helpful error message" award(*).  From previous
| experience I know that this is caused by improper use of
| __exit ... but it would really help a lot if the message
| had an actual symbol name, rather than "local symbol 0".
| 
| I found this by the brute force tactic of scanning backwards
| through 2.6.1-bk* patches, building each one until the error
| went away, and then getting a diff between the last good and
| first bad version, and looking for __exit.  But there ought
| to be a better way :-)

Having the build tools warn about it would be best.

However, after having got the message, you could also use this:
http://www.kernelnewbies.org/scripts/reference_discarded.pl

| * Previous held by "values of B will give rise to dom!"
| -


--
~Randy
kernel-janitors project:  http://janitor.kernelnewbies.org/
