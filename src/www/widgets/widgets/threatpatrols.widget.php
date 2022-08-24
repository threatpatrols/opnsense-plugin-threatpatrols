<?php

/*
    Copyright (c) 2022 Threat Patrols Pty Ltd <contact@threatpatrols.com>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

require_once("widgets/include/threatpatrols.inc");

$tp_repo_data = @json_decode(configd_run("threatpatrols repo info"), true);
if(empty($tp_repo_data)) { $tp_repo_data = array(); }
if(array_key_exists("url", $tp_repo_data) && array_key_exists("system_abi", $tp_repo_data)) {
    $tp_repo_data["url"] = str_replace('${ABI}', $tp_repo_data["system_abi"], $tp_repo_data["url"]);
}
if(array_key_exists("system_abi", $tp_repo_data)) {
    unset($tp_repo_data["system_abi"]);
}

$tp_installed_list = array();
foreach(explode("\n", configd_run("threatpatrols packages installed")) as $tp_installed_item) {
    $tp_installed_data = @json_decode($tp_installed_item, true);
    if(!empty($tp_installed_data)) {
        $tp_installed_list[] = $tp_installed_data;
    }
}

?>

<table class="table table-striped table-condensed">
    <tbody>

        <?php if (!empty($tp_repo_data)): ?>
        <tr>
            <th colspan="3">Repository</th>
        </tr>
        <?php foreach($tp_repo_data as $name => $value): ?>
        <tr>
            <td style="width: 20%;"><?php echo html_safe($name); ?></td>
            <td colspan="2"><?php echo html_safe($value); ?></td>
        </tr>
        <?php endforeach; ?>
        <?php endif; ?>

        <?php if (!empty($tp_installed_list)): ?>
        <tr>
            <th colspan="3">Packages Installed</th>
        </tr>
        <?php foreach($tp_installed_list as $tp_installed_item): ?>
        <tr>
            <td style="width: 20%;"><?php echo html_safe($tp_installed_item["name"]); ?></td>
            <td><?php echo html_safe($tp_installed_item["version"]); ?></td>
            <td style="width: 30%;"><?php echo html_safe($tp_installed_item["annotations"]["repository"]); ?></td>
        </tr>
        <?php endforeach; ?>
        <?php endif; ?>

    </tbody>

    <tfoot>
        <tr>
            <td colspan="3" style="padding-top: 20px;">
                <?php echo gettext("For more information, visit"); ?>
                <a target="_blank" rel="noopener noreferrer" href="https://documentation.threatpatrols.com/opnsense/">documentation.threatpatrols.com</a>
            </td>
        </tr>
    </tfoot>

</table>
