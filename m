From: Keith Owens <kaos@sgi.com>
Date: Tue, 14 Dec 2004 01:26:23 +0000
Subject: Re: [RFC] Change the effect of SAL_{GET,CLEAR}_STATE_INFO for MCA/INIT records
Message-Id: <8877.1102987583@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12433.1102594994@ocs3.ocs.com.au>
In-Reply-To: <12433.1102594994@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Dec 2004 17:00:21 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>The OS MCA and, to a lesser extent, the INIT handlers have to decide if
>>the MCA/INIT is recoverable or not.  To make that decision, the OS
>>handlers need the current MCA/INIT record because that is the only
>>record that contains the data needed to make the decision.  If there
>>are multiple MCA/INIT records stored for a cpu then SAL_GET_STATE_INFO
>>returns the top record every time, resulting in bad data and invalid
>>decisions about recovery.
>
>Isn't all the information on whether the current MCA/INIT event is
>recoverable encoded in the processor state parameter ... which is
>passed to the OS by SAL in r18.  What do you need that requires that
>you get at the error record?

The PSP bits only tell us that the event might be recoverable.  We need
more data from the MCA record to make the final decision.

