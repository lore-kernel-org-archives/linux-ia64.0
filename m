From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Thu, 01 Apr 2004 14:11:08 +0000
Subject: SAL functions related questions...
Message-Id: <406C22FC.6090907@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



		Hi,


	I'm still working about INIT management problematics.

	I just have a question about SAL_GET_STATE_INFO function.
What does exactly mean a return code equal to "1" (e.g. "Call completed
without error but some information was lost due to overflow") ?
I always get this "error" back when pushing on the dump button on a 
Tiger4. What is it due to ?

And which size does exactly SAL_GET_STATE_INFO_SIZE return ? When should
this function be called to allocate large enough buffers (after 
receiving INIT interrupt or at kernel startup) ?

Thanks for your help.

Kind regards,


				Francois WELLENREITER

