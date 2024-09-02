classdef ClassAcousticSystem < handle
    properties (Constant = true)
        bitRate = 16   * 1024
    end
    properties
        sampleRateTx
        digitsTx
        sampleRateRx
        digitsRx
        pilotSubcarrierStep


        imitationType
        mappingType
        modulationType
        infoType

        dataSize % примечание для разнесения кода на два устройства: на приемной стороне используется в decodeInfo

        OFDMsymbolsNum % примечание для разнесения кода на два устройства: на приемной стороне используется в synchronizeTimeByMinn
        OFDMsymbolTimeLen
        OFDMsymbolTimeVectorLen

        frequencies

        Fcentral

        subcarrierDistance

        isSourceInterleaver
        sourceInterleaverState

        isChannelEncoder
        trellis
        encoderType

        isChannelInterleaver
        channelInterleaverState

        isEqualizer
        isFilter

        CPlen
        minnSymbolNum
        minnPartType

        infoModulationOrder
        infoSubcarrierNum
        infoSubcarrierInd

        pilotModulationOrder
        pilotSubcarrierNum
        pilotSubcarrierInd

        isNullExist
        nullSubcarrierNum
        nullSubcarrierInd
    end

    methods

        function obj            = ClassAcousticSystem           (options)
            % Конструктор класса. Объявляет параметры и запускает имитацию
            % заданного типа.
            arguments
                options.imitationType        (1,1) {mustBeNumeric}   = 1        % 0 - излучение, 1 - модель, 3 - BER, 4 - канал
                options.subcarrierDistance   (1,1) {mustBeNumeric}   = 200      % 200
                options.mappingType          string                  = 'qam'    % PSK или QAM
                options.modulationType       string                  = 'ofdm'   % OFDM; TODO: FMBC
                options.infoModulationOrder  (1,1) {mustBeNumeric}   = 16       % 16
                options.pilotModulationOrder (1,1) {mustBeNumeric}   = 4        % 4
                options.Fcentral             (1,1) {mustBeNumeric}   = 12e3     % 12e3
                options.isNullExist          logical                 = false    % используем ли нулевые поднесущие
                options.infoType             string                  = 'txt'    % txt или png
                options.CPlen                double                  = 1/4;     % 1/4
                options.minnSymbolNum        (1,1) {mustBeNumeric}   = 64;      % 32 (>3)
                options.minnPartType         string                  = 'chirp'  % usual или chirp
                options.isSourceInterleaver  logical                 = false    % НЕ используем внешнее перемеживание
                options.isChannelEncoder     logical                 = false     % используем ли внутреннее кодирование
                options.encoderType          string                  = 'bch'    % bch или conv
                options.isChannelInterleaver logical                 = false     % используем ли внутреннее перемеживание
                options.isEqualizer          logical                 = true     % используем ли эквалайзер
                options.isFilter             logical                 = false    % НЕ используем фильтр
                options.sampleRateTx         (1,1) {mustBeNumeric}   = 96e3     % 96e3 или 48e3 частота дискретизации ПдУ
                options.sampleRateRx         (1,1) {mustBeNumeric}   = 96e3     % 96e3 или 48e3 частота дискретизации ПpУ зависит от параметров устройства
                options.digitsTx             (1,1) {mustBeNumeric}   = 16       % 8, 16 ии 24 разрядность квантователя ЦАП ПдУ зависит от параметров устройства
                options.digitsRx             (1,1) {mustBeNumeric}   = 16       % 8, 16 ии 24 разрядность квантователя ЦАП ПpУ зависит от параметров устройства
                options.pilotSubcarrierStep  (1,1) {mustBeNumeric}   = 3        % 3 (>1)
            end
            obj.imitationType            = options.imitationType;
            obj.subcarrierDistance       = options.subcarrierDistance;
            obj.mappingType              = options.mappingType;
            obj.modulationType           = options.modulationType;
            obj.infoModulationOrder      = options.infoModulationOrder;
            obj.pilotModulationOrder     = options.pilotModulationOrder;
            obj.Fcentral                 = options.Fcentral;
            obj.isNullExist              = options.isNullExist;
            obj.infoType                 = options.infoType;
            obj.CPlen                    = options.CPlen;
            obj.minnSymbolNum            = options.minnSymbolNum;
            obj.minnPartType             = options.minnPartType;
            obj.isSourceInterleaver      = options.isSourceInterleaver;
            obj.isChannelEncoder         = options.isChannelEncoder;
            obj.encoderType              = options.encoderType;
            obj.isChannelInterleaver     = options.isChannelInterleaver;
            obj.isEqualizer              = options.isEqualizer;
            obj.isFilter                 = options.isFilter;
            obj.sampleRateTx             = options.sampleRateTx;
            obj.sampleRateRx             = options.sampleRateRx;
            obj.digitsTx                 = options.digitsTx;
            obj.digitsRx                 = options.digitsRx;
            obj.pilotSubcarrierStep      = options.pilotSubcarrierStep;

            clc
            close all

            imitation(obj,obj.imitationType);
        end


        function obj            = setDefaultParameters          (obj)
            obj.subcarrierDistance      = 200;
            obj.mappingType             = 'qam';
            obj.modulationType          = 'ofdm';
            obj.infoModulationOrder     = 16;
            obj.pilotModulationOrder    = 4;
            obj.Fcentral                = 12e3;
            obj.isNullExist             = false;
            obj.infoType                = 'txt';
            obj.CPlen                   = 1/4;
            obj.minnSymbolNum           = 64;
            obj.minnPartType            = 'chirp';
            obj.isSourceInterleaver     = false;
            obj.isChannelEncoder        = false;
            obj.encoderType             = 'bch';
            obj.isChannelInterleaver    = false;
            obj.isEqualizer             = true;
            obj.isFilter                = false;
            obj.sampleRateTx            = 96e3;
            obj.sampleRateRx            = 96e3;
            obj.digitsTx                = 16;
            obj.digitsRx                = 16;
            obj.pilotSubcarrierStep     = 3;
        end


        function obj            = imitation                     (obj,imitationType)
            tic
            switch imitationType
                case {0,1}
                    switch imitationType
                        case 0
                            fprintf('%s ========== ПЕРЕДАЧА И ПРИЕМ СИГНАЛА ==========\n', datetime);
                        case 1
                            fprintf('%s ========== ИМИТАЦИЯ ==========\n', datetime);
                    end
                    isShowAnyInfo = [1 1 1];
                    inputData                   = generateInfo          (obj,isShowAnyInfo,obj.infoType);
                    calculateChannelParameters                          (obj,isShowAnyInfo);
                    signalSourceInterleaved     = interleaver           (obj,isShowAnyInfo,obj.isSourceInterleaver,inputData,obj.sourceInterleaverState);
                    info                        = toBinary              (obj,isShowAnyInfo,signalSourceInterleaved);
                    infoEncoded                 = channelEncoder        (obj,isShowAnyInfo,obj.isChannelEncoder,info,obj.trellis);
                    signalChannelInterleaved    = interleaver           (obj,isShowAnyInfo,obj.isChannelInterleaver,infoEncoded,obj.channelInterleaverState);
                    infoMapped                  = mapInfo               (obj,isShowAnyInfo,signalChannelInterleaved,obj.mappingType,obj.infoModulationOrder);
                    signalFormed                = formSignal            (obj,isShowAnyInfo,infoMapped);
                    signalModulated             = modulateSignal        (obj,isShowAnyInfo,signalFormed,obj.modulationType);
                    signalPrefixed              = addPrefix             (obj,isShowAnyInfo,signalModulated,'cp');
                    signalWithPreamble          = addPreamble           (obj,isShowAnyInfo,signalPrefixed,obj.minnSymbolNum,obj.minnPartType);
                    switch imitationType
                        case 0
                            signalTimeLen       = transmitSignal        (obj,isShowAnyInfo,signalWithPreamble,obj.sampleRateTx,obj.digitsTx);
                            signalReceived      = receiveSignal         (obj,isShowAnyInfo,signalTimeLen+0.4,obj.sampleRateRx,obj.digitsRx);
                        case 1
                            calculatePAPR(obj,signalPrefixed,1,1);
                            signalReceived      = modelChannel          (obj,isShowAnyInfo,signalWithPreamble,obj.sampleRateTx,obj.digitsTx,obj.sampleRateRx,obj.digitsRx);
                    end
                    signalSynchronized          = synchronizeTimeByMinn (obj,isShowAnyInfo,signalReceived, obj.minnSymbolNum);
                    signalFiltered              = filterSignal          (obj,isShowAnyInfo,obj.isFilter,signalSynchronized);
                    signalPostfixed             = deletePrefix          (obj,isShowAnyInfo,signalFiltered);
                    signalDemodulated           = demodulateSignal      (obj,isShowAnyInfo,signalPostfixed,obj.modulationType);
                    signalEqualised             = equalizeSubcarriers   (obj,isShowAnyInfo,obj.isEqualizer,signalDemodulated);
                    infoDemapped                = demapInfo             (obj,isShowAnyInfo,signalEqualised,obj.mappingType);
                    signalChannelDeinterleaved  = deinterleaver         (obj,isShowAnyInfo,obj.isChannelInterleaver,infoDemapped,obj.channelInterleaverState);
                    infoDecoded                 = channelDecoder        (obj,isShowAnyInfo, obj.isChannelEncoder, signalChannelDeinterleaved);
                    outputData                  = toDecimal             (obj,isShowAnyInfo,infoDecoded);
                    signalSourceDeinterleaved   = deinterleaver         (obj,isShowAnyInfo,obj.isSourceInterleaver,outputData,obj.sourceInterleaverState);
                    showResults                                         (obj,isShowAnyInfo,inputData,signalSourceDeinterleaved,obj.infoType);
                case 2
                    fprintf('%s ========== ВЫЧИСЛЕНИЕ ПАРАМЕТРОВ ==========\n', datetime);
                    calculateChannelParameters(obj,1);
                case 3
                    fprintf('%s ========== ВЫЧИСЛЕНИЕ БИТОВОЙ ОШИБКИ ==========\n', datetime);
                    isGraph = 1;
                    isTransmit = 1;
                    isShowAnyInfo = [0 0 0];
                    expNum = 3;
                    setDefaultParameters(obj);
                    inputData               = generateInfo          (obj,isShowAnyInfo,obj.infoType);
                    % experimentsToDo = [1 2 3 4 5 6 7 8 9 10 11 12];
                    experimentsToDo = [ 8 ];
                    for experiment = 1:length(experimentsToDo)
                        setDefaultParameters(obj);
                        switch experimentsToDo(experiment)
                            case 1
                                dataArr = [50 100 200 500 1000 2000];
                                parameter = 'Частотное разнесение поднесущих, Гц';
                            case 2
                                dataArr = [0 1/8 1/4 1/2 3/4 7/8];
                                parameter = 'Длительность ЦП, длительности символа';
                            case 3
                                dataArr = [2 4 8 16 32 64 128];
                                parameter = 'Число синхроимпульсов, шт.';
                            case 4
                                dataArr = [4 8 16 32];
                                parameter = 'Порядок манипуляции';
                            case 5
                                dataArr = [0 1];
                                parameter = 'Тип манипуляции';
                            case 6
                                dataArr = [5e3 7e3 12e3 18e3];
                                parameter = 'Центральная частота, Гц';
                            case 7
                                dataArr = [0 1];
                                parameter = 'Наличие канального кодирования';
                            case 8
                                dataArr = [0 1];
                                parameter = 'Наличие перемежителя';
                            case 9
                                dataArr = [0 1];
                                parameter = 'Наличие эквалайзера';
                            case 10
                                dataArr = [48e3 96e3];
                                parameter = 'Частота дискретизации ПдУ и ПрУ, Гц';
                            case 11
                                dataArr = [8 16 24];
                                parameter = 'Разрядность квантователя ПдУ и ПрУ, бит';
                            case 12
                                dataArr = [2 3 4 5 7 10];
                                parameter = 'Шаг пилотных поднесущих';
                            otherwise
                                error("Неверный номер исследования")
                        end
                        fprintf('%d Переменный параметр - %s \n', experiment, parameter);
                        % SER = zeros(expNum,length(dataArr));
                        BER = zeros(expNum,length(dataArr));
                        for i = 1:length(dataArr)
                            fprintf('Устанавливаем параметр равным %d \n', dataArr(i));
                            for j = 1:expNum
                                fprintf('\t %dй эксперимент \n', j);
                                switch experimentsToDo(experiment)
                                    case 1
                                        obj.subcarrierDistance = dataArr(i);
                                    case 2
                                        obj.CPlen = dataArr(i);
                                    case 3
                                        obj.minnSymbolNum = dataArr(i);
                                    case 4
                                        obj.infoModulationOrder = dataArr(i);
                                    case 5
                                        if dataArr(i) == 0
                                            obj.mappingType = 'PSK';
                                        elseif dataArr(i) == 1
                                            obj.mappingType = 'QAM';
                                        end
                                    case 6
                                        obj.Fcentral = dataArr(i);
                                    case 7
                                        obj.isChannelEncoder = dataArr(i);
                                    case 8
                                        obj.isChannelInterleaver = dataArr(i);
                                    case 9
                                        obj.isEqualizer = dataArr(i);
                                    case 10
                                        obj.sampleRateTx = dataArr(i);
                                        obj.sampleRateRx = dataArr(i);
                                    case 11
                                        obj.digitsTx = dataArr(i);
                                        obj.digitsRx = dataArr(i);
                                    case 12
                                        obj.pilotSubcarrierStep = dataArr(i);
                                end
                                try
                                    calculateChannelParameters                          (obj,isShowAnyInfo);
                                    signalSourceInterleaved     = interleaver           (obj,isShowAnyInfo,obj.isSourceInterleaver,inputData,obj.sourceInterleaverState);
                                    info                        = toBinary              (obj,isShowAnyInfo,signalSourceInterleaved);
                                    infoEncoded                 = channelEncoder        (obj,isShowAnyInfo,obj.isChannelEncoder,info,obj.trellis);
                                    signalChannelInterleaved    = interleaver           (obj,isShowAnyInfo,obj.isChannelInterleaver,infoEncoded,obj.channelInterleaverState);
                                    infoMapped                  = mapInfo               (obj,isShowAnyInfo,signalChannelInterleaved,obj.mappingType,obj.infoModulationOrder);
                                    signalFormed                = formSignal            (obj,isShowAnyInfo,infoMapped);
                                    signalModulated             = modulateSignal        (obj,isShowAnyInfo,signalFormed,obj.modulationType);
                                    signalPrefixed              = addPrefix             (obj,isShowAnyInfo,signalModulated,'cp');
                                    signalWithPreamble          = addPreamble           (obj,isShowAnyInfo,signalPrefixed,obj.minnSymbolNum,obj.minnPartType);
                                    if isTransmit
                                        signalTimeLen           = transmitSignal            (obj,isShowAnyInfo,signalWithPreamble,obj.sampleRateTx,obj.digitsTx);
                                        signalReceived          = receiveSignal             (obj,isShowAnyInfo,signalTimeLen+0.4,obj.sampleRateRx,obj.digitsRx);
                                    else
                                        signalReceived          = modelChannel              (obj,isShowAnyInfo,signalWithPreamble,obj.sampleRateTx,obj.digitsTx,obj.sampleRateRx,obj.digitsRx);
                                    end
                                    signalSynchronized          = synchronizeTimeByMinn (obj,isShowAnyInfo,signalReceived, obj.minnSymbolNum);
                                    signalFiltered              = filterSignal          (obj,isShowAnyInfo,obj.isFilter,signalSynchronized);
                                    signalPostfixed             = deletePrefix          (obj,isShowAnyInfo,signalFiltered);
                                    signalDemodulated           = demodulateSignal      (obj,isShowAnyInfo,signalPostfixed,obj.modulationType);
                                    signalEqualised             = equalizeSubcarriers   (obj,isShowAnyInfo,obj.isEqualizer,signalDemodulated);
                                    infoDemapped                = demapInfo             (obj,isShowAnyInfo,signalEqualised,obj.mappingType);
                                    signalChannelDeinterleaved  = deinterleaver         (obj,isShowAnyInfo,obj.isChannelInterleaver,infoDemapped,obj.channelInterleaverState);
                                    infoDecoded                 = channelDecoder        (obj,isShowAnyInfo, obj.isChannelEncoder, signalChannelDeinterleaved);
                                    outputData                  = toDecimal             (obj,isShowAnyInfo,infoDecoded);
                                    signalSourceDeinterleaved   = deinterleaver         (obj,isShowAnyInfo,obj.isSourceInterleaver,outputData,obj.sourceInterleaverState);
                                    [~,BER(j,i)] = biterr(uint8(signalSourceDeinterleaved),uint8(reshape(inputData,1,[])));
                                catch
                                    warning("Ошибка при проведении эксперимента")
                                    BER(j,i) = NaN;
                                end
                            end
                            objToSave(i) = obj;
                            BERtoSave = BER(:,i);
                        end
                        save([num2str(experimentsToDo(experiment)) '.mat'],"objToSave","BERtoSave")
                        figure('Name','Битовая и символьная ошибки в зависимости от изменения параметра')
                        if expNum == 1
                            plot(dataArr,BER,'-*b')
                        else
                            plot(dataArr,mean(BER,"omitnan"),'-*b')
                        end
                        xlabel(parameter)
                        ylabel('BER')
                        ylim([-0.1 1.1])
                        grid on
                        saveas(gcf,[num2str(experimentsToDo(experiment)) '.png'])
                        if ~isGraph
                            close
                        end
                    end
                case 4
                    fprintf('%s ========== ОЦЕНКА КАНАЛА ==========\n', datetime);
                    estimateChannel(obj);
                otherwise
                    error('Неверный тип имитации')
            end
            toc
        end


        function obj            = calculateChannelParameters    (obj,isShowAnyInfo)
            % Функция вычисляет параметры передачи
            % в канале для достижения желаемой скорости.
            if isShowAnyInfo(1)
                fprintf('%s ВЫЧИСЛЯЕМ ПАРАМЕТРЫ ПЕРЕДАЧИ ДЛЯ ЖЕЛАЕМОЙ СКОРОСТИ ПЕРЕДАЧИ\n', datetime);
            end
            if mod(obj.Fcentral,obj.subcarrierDistance)>0
                obj.Fcentral = ceil(obj.Fcentral/obj.subcarrierDistance)*obj.subcarrierDistance;
                warning(['Средняя частота должна быть кратной расстоянию между поднесущими для сохранения ортогональности. Частота была изменена на ' num2str(obj.Fcentral) ' Гц'])
            end
            % Вычисляем длительность OFDM символа (+ кодовая скорость?)
            obj.OFDMsymbolTimeLen = 1./obj.subcarrierDistance;
            OFDMsymbolTimeVector = 0:1/obj.sampleRateTx:obj.OFDMsymbolTimeLen-1/obj.sampleRateTx;
            obj.OFDMsymbolTimeVectorLen = length(OFDMsymbolTimeVector);
            if obj.isSourceInterleaver
                obj.sourceInterleaverState = 5;
            end
            if obj.isChannelInterleaver
                obj.channelInterleaverState = 3;
            end
            % Вычисляем символьную скорость
            symbolRate = 1./obj.OFDMsymbolTimeLen; % по сути, равно расзнесению поднесущих по частоте, что логично, если подумать со стороны приемника
            % Вычисляем число бит на OFDM символ
            bitsPerOFDMsymbol = ceil(obj.bitRate/symbolRate);
            % Вычисляем число бит на маппированный символ
            infoSymbolLen = log2(obj.infoModulationOrder);
            % Вычисляем число маппированных символов на OFDM символ
            symbolsMappedPerOFDMsymbol = ceil(bitsPerOFDMsymbol/infoSymbolLen);
            obj.infoSubcarrierNum = symbolsMappedPerOFDMsymbol; % число таких символов это количество информационных поднесущих
            % Вычисляем число всех поднесущих и их их индексы в полосе
            calculateSubcarriersNum(obj,isShowAnyInfo);
            % Вычисляем ширину полосы c учетом нулевых поднесущих (т.н. guard band)
            spectrumWidth = (obj.infoSubcarrierNum + obj.pilotSubcarrierNum + obj.nullSubcarrierNum - 1) * obj.subcarrierDistance;
            % Вычисляем частоты поднесущих
            Fmin = obj.Fcentral - 0.5*spectrumWidth;
            Fmax = obj.Fcentral + 0.5*spectrumWidth;
            Fmin = ceil(Fmin/obj.subcarrierDistance)*obj.subcarrierDistance;
            Fmax = ceil(Fmax/obj.subcarrierDistance)*obj.subcarrierDistance;
            if Fmin <= 0
                error('Частота не может быть отрицательной. Выберите другое значение разнесения по частоте')
            end
            obj.frequencies = Fmin:obj.subcarrierDistance:Fmax;
            if isShowAnyInfo(3)
                fprintf('\t Расстояние между поднесущими %d Гц \n', obj.subcarrierDistance);
                fprintf('\t Длительность OFDM символа %d с \n', obj.OFDMsymbolTimeLen);
                fprintf('\t Число отсчетов на символ %d шт. \n', obj.OFDMsymbolTimeVectorLen);
                fprintf('\t Тип модуляции %s-%d с %d б/симв \n',  upper(obj.mappingType), obj.infoModulationOrder, log2(obj.infoModulationOrder));
                fprintf('\t Минимальная частота %d Гц \n',  obj.frequencies(1));
                fprintf('\t Максимальная частота %d Гц \n', obj.frequencies(end));
                fprintf('\t Полоса %d Гц \n', obj.frequencies(end)-obj.frequencies(1));
                fprintf('\t Всего %d поднесущих, в т.ч. %d пилотных, %d информационных и %d нулевых) \n', length(obj.frequencies), obj.pilotSubcarrierNum, obj.infoSubcarrierNum, obj.nullSubcarrierNum);
                fprintf('\t Частоты информационных поднесущих: %s \n',  num2str(obj.frequencies(obj.infoSubcarrierInd)));
                fprintf('\t Частоты пилотных поднесущих: %s \n',  num2str(obj.frequencies(obj.pilotSubcarrierInd)));
                fprintf('\t Частоты нулевых поднесущих: %s \n',  num2str(obj.frequencies(obj.nullSubcarrierInd)));
            end
        end


        function obj            = calculateSubcarriersNum       (obj,isShowAnyInfo)
            % Функция вычисляет число пилотных и нулевых
            % поднесущих, их индексы в широкополосном
            % сигнале, а также размер взятия БПФ.
            if isShowAnyInfo(1)
                fprintf('%s ВЫЧИСЛЯЕМ ЧИСЛО ПОДНЕСУЩИХ \n', datetime);
            end
            if obj.isEqualizer
                obj.pilotSubcarrierNum = ceil(obj.infoSubcarrierNum/(obj.pilotSubcarrierStep-1));
                if obj.isNullExist
                    FFTlen = 2^( ceil(log2(obj.pilotSubcarrierNum + obj.infoSubcarrierNum)) );
                    obj.nullSubcarrierNum = FFTlen - obj.pilotSubcarrierNum - obj.infoSubcarrierNum;
                    obj.nullSubcarrierInd = [1 : ceil(obj.nullSubcarrierNum/2), FFTlen-floor(obj.nullSubcarrierNum/2)+1 : FFTlen];
                else
                    FFTlen = obj.pilotSubcarrierNum + obj.infoSubcarrierNum;
                    obj.nullSubcarrierNum = 0;
                    obj.nullSubcarrierInd = [];
                end
                obj.pilotSubcarrierInd = 1+obj.nullSubcarrierNum/2:obj.pilotSubcarrierStep:FFTlen-obj.nullSubcarrierNum/2;
                if length(obj.pilotSubcarrierInd) ~= obj.pilotSubcarrierNum
                    error("Ошибка в calculateSubcarriersNum! Число пилотных поднесущих не совпадает")
                end
            else
                obj.pilotSubcarrierNum = 0;
                if obj.isNullExist
                    FFTlen = 2^( ceil(log2(obj.pilotSubcarrierNum + obj.infoSubcarrierNum)) );
                    obj.nullSubcarrierNum = FFTlen - obj.pilotSubcarrierNum - obj.infoSubcarrierNum;
                    obj.nullSubcarrierInd = [1 : ceil(obj.nullSubcarrierNum/2), FFTlen-floor(obj.nullSubcarrierNum/2)+1 : FFTlen];
                else
                    FFTlen = obj.pilotSubcarrierNum + obj.infoSubcarrierNum;
                    obj.nullSubcarrierNum = 0;
                    obj.nullSubcarrierInd = [];
                end
                obj.pilotSubcarrierInd = [];
            end
            obj.infoSubcarrierInd = 1:FFTlen;
            obj.infoSubcarrierInd([obj.pilotSubcarrierInd obj.nullSubcarrierInd]) = [];
            if isShowAnyInfo(3)
                fprintf('\t Индексы информационных поднесущих: %s \n',  num2str(obj.infoSubcarrierInd));
                fprintf('\t Индексы пилотных поднесущих: %s \n',  num2str(obj.pilotSubcarrierInd));
                fprintf('\t Индексы нулевых поднесущих: %s \n',  num2str(obj.nullSubcarrierInd));
            end
        end


        function signalOut      = generateInfo                  (obj,isShowAnyInfo,infoType)
            % Функция считывает входные данные в виде файла Data.xxx,
            % в котором содержится текст или изображение, сохраняет
            % их и передает дальше в бинарном виде.
            % входные параметры:
            %    infoType (1,1) {int}
            %        1 - текст (txt-файл)
            %        2 - изображение (png-файл)
            % выходные параметры:
            %    signalOut (1,N) {string} или {int}
            if isShowAnyInfo(1)
                fprintf('%s ЗАДАЕМ ИНФОРМАЦИОННЫЕ ДАННЫЕ \n', datetime);
            end
            if strcmpi(infoType,'txt')
                % Считываем файл
                signalOut = ReadSource("DataType","txt");
            elseif strcmpi(infoType,'png')
                % Считываем файл
                % obj.inputData = ReadSource("DataType","png");
                % Считываем изображение
                signalOut = imread("Data.png");
                % inputData = im2gray(inputData);
                % Сжимаем картинку для удобства передачи
                imageSize = size(signalOut);
                if imageSize(1) >= 1000 || imageSize(2) >= 1000
                    signalOut = imresize(signalOut,0.1);
                end
            else
                warning("Неверный тип информационных данных")
            end
            obj.dataSize = size(signalOut);
            signalOut = reshape(signalOut,1,[]);
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = toBinary                      (obj,isShowAnyInfo,signalIn)
            % Входные данные считываются в виде строки или числового массива
            % и преобразовываются в бинарный вид.
            % входные параметры:
            %    signalIn (M,N) {string} или {int}
            % выходные параметры:
            %    signalOut (1,8MN) {bin} (фактически {int})
            signalIn = checkColumn(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ПЕРЕВОДИМ ИНФОРМАЦИОННЫЕ ДАННЫЕ В БИНАРНЫЙ ВИД \n', datetime);
            end
            try
                dec = uint8(signalIn);
                binReshaped = dec2bin(dec,8).'-'0';
                signalOut = reshape(binReshaped,1,[]);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в info2bin")
            end
        end


        function signalOut      = interleaver                   (obj,isShowAnyInfo,isInterleaver,signalIn,interleaverState)
            % Функция осуществляет перемеживание. Входные данные
            % перемешиваются случайным образом согласно заданной
            % последовательности.
            % входные параметры:
            %    isInterleaver (logical)
            %    signalIn (1,N) {bin} (фактически {int})
            % выходные параметры:
            %    signalOut (1,N) {bin} (фактически {int})
            signalIn = checkRow(obj,signalIn);
            if isInterleaver
                if isShowAnyInfo(1)
                    fprintf('%s ПЕРЕМЕЖИВАЕМ ДАННЫЕ \n', datetime);
                end
                try
                    % interleaverDepth = 7;
                    % signalOut = [];
                    % for i = 1:length(signalIn)/interleaverDepth
                    %     signalOut = [signalOut randintrlv(double(signalIn(interleaverDepth*(i-1)+1:interleaverDepth*i)),interleaverState)];
                    % end

                    signalOut = randintrlv(double(signalIn),interleaverState);
                catch
                    error("Неизвестная ошибка в interleaver")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = channelEncoder                (obj,isShowAnyInfo,isEncode,signalIn,trellis)
            % Функция применяет сверточное кодирование ко входной
            % бинарной последовательности.
            % входные параметры:
            %    isEncode (logical)
            %    signal (1,N) {bin} (фактически {int})
            % выходные параметры:
            %    infoEncoded (1,N/codeRate) {bin} (фактически {int})
            signalIn = checkBinary(obj,signalIn);
            signalIn = checkRow(obj,signalIn);
            if isEncode
                if isShowAnyInfo(1)
                    fprintf('%s КОДИРУЕМ ДАННЫЕ \n', datetime);
                end
                try
                    if strcmpi(obj.encoderType,'conv')
                        % obj.trellis = poly2trellis([4 3],[4 5 17;7 4 2]);
                        obj.trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
                        signalOut = convenc(signalIn,obj.trellis);
                    elseif strcmpi(obj.encoderType,'bch')
                        n = 7;
                        k = 4;
                        % n = 127;
                        % k = 8;
                        t = bchnumerr(n,k);
                        obj.trellis = [n k t];
                        signalGF = gf(reshape(signalIn,k,[]).');
                        signalEncoded = bchenc(signalGF,n,k);
                        signalOut = reshape(signalEncoded.x.',1,[]);
                    end
                catch
                    error("Неизвестная ошибка в encodeInfo")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = mapInfo                       (obj,isShowAnyInfo,signalIn,mappingType,infoModulationOrder)
            % Функция маппирует поступающие биты согласно
            % выбранному созвездию.
            % входные параметры:
            %    signal (1,N) {bin} (фактически {int})
            % выходные параметры:
            %    signalMapped (bitsPerSymbol*ceil(N/bitsPerSymbol),1) {complex}
            signalIn = checkBinary(obj,signalIn);
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s МАППИРУЕМ (МАНИПУЛИРУЕМ) ДАННЫЕ \n', datetime);
            end
            try
                symbolNum = length(signalIn)/log2(infoModulationOrder);
                arrayNum = ceil(symbolNum)*log2(infoModulationOrder);
                signalToMap = zeros(arrayNum,1);
                signalToMap(1:length(signalIn)) = signalIn;
                if strcmpi(mappingType,'qam')
                    signalOut = qammod(signalToMap,infoModulationOrder,'InputType','bit','PlotConstellation',false);
                elseif strcmpi(mappingType,'psk')
                    signalOut = pskmod(signalToMap,infoModulationOrder,'InputType','bit','PlotConstellation',false);
                elseif strcmpi(mappingType,'tcm')
                    % не реализовано
                end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в mapInfo")
            end
        end


        function signalOut      = formSignal                    (obj,isShowAnyInfo,signalIn)
            % Функция создает многоканальный поток данных
            % согласно сути технологии частотного
            % разделения каналов.
            % входные параметры:
            %    signalIn (N,1) {complex}
            % выходные параметры:
            %    signalOut (symbolNum,subcarrierNum) {complex}
            if obj.infoModulationOrder > 2 && isreal(signalIn)
                error("Ошибка в formSignalNew! Сигнал не в комплексной форме")
            end
            signalIn = checkColumn(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ФОРМИРУЕМ ШИРОКОПОЛОСНЫЙ СИГНАЛ \n', datetime);
            end
            try
                symbolNum = length(signalIn)/obj.infoSubcarrierNum;
                arrayNum = ceil(symbolNum)*obj.infoSubcarrierNum;
                dataToDivide = zeros(arrayNum,1);
                dataToDivide(1:length(signalIn)) = signalIn;
                dataDivided = reshape(dataToDivide,obj.infoSubcarrierNum,[]).';
                [obj.OFDMsymbolsNum, ~] = size(dataDivided);
                signalOut = zeros(obj.OFDMsymbolsNum,obj.infoSubcarrierNum+obj.pilotSubcarrierNum+obj.nullSubcarrierNum);
                if obj.isNullExist
                    null = generateNull(obj);
                    signalOut(:,obj.nullSubcarrierInd) = null;
                end
                if obj.isEqualizer
                    pilotMapped = generatePilot(obj,isShowAnyInfo);
                    signalOut(:,obj.pilotSubcarrierInd) = pilotMapped;
                end
                signalOut(:,obj.infoSubcarrierInd) = dataDivided;
                try
                    signalOut = signalOut./compensateTx(obj);
                catch
                    warning('Влияние передатчика не было устранено по неизвестной причине')
                end
                if isShowAnyInfo(3)
                    figure("Name","Созвездия передающей стороны до переноса на ВЧ")
                    tiledlayout(1,2)
                    ax1 = nexttile;
                    plot(ax1,signalOut(:,obj.infoSubcarrierInd(1)),"r*")
                    title(ax1,"1-я инфо-подн.")
                    grid on
                    if obj.isEqualizer
                        ax2 = nexttile;
                        plot(ax2,signalOut(:,obj.pilotSubcarrierInd(1)),"r*")
                        title(ax2,"1-я пилот-подн.")
                        grid on
                    end
                end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в formSignal")
            end
        end


        function signalOut      = generatePilot                 (obj,isShowAnyInfo)
            % Функция задает и маппирует пилотные данные.
            % выходные параметры:
            %    pilotMapped (OFDMsymbolsNum,pilotSubcarrierNum) {complex}
            if isShowAnyInfo(1)
                fprintf('%s ЗАДАЕМ ПИЛОТНЫЕ ДАННЫЕ \n', datetime);
            end
            try
                pilot = ones(obj.OFDMsymbolsNum*log2(obj.pilotModulationOrder), obj.pilotSubcarrierNum);
                % if strcmpi(obj.mappingType,'qam')
                %     signalOut = qammod(pilot,obj.pilotModulationOrder,'InputType','bit');
                % elseif strcmpi(obj.mappingType,'psk')
                    signalOut = pskmod(pilot,obj.pilotModulationOrder,'InputType','bit');
                % end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в generatePilot")
            end
        end


        function signalOut      = generateNull                  (obj,isShowAnyInfo)
            % Функция задает и маппирует данные на нулевых поднесущих.
            % выходные параметры:
            %    pilotMapped (OFDMsymbolsNum,pilotSubcarrierNum) {complex}
            if isShowAnyInfo(1)
                fprintf('%s ЗАДАЕМ НУЛЕВЫЕ ПОДНЕСУЩИЕ \n', datetime);
            end
            try
                signalOut = zeros(obj.OFDMsymbolsNum,obj.nullSubcarrierNum);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в generateNull")
            end
        end


        function signalOut      = modulateSignal                (obj,isShowAnyInfo,signalIn,modulationType)
            % Функция модулирует сформированный сигнал согласно
            % выбранному принципу модуляции.
            % входные параметры:
            %    signal (M,N) {complex}
            % выходные параметры:
            %    signalModulated (1,OFDMsymbolTimeVectorLen*OFDMsymbolsNum) {double}
            if (obj.infoModulationOrder > 2 || obj.pilotModulationOrder > 2 ) && isreal(signalIn)
                error("Ошибка в modulateSignal! Сигнал не в комплексной форме")
            end
            [a, b] = size(signalIn);
            if a ~= obj.OFDMsymbolsNum || b ~= length(obj.frequencies)
                error("Ошибка в modulateSignal! Сигнал неправильно разнесен по поднесущим")
            end
            if isShowAnyInfo(1)
                fprintf('%s МОДУЛИРУЕМ СИГНАЛ \n', datetime);
            end
            try
                subcarriers = generateSubcarriers(obj,isShowAnyInfo);
                if strcmpi(modulationType,'ofdm')
                    if length(obj.frequencies) > obj.OFDMsymbolTimeVectorLen
                        error('Передача невозможна - размер БПФ меньше числа поднесущих. Увеличьте частоту дискретизации или понизьте скорость передачи')
                    end
                    signalExpanded = repelem(signalIn,obj.OFDMsymbolTimeVectorLen,1);
                    signalOut = real(sum((signalExpanded.*subcarriers).'))./length(obj.frequencies);
                    % signalModulatedBaseband = ifft(signal.',obj.OFDMsymbolTimeVectorLen);
                    % signalModulated = reshape(signalModulatedBaseband,1,[]).*subcarriers(:,find(obj.frequencies == obj.Fcentral));
                elseif strcmpi(modulationType,'fbmc')
                    % не реализовано
                else
                    error('Неподходящий тип модуляции')
                end
                if isShowAnyInfo(3)
                    figure("Name","Созвездия передающей стороны после переноса на ВЧ")
                    tiledlayout(1,2)
                    ax1 = nexttile;
                    % sf = fft(signalOut(1:obj.OFDMsymbolTimeVectorLen));
                    % sfr = reshape(sf,[],obj.infoSubcarrierNum+obj.pilotSubcarrierNum);
                    signalResampled = [];
                    for i = 1:obj.OFDMsymbolsNum
                        signalDemodulatedFFT = fft(signalOut( (i-1)*obj.OFDMsymbolTimeVectorLen+1 : i*obj.OFDMsymbolTimeVectorLen ));
                        signalResampled = [signalResampled signalDemodulatedFFT((obj.frequencies/obj.subcarrierDistance)+1)];
                    end
                    signalReshaped = reshape(signalResampled,length(obj.frequencies),[]);
                    sfr = signalReshaped.';
                    plot(ax1,sfr(:,obj.infoSubcarrierInd(1)),"r*")
                    title(ax1,"1-я инфо-подн.")
                    grid on
                    if obj.isEqualizer
                        ax2 = nexttile;
                        plot(ax2,sfr(:,obj.pilotSubcarrierInd(1)),"r*")
                        title(ax2,"1-я пилот-подн.")
                        grid on
                    end
                end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в modulateSignal")
            end
        end


        function signalOut      = generateSubcarriers           (obj,isShowAnyInfo)
            % Функция создает цифровые образы поднесущих
            % заданного типа.
            % выходные параметры:
            %    subcarriers (M,N) {complex}
            if isShowAnyInfo(1)
                fprintf('%s ГЕНЕРИРУЕМ ПОДНЕСУЩИЕ ЗАДАННОГО ТИПА \n', datetime);
            end
            try
                % OFDMsymbolTimeVector = linspace(0,obj.OFDMsymbolTimeLen*obj.OFDMsymbolsNum-1/obj.sampleRateTx,obj.OFDMsymbolsNum*obj.OFDMsymbolTimeVectorLen);
                OFDMsymbolTimeLen = 1./obj.subcarrierDistance;
                OFDMsymbolTimeVector = 0 : 1/obj.sampleRateTx : OFDMsymbolTimeLen-1/obj.sampleRateTx;
                for i = 1:length(obj.frequencies)
                    signalOut(:,i) = exp(1i*2*pi*obj.frequencies(i)*OFDMsymbolTimeVector.'); % *exp(1i*pi/4)
                end
                signalOut = repmat(signalOut,obj.OFDMsymbolsNum,1);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в generateSubcarriers")
            end
        end


        function signalOut      = addPrefix                     (obj,isShowAnyInfo,signalIn,prefixType)
            % Функция добавляет префикс заданного типа
            % перед каждым символом OFDM.
            % входные параметры:
            %    signal (1,N) {double}
            % выходные параметры:
            %    signalPrefixed (1,N*(1+CPlen)) {double}
            if ~isreal(signalIn)
                error("Ошибка в addPrefix! Сигнал не в вещественной форме")
            end
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ДОБАВЛЯЕМ ПРЕФИКС \n', datetime);
            end
            try
                signalReshaped = reshape(signalIn,obj.OFDMsymbolTimeVectorLen,[]);
                if strcmpi(prefixType,'cp')
                    signalOut = [signalReshaped(end-ceil(obj.OFDMsymbolTimeVectorLen*obj.CPlen)+1:end,:) ; signalReshaped(:,:)];
                elseif strcmpi(prefixType,'nulls')
                    signalOut = [zeros(size(signalReshaped(end-ceil(obj.OFDMsymbolTimeVectorLen*obj.CPlen)+1:end,:))) ; signalReshaped(:,:)];
                else
                    error("Ошибка в addPrefix! Неверный тип префикса")
                end
                signalOut = reshape(signalOut,1,[]);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в addPrefix")
            end
        end


        function signalOut      = addPreamble                   (obj,isShowAnyInfo,signalIn,minnSymbolNum,preambleSignalType)
            % Функция добавляет символ синхронизации установленной длины
            % (преамбулу) для синхронизации по алгоритму Минна.
            % Примечание: не поддерживается использование 1-го символа для
            % синхронизации - особенность кода.
            % входные параметры:
            %    signal (1,N) {double}
            % выходные параметры:
            %    signalPrefixed (1,N+minnSymbolNum*OFDMsymbolTimeVectorLen*(1+CPlen)) {double}
            if ~isreal(signalIn)
                error("Ошибка в addMinnSynchro! Сигнал не в вещественной форме")
            end
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ДОБАВЛЯЕМ СИМВОЛ МИННА ДЛЯ СИНХРОНИЗАЦИИ (ПРЕАМБУЛА) \n', datetime);
            end
            try
                if mod(minnSymbolNum,2)~=0
                    obj.minnSymbolNum = ceil(minnSymbolNum/4)*4;
                    minnSymbolNum = obj.minnSymbolNum;
                    warning(['Ошибка в addPreamble! Заданное число символов, используемых для синхронизации не согласуется с алгоритмом Минна. Число символов было изменено на ' num2str(obj.minnSymbolNum)]);
                end
                AsymbolTimeVectorLen = ceil(obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen))*minnSymbolNum/4;
                if strcmpi(preambleSignalType,'usual')
                    signalFlipped = fliplr(signalIn);
                    A = signalFlipped(1,1*AsymbolTimeVectorLen+1:1*AsymbolTimeVectorLen+AsymbolTimeVectorLen);
                    minusA = -A;
                elseif strcmpi(preambleSignalType,'chirp')
                    AsymbolTime = minnSymbolNum*obj.OFDMsymbolTimeLen*(1+obj.CPlen)/4;
                    AsymbolTimeVector = linspace(0,AsymbolTime-1/obj.sampleRateTx,AsymbolTimeVectorLen);
                    A = chirp(AsymbolTimeVector,obj.frequencies(1),AsymbolTime,obj.frequencies(end));
                    minusA = chirp(AsymbolTimeVector,obj.frequencies(end),AsymbolTime,obj.frequencies(1));
                end
                minnSymbol = [A A minusA minusA];
                signalOut = [minnSymbol signalIn]; % zeros(1,1000)
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в addPreamble")
            end
        end


        function signalTimeLen  = transmitSignal                (obj,isShowAnyInfo,signalIn,sampleRateTx,digitsTx)
            % Функция излучает сигнал в пространство.
            % входные параметры:
            %    signal (1,N) {double}
            %    sampleRateTx (1,1) {int}
            %    digitsTx (1,1) {int}
            % выходные параметры:
            %    signalTimeLen (1,1) {double}
            if ~isreal(signalIn)
                error("Ошибка в transmitSignal! Сигнал не в вещественной форме")
            end
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ИЗЛУЧАЕМ СИГНАЛ \n', datetime);
            end
            try
                signalTimeLen = length(signalIn)/sampleRateTx;
                audiodevreset
                t = timer;
                t.StartDelay = 0.11;
                t.TimerFcn = @(~,~)sound(signalIn, sampleRateTx, digitsTx);
                start(t)
                if isShowAnyInfo(3)
                    fprintf('Будет излучено %d OFDM символов \n', obj.OFDMsymbolsNum);
                    fprintf('Излучение продлится %s \n', signalTimeLen);
                    fprintf('Мощность излучаемого сигнала %s \n', rms(signalIn)^2);
                    fprintf('Мгновенная мощность излучаемого сигнала %s \n', rms(signalIn)^2/signalTimeLen);
                end
            catch
                error("Неизвестная ошибка в transmitSignal")
            end
        end


        function signalOut      = modelChannel                  (obj,isShowAnyInfo,signalIn,sampleRateTx,digitsTx,sampleRateRx,digitsRx)
            % Функция модулирует прохождение сигнала через канал.
            % (Не реализованы замирания и добавление шума).
            % входные параметры:
            %    signalIn (1,N) {double}
            %    sampleRateTx (1,1) {int}
            %    digitsTx (1,1) {int}
            %    sampleRateRx (1,1) {int}
            %    digitsRx (1,1) {int}
            % выходные параметры:
            %    signalIn (1,N*sampleRateTx/sampleRateRx) {double}
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s МОДЕЛИРУЕМ ПРОХОЖДЕНИЕ ЧЕРЕЗ КАНАЛ \n', datetime);
            end
            % Квантователь передатчика (пока не реализовано)
            signalQuantizedTx = signalIn;
            % Дискретизатор передатчика (является частью ПО передатчика,
            % поэтому не требуется менять частоту дискретизации)
            signalResampledTx = signalQuantizedTx;
            % Моделирование прохождения сигнала через канал
            % Дискретизатор приемника (пока не реализовано)
            [P,Q] = rat(sampleRateRx/sampleRateTx);
            signalResampledRx = resample(signalResampledTx,P,Q);
            % Квантователь приёмника
            signalQuantizedRx = signalResampledRx;
            % Вносим избыточность сигнала по времени
            signalOut = [zeros(1,50000) signalQuantizedRx zeros(1,100)];
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = receiveSignal                 (obj,isShowAnyInfo,signalTimeLen,sampleRateRx,digitsRx)
            % Функция записывает сигнал на устройство.
            % входные параметры:
            %    signalTimeLen (1,1) {double}
            %    sampleRateRx (1,1) {int}
            %    digitsRx (1,1) {int}
            % выходные параметры:
            %    signalReceived (1,N) {double}
            if isShowAnyInfo(1)
                fprintf('%s ПРИНИМАЕМ СИГНАЛ \n', datetime)
            end
            try
                disp('Начало записи');
                recObj = audiorecorder(sampleRateRx,digitsRx,1);
                tic
                recordblocking(recObj, signalTimeLen);
                disp('Конец записи');
                signalOut = getaudiodata(recObj).';
                if isShowAnyInfo(3)
                    fprintf('Излучение продлится %s \n', toc);
                    disp(['Мощность принятого сигнала ' num2str(rms(signalOut)^2)])
                end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в receiveSignal")
            end
        end


        function signalOut      = synchronizeTimeByMinn         (obj,isShowAnyInfo,signalIn,minnSymbolNum)
            % Функция синхронизирует сигнал по времени методом Минна.
            % входные параметры:
            %    signal (1,N) {double}
            %    minnSymbolNum (1,1) {int}
            % выходные параметры:
            %    signalSynchronized (1,M) {double}
            signalIn = checkRow(obj,signalIn);
            if minnSymbolNum ~= 0
                try
                    if isShowAnyInfo(1)
                        fprintf('%s СИНХРОНИЗИРУЕМ ПО ВРЕМЕНИ С ПОМОЩЬЮ СИМВОЛА МИННА \n', datetime);
                    end
                    signalReshaped = signalIn';
                    windowLen = ceil(obj.sampleRateRx/obj.sampleRateTx*obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen))*minnSymbolNum/4;
                    if length(signalReshaped) < windowLen*8
                        ACFlimit = length(signalReshaped) - windowLen*4;
                    else
                        ACFlimit = windowLen*8;
                    end
                    for i = 1:ACFlimit
                        % for i = 1:500000
                        CFelement1 = 0;
                        CFelement2 = 0;
                        for j = 0:1
                            symbolPart1 = signalReshaped( 2*j*windowLen+i : 2*j*windowLen+windowLen+i-1 );
                            symbolPart2 = signalReshaped( 2*j*windowLen+i+windowLen : 2*j*windowLen+2*windowLen+i-1 );
                            CFelement1 = CFelement1 + sum((conj(symbolPart1)).*(symbolPart2));
                            CFelement2 = CFelement2 + sum(abs(symbolPart2).^2);
                        end
                        % CF(i) = (abs(CFelement1)).^2/CFelement2.^2;
                        CF(i) = (abs(CFelement1)).^2;
                    end
                    CF = CF./max(CF);
                    % CF(CF<=0.5) = 0;
                    maxCF = max(CF);
                    OFDMstartPosition = find(CF == maxCF);
                    signalPreSynchronized = signalReshaped(OFDMstartPosition+4*windowLen:end)';
                    if isShowAnyInfo(3)
                        figure('Name','ACF based on Minns method')
                        plot(CF);
                        xlabel('Отсчеты')
                        ylabel('Нормализованная амплитуда')
                        hold on
                    end
                catch
                    error("Неизвестная ошибка в synchronizeTimeByMinn")
                end
            else
                signalPreSynchronized = signalIn;
            end
            try
                signalOut = signalPreSynchronized(1:ceil(obj.sampleRateRx/obj.sampleRateTx*obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen))*obj.OFDMsymbolsNum);
            catch
                error('Полученный сигнал слишком короткий!')
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = deletePrefix                  (obj,isShowAnyInfo,signalIn)
            % Функция удаляет префикс перед каждым символом OFDM.
            % входные параметры:
            %    signal (1,N) {double}
            % выходные параметры:
            %    signalPostfixed (1,N/(1+CPlen)) {double}
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s УДАЛЯЕМ ПРЕФИКС \n', datetime);
            end
            try
                signalReshaped = reshape(signalIn,ceil(obj.sampleRateRx/obj.sampleRateTx*obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen)),[]);
                signalOut = signalReshaped(ceil(obj.sampleRateRx/obj.sampleRateTx*obj.OFDMsymbolTimeVectorLen*obj.CPlen)+1:end,:);
                signalOut = reshape(signalOut,1,[]);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в deletePrefix")
            end
        end


        function signalOut      = filterSignal                  (obj,isShowAnyInfo,isFilter,signalIn)
            % Функция фильтрует поступающий сигнал полосовым
            % фильтром с полосой пропускания равной полосе
            % сигнала. Фильтр с КИХ и ЛФЧХ. Уровень
            % подавления вне полосы 60+ дБ
            % входные параметры:
            %    isFilter {logical}
            %    signal (1,N) {double}
            % выходные параметры:
            %    signalFiltered (1,N) {double}
            signalIn = checkRow(obj,signalIn);
            if isFilter
                if isShowAnyInfo(1)
                    fprintf('%s ФИЛЬТРУЕМ СИГНАЛ \n', datetime);
                end
                try
                    Dstop1 = 1e-05;           % First Stopband Attenuation
                    Dpass  = 0.057501127785;  % Passband Ripple
                    Dstop2 = 1e-05;           % Second Stopband Attenuation
                    dens   = 20;              % Density Factor
                    [N, Fo, Ao, W] = firpmord([obj.frequencies(1)-1000 obj.frequencies(1) obj.frequencies(end) obj.frequencies(end)+1000]/(obj.sampleRateRx/2), [0 1 0], [Dstop1 Dpass Dstop2]);
                    filterImpulseResponse  = firpm(N, Fo, Ao, W, {dens});
                    symbolNumToGet = floor(length(signalIn)/(obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen)));
                    signalOut = [];
                    for i = 1:symbolNumToGet
                        signalToFilter = signalIn( (i-1)*obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen)+1 : i*obj.OFDMsymbolTimeVectorLen*(1+obj.CPlen) );
                        signalFilteredWindow = conv(double(signalToFilter),double(filterImpulseResponse),'same');
                        signalOut = [signalOut signalFilteredWindow];
                    end
                    if isShowAnyInfo(3)
                        f = linspace(0,obj.sampleRateRx,length(filterImpulseResponse));
                        figure('Name','АЧХ и ФЧХ цифрового фильтра')
                        subplot(2,1,1)
                        plot(f,abs(fft(filterImpulseResponse)))
                        xlabel('Frequency, Hz')
                        ylabel('Magnitude, dB')
                        xlim([0 obj.sampleRateRx/2])
                        grid on
                        subplot(2,1,2)
                        plot(f,angle(fft(filterImpulseResponse)))
                        xlabel('Frequency, Hz')
                        ylabel('Phase, radians')
                        xlim([0 obj.sampleRateRx/2])
                        grid on
                    end
                catch
                    error("Неизвестная ошибка в filterSignal")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = demodulateSignal              (obj,isShowAnyInfo,signalIn,modulationType)
            % Функция демодулирует принятый синхронизированный сигнал
            % согласно выбранному принципу модуляции.
            % входные параметры:
            %    signal (1,N) {double}
            % выходные параметры:
            %    signalDemodulated (OFDMsymbolsNum,subcarrierNum) {complex}
            signalIn = checkRow(obj,signalIn);
            if isShowAnyInfo(1)
                fprintf('%s ДЕМОДУЛИРУЕМ СИГНАЛ \n', datetime);
            end
            try
                symbolNumToGet = floor(length(signalIn)/(obj.sampleRateRx/obj.sampleRateTx*obj.OFDMsymbolTimeVectorLen));
                if strcmpi(modulationType,'ofdm') || strcmpi(modulationType,'ofdmRight')
                    signalResampled = [];
                    for i = 1:symbolNumToGet
                        signalDemodulatedFFT = fft(signalIn( obj.sampleRateRx/obj.sampleRateTx*(i-1)*obj.OFDMsymbolTimeVectorLen+1 : obj.sampleRateRx/obj.sampleRateTx*i*obj.OFDMsymbolTimeVectorLen ));
                        signalResampled = [signalResampled signalDemodulatedFFT((obj.frequencies/obj.subcarrierDistance)+1)];
                    end
                    signalReshaped = reshape(signalResampled,length(obj.frequencies),[]);
                    signalOut = signalReshaped.';
                elseif strcmpi(modulationType,'fbmc')
                    % не реализовано
                else
                    error('Неподходящий тип модуляции')
                end
            catch
                error("Неизвестная ошибка в demodulateSignal")
            end
            if isShowAnyInfo(3)
                try
                    figure("Name","Созвездия приемной стороны перед эквализацией")
                    tiledlayout(1,2)
                    ax1 = nexttile;
                    plot(ax1,signalOut(:,obj.infoSubcarrierInd(1)),"r*")
                    title(ax1,"1-я инфо-подн.")
                    grid on
                    if obj.isEqualizer
                        ax2 = nexttile;
                        plot(ax2,signalOut(:,obj.pilotSubcarrierInd(1)),"r*")
                        title(ax2,"1-я пилот-подн.")
                        grid on
                    end
                catch
                    warning("Не удается отобразить созвездия приемной стороны без эквалайзинга")
                end
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = equalizeSubcarriers           (obj,isShowAnyInfo,isEqualise,signalIn)
            % Функция эквализирует входной поток.
            % входные параметры:
            %    isEqualise {logical}
            %    signal (M,N) {complex}
            % выходные параметры:
            %    signalEqualised (M,N) {complex}

            [a, b] = size(signalIn);
            if b ~= length(obj.frequencies)
                error("Ошибка в equalizeSubcarriers! Сигнал неправильно разнесен по поднесущим")
            end

            if isEqualise
                if isShowAnyInfo(1)
                    fprintf('%s ЭКВАЛИЗИРУЕМ СИГНАЛ \n', datetime);
                end
                try
                    pilotReceived = signalIn(:,obj.pilotSubcarrierInd);
                    pilotReceivedSize = size(pilotReceived);
                    if pilotReceivedSize(2) < 2
                        warning("Ошибка в equalizeSubcarriers! Сигнал не может быть эквализирован - всего 1 пилотная поднесущая")
                        signalOut = signalIn;
                    else
                        pilotMapped = generatePilot(obj,isShowAnyInfo);
                        transferFunc = pilotReceived./pilotMapped;
                        for i = 1:length(signalIn(:,1))
                            transferCoefs(i,:) = interp1(obj.pilotSubcarrierInd,transferFunc(i,:),1:1:length(obj.frequencies),'linear','extrap');
                        end
                        signalOut = signalIn./transferCoefs;
                    end
                    if isShowAnyInfo(3)
                        try
                            figure("Name","Созвездия приемной стороны после эквалайзинга")
                            tiledlayout(1,2)
                            ax1 = nexttile;
                            plot(ax1,signalOut(:,obj.infoSubcarrierInd(1)),"r*")
                            title(ax1,"1-я инфо-подн.")
                            grid on
                            ax2 = nexttile;
                            plot(ax2,signalOut(:,obj.pilotSubcarrierInd(1)),"r*")
                            title(ax2,"1-я пилот-подн.")
                            grid on
                        catch
                            warning("Не удается отобразить созвездия приемной стороны после эквалайзинга")
                        end
                    end
                catch
                    error("Неизвестная ошибка в equalizeSubcarriers")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = demapInfo                     (obj,isShowAnyInfo,signalIn,mappingType)
            % Функция демаппирует поступающие символы согласно
            % выбранному созвездию.
            % входные параметры:
            %    signal (M,N) {complex}
            % выходные параметры:
            %    infoDemapped (OFDMsymbolsNum*infoSymbolLen*infoSubcarrierNum,1) {bin} (фактически {int})

            [a, b] = size(signalIn);
            if b ~= length(obj.frequencies)
                error("Ошибка в demapSignal! Входные параметры сигнала не соответствуют требуемым")
            end
            if isShowAnyInfo(1)
                fprintf('%s ДЕМАППИРУЕМ ДАННЫЕ \n', datetime);
            end
            % try
                signalReshaped = signalIn(:,obj.infoSubcarrierInd).';
                if strcmpi(mappingType,'qam')
                    signalOut = qamdemod(signalReshaped,obj.infoModulationOrder,'OutputType','bit'); % 1 3 0 2 если без поворота фазы на 90 при генерации поднесущей
                elseif strcmpi(mappingType,'psk')
                    signalOut = pskdemod(signalReshaped,obj.infoModulationOrder,'OutputType','bit');
                    % signalOut = pskdemod(signalReshaped,obj.infoModulationOrder,-3*pi/4,'OutputType','bit');
                elseif strcmpi(mappingType,'tcm')
                    % не реализовано
                end

                signalOut = reshape(signalOut,1,[]);
                if obj.isChannelEncoder
                    if strcmpi(obj.encoderType,'conv')
                        coderate = (log2(obj.trellis.numInputSymbols)/log2(obj.trellis.numOutputSymbols));
                    elseif strcmpi(obj.encoderType,'bch')
                        coderate = obj.trellis(2)/obj.trellis(1);
                    end
                    signalOut = signalOut(1:prod(obj.dataSize)*8/coderate);
                else
                    signalOut = signalOut(1:prod(obj.dataSize)*8);
                end
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            % catch
            %     error("Неизвестная ошибка в demapInfo")
            % end
        end


        function signalOut      = deinterleaver                 (obj,isShowAnyInfo,isInterleaver,signalIn,interleaverState)
            % Функция осуществляет деперемеживание. Входные данные
            % восстанавливают исходную последовательность согласно
            % заданной последовательности.
            % входные параметры:
            %    isInterleaver (logical)
            %    signalIn (1,N) {bin} (фактически {int})
            % выходные параметры:
            %    signalOut (1,N) {bin} (фактически {int})
            signalIn = checkRow(obj,signalIn);
            if isInterleaver
                if isShowAnyInfo(1)
                    fprintf('%s ДЕПЕРЕМЕЖИВАЕМ ДАННЫЕ \n', datetime);
                end
                try
                    % interleaverDepth = 7;
                    % signalOut = [];
                    % for i = 1:length(signalIn)/interleaverDepth
                    %     signalOut = [signalOut randdeintrlv(double(signalIn(interleaverDepth*(i-1)+1:interleaverDepth*i)),interleaverState)];
                    % end

                    signalOut = randdeintrlv(double(signalIn),interleaverState);
                catch
                    error("Неизвестная ошибка в interleaver")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = channelDecoder                (obj,isShowAnyInfo,isDecode,signalIn)
            % Функция применяет сверточное кодирование ко входной
            % бинарной последовательности.
            % входные параметры:
            %    isEncode {logical}
            %    signal (1,N) {bin} (фактически {int})
            % выходные параметры:
            %    signalDecoded (1,N*codeRate) {bin} (фактически {int})
            signalIn = checkBinary(obj,signalIn);
            if isDecode
                if isShowAnyInfo(1)
                    fprintf('%s ДЕКОДИРУЕМ ДАННЫЕ \n', datetime);
                end
                try
                    if strcmpi(obj.encoderType,'conv')
                        depth = 5;
                        codeRate = log2(obj.trellis.numInputSymbols)/log2(obj.trellis.numOutputSymbols);
                        signalOut = vitdec(signalIn(1:prod(obj.dataSize)*8/codeRate),obj.trellis,depth,'trunc','hard');
                    elseif strcmpi(obj.encoderType,'bch')
                        signalOutGF = bchdec(gf(reshape(signalIn,obj.trellis(1),[]).'),obj.trellis(1),obj.trellis(2));
                        signalOut = signalOutGF.x;
                        signalOut = reshape(signalOut.',1,[]);
                    end
                catch
                    error("Неизвестная ошибка в decodeInfo")
                end
            else
                signalOut = signalIn;
            end
            showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
        end


        function signalOut      = toDecimal                 (obj,isShowAnyInfo,signalIn)
            % Функция считывает входные данные в виде бинарного
            % потока и дешифрует их в привычный вид.
            % входные параметры:
            %    signalIn (M,N) {string} или {int}
            %    signalOut (1,L) {bin} (фактически {int})
            % выходные параметры:
            %    outputData (M,N) {string} или {int}
            if isShowAnyInfo(1)
                fprintf('%s ДЕШИФРУЕМ ПРИНЯТЫЙ СИГНАЛ \n', datetime);
            end
            try
                outputDataLine = (bin2dec(reshape(char(signalIn(1:prod(obj.dataSize)*8)+'0'), 8,[]).'));
                signalOut = reshape(outputDataLine,obj.dataSize);
                showOutputDataSize(obj,signalOut,isShowAnyInfo(2));
            catch
                error("Неизвестная ошибка в bin2info")
            end
        end


        function                  showResults                   (obj,isShowAnyInfo,signalTx,signalRx,infoType)
            % Функция считывает данные и отображает
            % их в привычном виде.
            % входные параметры:
            %    signalIn (M,N) {string} или {int}
            %    signalOut (1,L) {bin} (фактически {int})
            %    infoType {string}
            if isShowAnyInfo(1)
                fprintf('%s ОТОБРАЖЕМ ПРИНЯТЫЕ ДАННЫЕ \n', datetime);
            end
            try
                [~,BER] = biterr(uint8(reshape(signalTx,1,[])),uint8(reshape(signalRx,1,[])));
                if strcmpi(infoType,'txt')
                    disp('Transmitted:');
                    disp(signalTx);
                    disp('Received:');
                    disp(char(signalRx));
                    disp(['SER = ' num2str(BER)]);
                elseif strcmpi(infoType,'png')
                    f = figure('Name',['Переданное и принятое изображения. BER = ', num2str(BER)]);
                    f.Position(3:4) = [1400 600];
                    subplot(1,2,1)
                    image(reshape(signalTx,obj.dataSize))
                    subplot(1,2,2)
                    image(reshape(uint8(signalRx),obj.dataSize))
                end
            catch
                error("Неизвестная ошибка в showResults")
            end
        end


        function                  showOutputDataSize            (obj,signalIn,isShowOutputDataSize)
            % Функция считывает данные и отображает
            % их рызмер.
            % входные параметры:
            %    signalIn (K,L,M,N) {int}
            if isShowOutputDataSize
                sizer = size(signalIn);
                counter = length(sizer);
                if counter <= 4
                    fprintf('\t Размер выходных данных = %d %d %d %d \n', size(signalIn));
                    fprintf('\n');
                end
            end
        end


        function signalOut      = checkRow                      (obj,signalIn)
            % Функция проверяет являются ли входные данные вектором-строкой
            % и возвращает вектор-строку этих данных, если они являются
            % вектор-столбцом.
            % входные параметры:
            %    signalIn (M,N) {int}
            if ~isrow(signalIn) && iscolumn(signalIn)
                signalOut = signalIn.';
            elseif ~isrow(signalIn) && ~iscolumn(signalIn)
                warning("Ошибка! Многоканальность не поддерживается. Данные были преобразованы в вектор-строку")
                signalOut = reshape(signalIn,1,[]);
            else
                signalOut = signalIn;
            end
        end


        function signalOut      = checkColumn                   (obj,signalIn)
            % Функция проверяет являются ли входные данные вектор-столбцом
            % и возвращает вектор-столбец этих данных, если они являются
            % вектор-строкой.
            % входные параметры:
            %    signalIn (M,N) {int}
            if ~iscolumn(signalIn) && isrow(signalIn)
                signalOut = signalIn.';
            elseif ~isrow(signalIn) && ~iscolumn(signalIn)
                warning("Ошибка! Многоканальность не поддерживается. Данные были преобразованы в вектор-столбец")
                signalOut = reshape(signalIn,1,[]).';
            else
                signalOut = signalIn;
            end
        end


        function signalOut      = checkBinary                   (obj,signalIn)
            % Функция проверяет являются ли входные данные бинарной
            % последовательностью.
            % входные параметры:
            %    signalIn (M,N) {int}
            if ~(max(signalIn) <= 1)
                error("Ошибка! Сигнал не в двоичной форме")
            else
                signalOut = signalIn;
            end
        end


        function obj = calculatePAPR(obj,signal,isAbs,isMax)
            signalReshaped = reshape(signal,[],1);
            if isAbs
                instantSignalEnergy = abs(signalReshaped).^2;
            else
                instantSignalEnergy = signalReshaped.*conj(signalReshaped);
            end
            meanSignalEnergy = mean(instantSignalEnergy);
            if isMax
                PAPR = (10*log10(max(instantSignalEnergy)/meanSignalEnergy));
            else
                PAPR = (10*log10(instantSignalEnergy/meanSignalEnergy));
            end
            disp(PAPR)
        end


        function obj = estimateChannel(obj)
            isShowAnyInfo = [0 0 0];
            isTransmit = 1;
            obj.sampleRateRx = 48e3;
            obj.sampleRateTx = 48e3;
            obj.subcarrierDistance = 100;
            obj.frequencies = obj.subcarrierDistance:obj.subcarrierDistance:obj.sampleRateTx/2-obj.subcarrierDistance;
            obj.infoSubcarrierInd = [];
            obj.pilotSubcarrierInd = 1:length(obj.frequencies);
            obj.pilotSubcarrierNum = obj.pilotSubcarrierInd(end);
            obj.pilotModulationOrder = 2;
            obj.OFDMsymbolsNum = 1000;
            pilotMapped = generatePilot(obj,isShowAnyInfo);
            obj.OFDMsymbolTimeLen = 1./obj.subcarrierDistance;
            OFDMsymbolTimeVector = 0:1/obj.sampleRateTx:obj.OFDMsymbolTimeLen-1/obj.sampleRateTx;
            obj.OFDMsymbolTimeVectorLen = length(OFDMsymbolTimeVector);
            subcarriers = generateSubcarriers(obj,isShowAnyInfo);
            pilotExpanded = repelem(pilotMapped,obj.OFDMsymbolTimeVectorLen,1);
            pilotModulated = real(sum((pilotExpanded.*subcarriers).'))./length(obj.frequencies);
            obj.CPlen = 0;
            obj.minnSymbolNum = 16;
            % pilotPreambled = addPreamble(obj,isShowAnyInfo,pilotModulated,obj.minnSymbolNum,'chirp');
            pilotPreambled = pilotModulated;
            if isTransmit
                signalTimeLen = transmitSignal(obj,isShowAnyInfo,pilotPreambled,obj.sampleRateTx,obj.digitsTx);
                signalReceived = receiveSignal(obj,isShowAnyInfo,signalTimeLen,obj.sampleRateRx,obj.digitsRx);
            else
                signalReceived = modelChannel(obj,isShowAnyInfo,pilotPreambled,obj.sampleRateTx,obj.digitsTx,obj.sampleRateRx,obj.digitsRx);
            end
            % signalSynchronized = synchronizeTimeByMinn(obj,isShowAnyInfo,signalReceived,obj.minnSymbolNum);
            % signalSynchronized = signalReceived;
            signalSynchronized = pilotModulated;
            pilotReceived = demodulateSignal(obj,isShowAnyInfo,signalReceived(1:obj.OFDMsymbolTimeVectorLen*(obj.OFDMsymbolsNum-0)),'ofdm');

            transferFunc = pilotReceived./pilotMapped;
            transferFunc = transferFunc(250:end,:);
            figure('Name','Зависящая от времени передаточная функция канала')
            mesh(abs(transferFunc))
            xlabel('Частота, кГц')
            ylabel('Отсчеты')
            zlabel('Амплитуда')
            saveas(gcf,'channel.png')

            signalOut = equalizeSubcarriers(obj,isShowAnyInfo,1,pilotReceived);
            figure('Name','Частотная характеристика сигнала после эквалиазции')
            mesh(abs(signalOut))
            xlabel('Частота, кГц')
            ylabel('Отсчеты')
            zlabel('Амплитуда')
            saveas(gcf,'channel.png')


            figure('Name','Зависящий от времени импульсный отклик канала')
            mesh(abs(ifft(transferFunc)))
            xlabel('Частота, кГц')
            ylabel('Отсчеты')
            zlabel('Амплитуда')

            channelResponse = mean(transferFunc);
            figure('Name','Усредненная передаточная функция канала')
            f = linspace(0,obj.sampleRateRx/2,length(channelResponse));
            plot(f,abs(channelResponse))
            xlabel('Частота, Гц')
            grid on

            DopplerSpreading = ifft(mean(transferFunc));
            figure('Name','ИХ канала')
            t = linspace(0,signalTimeLen,length(DopplerSpreading));
            plot(t,abs(DopplerSpreading))
            xlabel('Время, с')
            grid on

            a = fft(transferFunc(:,3));
            figure('Name','Профиль рассеяния канала')
            t = linspace(0,signalTimeLen,length(a));
            plot(t,abs(a))
            xlabel('Время, с')
            grid on
            xlim([0 signalTimeLen/2])
        end


        function transferFunc = compensateTx(obj)
            pilot = ones(obj.OFDMsymbolsNum*log2(obj.pilotModulationOrder), obj.infoSubcarrierNum+obj.pilotSubcarrierNum);
            pilotMapped = pskmod(pilot,obj.pilotModulationOrder,'InputType','bit');
            OFDMsymbolTimeVector = 0 : 1/obj.sampleRateTx : obj.OFDMsymbolTimeLen-1/obj.sampleRateTx;
            for i = 1:length(obj.frequencies)
                signalOut(:,i) = exp(1i*2*pi*obj.frequencies(i)*OFDMsymbolTimeVector.');
            end
            subcarriers = repmat(signalOut,obj.OFDMsymbolsNum,1);
            pilotExpanded = repelem(pilotMapped,obj.OFDMsymbolTimeVectorLen,1);
            pilotModulated = real(sum((pilotExpanded.*subcarriers).'))./length(obj.frequencies);
            signalResampled = [];
            for i = 1:obj.OFDMsymbolsNum
                signalDemodulatedFFT = fft(pilotModulated( (i-1)*obj.OFDMsymbolTimeVectorLen+1 : i*obj.OFDMsymbolTimeVectorLen ));
                signalResampled = [signalResampled signalDemodulatedFFT((obj.frequencies/obj.subcarrierDistance)+1)];
            end
            signalReshaped = reshape(signalResampled,length(obj.frequencies),[]);
            pilotReceived = signalReshaped.';
            transferFunc = pilotReceived./pilotMapped;
        end
        
    end
end