From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 16 Dec 2002 22:11:21 +0000
Subject: Re: [Linux-ia64] gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805566@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805566@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 15:46:27 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> As I mentioned in the previous mail, I could not find any mail, bug
  Keith> reports or changelog entries that mentioned ia64 unwind or rlen being
  Keith> wrong.  Which makes me think that the bug exists in current binutils,
  Keith> however I cannot test that at the moment.

Trust me: there were at least 2 or 3 fixes; some in the compiler, some
in binutils.  Here is an example from gas:

2002-02-22  David Mosberger  <davidm@hpl.hp.com>

	* config/tc-ia64.c (dot_restore): Issue error message of epilogue
	count exceeds prologue count.
	(md_show_usage): Describe -mconstant-gp and -mauto-pic.
	(unwind.label_prologue_count): New member.

	Based on a patch by Hans Boehm <hboehm@hpl.hp.com>:

	(get_saved_prologue_count): New function.
	(save_prologue_count): New function.
	(free_saved_prologue_count): New function.
	(dot_label_state): Record state label by calling save_prologue_count().
	(dot_copy_state): Restore prologue count by calling
	get_saved_prologue_count().
	(generate_unwind_image): Free up list of saved prologue
	counts by calling free_saved_prologue_counts().

  --david

