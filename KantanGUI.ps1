Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$FontSize = 9
$TitleFontSize = 18
$FontName = '�l�r �S�V�b�N'

# �t�H���g�T�C�Y����
$DefaultFontHeight = $FontSize * (1 + 1 / 3)
# �t�H���g�T�C�Y��
$DefaultFontWidth = [Int]($DefaultFontHeight / 1.41421356) 
# �e�L�X�g�{�b�N�X�̍���
$DefaultTextHeight = 8 + $DefaultFontHeight
# �{�^���̊�{��
$BaseButtonWidth = 60
# �{�^���ɗ]���ɉ����镝
$DefaultButtonPaddingX = 0
# �{�^���̍���
$DefaultButtonHeight = 8 + $DefaultFontHeight
#�e�L�X�g�{�b�N�X�̊�{��
$BaseTextWidth = 120
# �`�F�b�N�{�b�N�X�̃T�C�Y
$CheckSize = 20

# �t�H�[���\���̃R�}���h���b�g
function KantanGUI-Show ($ProjectPath, $LayoutName, $ArgumentList) {
    $layout = KantanGUI-Load-Json "${ProjectPath}\${LayoutName}"
    
    # �K��l�̐ݒ�
    $Version = if($layout.Version){$layout.Version}else{0}
    $Title = if($layout.Title){$layout.Title}else{''}
    $TitleBar = if($layout.TitleBar){$layout.TitleBar}else{''}
    $Width = if($layout.Width){$layout.Width}else{0}
    $Height = if($layout.Height){$layout.Height}else{0}
    $StartY = if($layout.StartY){$layout.StartY}else{5}
    $PaddingX = if($layout.PaddingX){$layout.PaddingX}else{2}
    $PaddingY = if($layout.PaddingY){$layout.PaddingY}else{2}
    $Components = $layout.Components

    # Components�̃`�F�b�N
    if ($Components -eq $null) {
        throw 'layout��Components���܂܂�Ă��܂���'
        return
    } elseif ($Components.GetType().Name -ne 'Object[]') {
        $Components = @($Components)
    }

    if ($Components.Count -eq 0) {
        throw 'Components�͏��Ȃ��Ƃ���K�v�ł�'
        return
    }

    $returns = New-Object PSCustomObject

    $ReturnMethod = {
        Param($rObj)
        $rObj.psobject.properties.name | %{
            $returns | Add-Member -MemberType NoteProperty -Name $_ -Value $rObj.$_
        }
    }
    
    $form = New-Object System.Windows.Forms.Form
    $Table = KAntanGUI-Get-ComponentsList $ProjectPath $form $ArgumentList $ReturnMethod $Components $StartY $PaddingX $PaddingY ($Width / 1.1)

    $form.Text = $TitleBar
    if ($Width -le 0) {
        $Width = ($Table.TotalWidth * (1 + 1 / 16))
    }
    if ($Height -le 0) {
        $Height = ($Table.TotalHeight * (1 + 2 / 16))
    }
    $form.Size = New-Object System.Drawing.Size($Width, $Height)

    $Table.Components | %{
        if ($_.Component1) {
            $form.Controls.Add($_.Component1) | Out-Null
        }
        if ($_.Component2) {
            $form.Controls.Add($_.Component2) | Out-Null
        }
        if ($_.Component3) {
            $form.Controls.Add($_.Component3) | Out-Null
        }
    }

    if ($form.ShowDialog() -eq 'Cancel') {
        return $null
    }
    
    return $returns
}


function KantanGUI-Get-ComponentsList ($ProjectPath, [System.Windows.Forms.Form]$Form, $ArgumentList, $ReturnMethod, $Components, $StartY, $PaddingX, $PaddingY, $FormWidth) {
    $DandDList = New-Object Collections.ArrayList

    $Components | %{
        # �v���p�e�B�������ꍇ�͒ǉ�
        if('Id' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Id' -Value ''}
        if('Type' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Type' -Value ''}
        if('Label' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Label' -Value ''}
        if('Height' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Height' -Value 0}
        if('Default' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Default' -Value ''}
        if('Required' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Required' -Value $false}
        if('DandD' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'DandD' -Value $false}
        if('Items' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Items' -Value @()}
        if('Validation' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Validation' -Value $false}
        if('Close' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Close' -Value 'Always'}
        if('Target' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Target' -Value ''}
        if('Return' -notin $_.psobject.properties.name){$_ | Add-Member -MemberType NoteProperty -Name 'Return' -Value $false}

        # �K��l�̐ݒ�
        $_.Id = if($_.Id){$_.Id}else{''}
        $_.Type = if($_.Type){$_.Type}else{''}
        $_.Label = if($_.Label){$_.Label}else{''}
        $_.Height = if($_.Height){$_.Height}else{0}
        $_.Default = if($_.Default){$_.Default}else{''}
        $_.Required = if($_.Required){$_.Required}else{$false}
        $_.DandD = if($_.DandD){$_.DandD}else{$false}
        $_.Items = if($_.Items){$_.Items}else{@()}
        $_.Validation = if($_.Validation){$_.Validation}else{$false}
        $_.Close = if($_.Close){$_.Close}else{'Always'}
        $_.Target = if($_.Target){$_.Target}else{''}
        $_.Return = if($_.Return){$_.Return}else{$false}

        if ($_.Type -eq '') {
            throw 'Type�͕K���K�v�ł�'
            return
        }

        $_ | Add-Member -MemberType NoteProperty -Name 'Component1' -Value $null
        $_ | Add-Member -MemberType NoteProperty -Name 'Component2' -Value $null
        $_ | Add-Member -MemberType NoteProperty -Name 'Component3' -Value $null
        $_ | Add-Member -MemberType NoteProperty -Name 'Width1' -Value 0
        $_ | Add-Member -MemberType NoteProperty -Name 'Width2' -Value 0
        $_ | Add-Member -MemberType NoteProperty -Name 'Width3' -Value 0

        $c = $_
        
        switch($c.Type){
            'Label'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component1.Text = $c.Label
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Height = $DefaultFontHeight
            }
            'Title'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component1.Text = $c.Label
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$TitleFontSize)
                $c.Width1 = ((KAntanGUI-Get-Width $c.Label) * $TitleFontSize / $FontSize)
                $c.Height = ($DefaultFontHeight * $TitleFontSize / $FontSize)
            }
            'Blank'{
                # Blank�͍��������݂̂Ȃ̂ŏ����Ȃ�
            }
            'Text'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Height = $DefaultTextHeight
            }
            'Number'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Height = $DefaultTextHeight
            }
            'Check'{
                $c.Component2 = New-Object System.Windows.Forms.CheckBox
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Text = $c.Label
                $c.Component2.Checked = $c.Default
                $c.Width2 = (KAntanGUI-Get-Width $c.Label) + $CheckSize
                $c.Height = if($DefaultFontHeight -lt $CheckSize){$CheckSize}else{$DefaultFontHeight}
            }
            'List'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.ComboBox
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Items | %{
                    $c.Component2.Items.Add($_)|Out-Null
                }
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Component2.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Height = $DefaultTextHeight
            }
            'OpenFile'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Component3.Text = "�J��"
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Width3 = (KAntanGUI-Get-Width '�t�@�C��') + $DefaultButtonPaddingX
                $dialog = New-Object System.Windows.Forms.OpenFileDialog
                $dialog.Filter = '�S�Ẵt�@�C��(*.*)|*.*'
                $dialog.Title = "�t�@�C�����J��"
                $dialog.Multiselect = $false
                $c.Component3.Add_Click({
                    if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
                        $c.Component2.Text = $dialog.FileName
                    }
                }.GetNewClosure())

                $DandDList.Add($c)|Out-Null

                $c.Height = $DefaultButtonHeight
            }
            'OpenFolder'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Component3.Text = "�J��"
                $c.Width1 = $Label.Length * $DefaultFontWidth
                $c.Width3 = (KAntanGUI-Get-Width '�t�@�C��') + $DefaultButtonPaddingX
                $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
                $c.Component3.Add_Click({
                    if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
                        $c.Component2.Text = $dialog.SelectedPath
                    }
                }.GetNewClosure())

                $DandDList.Add($c)|Out-Null

                $c.Height = $DefaultButtonHeight
            }
            'SaveFile'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Component3.Text = "�ۑ�"
                $c.Width1 = KAntanGUI-Get-Width $c.Label
                $c.Width3 = (KAntanGUI-Get-Width '�t�@�C��') + $DefaultButtonPaddingX
                $dialog = New-Object System.Windows.Forms.SaveFileDialog
                $dialog.Filter = '�S�Ẵt�@�C��(*.*)|*.*'
                $dialog.Title = "�t�@�C����ۑ�"
                $c.Component3.Add_Click({
                    if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
                        # �����I���������Ă��鎞�� $dialog.FileNames �𗘗p����
                        $c.Component2.Text = $dialog.FileName
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'SaveFolder'{
                $c.Component1 = New-Object System.Windows.Forms.Label
                $c.Component2 = New-Object System.Windows.Forms.TextBox
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component1.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component2.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component1.Text = $c.Label
                $c.Component2.Text = $c.Default
                $c.Component3.Text = "�ۑ�"
                $c.Width1 = $Label.Length * $DefaultFontWidth
                $c.Width3 = (KAntanGUI-Get-Width '�t�@�C��') + $DefaultButtonPaddingX
                $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
                $c.Component3.Add_Click({
                    if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
                        # �����I���������Ă��鎞�� $dialog.FileNames �𗘗p����
                        $c.Component2.Text = $dialog.SelectedPath
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'ButtonCmd'{
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Text = $c.Label
                $c.Width3 = (KAntanGUI-Get-Width $c.Label) + $DefaultButtonPaddingX

                $c.Component3.Add_Click({
                    try{
                        . "${PSScriptRoot}\KantanGUI.ps1"
                        if($c.Validation) {
                            if (-not (KantanGUI-Valid-Components $Components)) {
                                return
                            }
                        }
                        #����
                        $cmdStr = ". `"${ProjectPath}\$($c.Target)`" "
                        $Components | %{
                            if ($_.Return) {
                                $c2 = $_
                                switch ($c2.Type) {
                                    'Number' {
                                        $cmdStr += "$($c2.Component2.Text) "
                                    }
                                    'Check' {
                                        $cmdStr += "$($c2.Component2.Checked) "
                                    }
                                    default {
                                        $cmdStr += "`"$($c2.Component2.Text)`" "
                                    }
                                }
                            }
                        }
                        Invoke-Expression $cmdStr | Out-Null
                        if ((KantanGUI-Is-Closing $LASTEXITCODE $c.Close)) {
                            $Form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                            $Form.Close()
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '�v���I�ȃG���[', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | out-null
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'ButtonCmdNamed'{
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Text = $c.Label
                $c.Width3 = (KAntanGUI-Get-Width $c.Label) + $DefaultButtonPaddingX

                $c.Component3.Add_Click({
                    try{
                        . "${PSScriptRoot}\KantanGUI.ps1"
                        if($c.Validation) {
                            if (-not (KantanGUI-Valid-Components $Components)) {
                                return
                            }
                        }
                        #����
                        $cmdStr = ". `"${ProjectPath}\$($c.Target)`" "
                        $Components | %{
                            if ($_.Return) {
                                $c2 = $_
                                switch ($c2.Type) {
                                    'Number' {
                                        $cmdStr += "-$($c2.Id) $($c2.Component2.Text) "
                                    }
                                    'Check' {
                                        $cmdStr += "-$($c2.Id) $($c2.Component2.Checked) "
                                    }
                                    default {
                                        $cmdStr += "-$($c2.Id) `"$($c2.Component2.Text)`" "
                                    }
                                }
                            }
                        }
                        Invoke-Expression $cmdStr | Out-Null
                        if ((KantanGUI-Is-Closing $LASTEXITCODE $c.Close)) {
                            $Form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                            $Form.Close()
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '�v���I�ȃG���[', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | out-null
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'ButtonForm'{
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Text = $c.Label
                $c.Width3 = (KAntanGUI-Get-Width $c.Label) + $DefaultButtonPaddingX
                $c.Component3.Add_Click({
                    try{
                        . "${PSScriptRoot}\KantanGUI.ps1"
                        if($c.Validation) {
                            if (-not (KantanGUI-Valid-Components $Components)) {
                                return
                            }
                        }
                        #����
                        $rObj = New-Object PSCustomObject
                        $Components | %{
                            if ($_.Return) {
                                $rObj | Add-Member -MemberType NoteProperty -Name $_.Id -Value $_.Component2.Text
                            }
                        }
                        KantanGUI-Show $c.Target $rObj | Out-Null
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '�v���I�ȃG���[', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | out-null
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'ButtonOK'{
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Text = $c.Label
                $c.Width3 = (KAntanGUI-Get-Width $c.Label) + $DefaultButtonPaddingX
                $c.Component3.Add_Click({
                    try{
                        . "${PSScriptRoot}\KantanGUI.ps1"
                        if((-not $c.Validation) -and (KantanGUI-Valid-Components $Components)) {
                            #����
                            $rObj = New-Object PSCustomObject
                            $Components | %{
                                if ($_.Return) {
                                    $rObj | Add-Member -MemberType NoteProperty -Name $_.Id -Value $_.Component2.Text
                                }
                            }
                            Invoke-Command -ScriptBlock $ReturnMethod -ArgumentList @($rObj)
                            $Form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                            $Form.Close()
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '�v���I�ȃG���[', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | out-null
                    }
                }.GetNewClosure())
                $c.Height = $DefaultButtonHeight
            }
            'ButtonCancel'{
                $c.Component3 = New-Object System.Windows.Forms.Button
                $c.Component3.Font = New-Object System.Drawing.Font($FontName,$FontSize)
                $c.Component3.Text = $c.Label
                $c.Width3 = (KAntanGUI-Get-Width $c.Label) + $DefaultButtonPaddingX
                $c.Height = $DefaultButtonHeight
                $c.Component3.Add_Click({
                    $Form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    $Form.Close()
                }.GetNewClosure())

            }
            default{
                throw "�R���|�[�l���gId'${Id}'�Ɋ܂܂��Type'${Type}'�𔻕ʂł��܂���B"
                return
            }
        }
    }

    # �����v�Z
    $MaxWidth1 = (KAntanGUI-Get-MaxOfArray $Components.Width1)
    $MaxWidth2 = (KAntanGUI-Get-MaxOfArray $Components.Width2)
    $MaxWidth3 = (KAntanGUI-Get-MaxOfArray $Components.Width3)

    # �{�^���̃T�C�Y���C��
    $MaxWidth3 = if ($MaxWidth3 -lt $BaseButtonWidth) {$BaseButtonWidth} else {$MaxWidth3}
    
    # �e�L�X�g�{�b�N�X�̃T�C�Y���C��
    if ($FormWidth -le 0) {
        # �t�H�[���̕����w�肳��ĂȂ��ꍇ�́A�e�L�X�g�{�b�N�X�̊�{�T�C�Y��K�p
        $MaxWidth2 = if ($MaxWidth2 -lt $BaseTextWidth) {$BaseTextWidth} else {$MaxWidth2}
    } else {
        $MaxWidth2 = $FormWidth - $MaxWidth1 - $MaxWidth3
    }

    # �ʒu�����肷��
    $y = $StartY + $PaddingY
    
    $Components | %{
        if($_.Component1 -ne $null){
            $_.Component1.Location = New-Object System.Drawing.Point($PaddingX, $y)
            $_.Component1.Size = New-Object System.Drawing.Point($MaxWidth1, $_.Height)
        }
        if($_.Component2 -ne $null){
            $_.Component2.Location = New-Object System.Drawing.Point(($PaddingX * 2 + $MaxWidth1), $y)
            $_.Component2.Size = New-Object System.Drawing.Point($MaxWidth2, $_.Height)
            if ($_.Id -in $ArgumentList.Keys) {
                if ($_.Type -eq 'Check') {
                    $_.Component2.Checked = $ArgumentList.($_.Id)
                } else {
                    $_.Component2.Text = $ArgumentList.($_.Id)
                }
            }
        }
        if($_.Component3 -ne $null){
            $_.Component3.Location = New-Object System.Drawing.Point(($PaddingX * 3 + $MaxWidth1 + $MaxWidth2), $y)
            $_.Component3.Size = New-Object System.Drawing.Point($MaxWidth3, $_.Height)
        }
        $y += $_.Height+ $PaddingY
    }

    
    # �t�H�[����D&D
    if($DandDList.Count -gt 0) {
        $Form.AllowDrop = $true
        $Form.Add_DragOver({
            $arg = $_
            foreach ($filename in $arg.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
                $arg.Effect = [Windows.Forms.DragDropEffects]::All
            }
        })
        $Form.Add_DragDrop({
            $arg = $_
            foreach ($filename in $arg.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
                if (Test-Path $filename -PathType Leaf) {
                    $DandDList | %{
                        if ($_.Type -eq 'OpenFile') {
                            $_.Component2.Text = $filename
                        }
                    }
                } elseif (Test-Path $filename -PathType Container) {
                    $DandDList | %{
                        if ($_.Type -eq 'OpenFolder') {
                            $_.Component2.Text = $filename
                        }
                    }
                }
            }
        }.GetNewClosure())
    }

    return New-Object PSCustomObject -Property @{
            MaxWidth1 = $MaxWidth1;
            MaxWidth2 = $MaxWidth2;
            MaxWidth3 = $MaxWidth3;
            TotalWidth = $PaddingX * 4 + $MaxWidth1 + $MaxWidth2 + $MaxWidth3;
            TotalHeight = $y;
            Components = $Components;
        }
}

# �R���|�[�l���g�̃o���f�[�V�����ƃG���[�\�����s��
function KantanGUI-Valid-Components ($Components) {
    $rcode = $true
    :lp foreach($_ in $Components){
        if($_.Required -and $_.Component2.Text -eq ''){
            $_.Component2.Focus() | out-null
            [System.Windows.Forms.MessageBox]::Show("$($_.Label)'�͕K�{�ł��B", '���̓G���[') | out-null
            $rcode = $false
            break lp
        }
        $num = 0
        if ($_.Type -eq 'Number') {
            if (-not $_.Required -and $_.Component2.Text -eq '') {
            
            } elseif (-not [double]::TryParse($_.Component2.Text,[ref]$num)) {
                $_.Component2.Focus() | out-null
                [System.Windows.Forms.MessageBox]::Show("$($_.Label)'�͐��l����͂��Ă��������B", '���̓G���[') | out-null
                $rcode = $false
                break lp
            }
        }
    }
    return $rcode
}

# �t�H�[���̃{�^�����������ۂɁA�t�H�[������邩�ǂ���
function KantanGUI-Is-Closing ($rcode, $close) {
    switch($close) {
        'Always' {
            return $true
        }
        'Success' {
            if ($rcode -eq 0) {
                return $true
            } else {
                return $false
            }
        }
        'Failure' {
            if ($rcode -eq 0) {
                return $false
            } else {
                return $true
            }
        }
        'None' {
            return $false
        }
    }
    return $true
}

function KantanGUI-Get-Width ($str) {
    return [System.Text.Encoding]::GetEncoding("shift_jis").GetByteCount($str) * $DefaultFontWidth
}

function KantanGUI-Get-MaxOfArray ($array) {
    $max = 0
    $array | %{
        $max = if($_ -lt $max){$max}else{$_}
    }
    return $max
}


function KantanGUI-Load-Json ($JsonPath) {
    if (-not (Test-Path $JsonPath -PathType Leaf)) {
        throw "�w�肳�ꂽ�t�@�C��('${JsonPath}')������܂���"
    }
    return ("$(Get-Content -Encoding utf8 $JsonPath)" | ConvertFrom-Json)
}
