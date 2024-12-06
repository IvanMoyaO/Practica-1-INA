%% Init variables
elevacion_antena = 991 + 16; % Dato
altitud_vuelo = 5500; % Dato
radiales = [15 30 45 60 75 90 105 120 135 150 165 180 195 210 225 240 255 270 285 300 315 330 345 360]; % Dato
% Medidas del mapa
elevacion_obstaculos = [0 0 0; %15
                        0 0 0; %30
                        0 0 0; %45
                        0 0 0; %60
                        0 0 0; %75
                        0 0 0; %90
                        0 0 0; %105
                        0 0 0; %120
                        0 0 0; %135
                        0 0 0; %150
                        0 0 0; %165
                        0 0 0; %180
                        0 0 0; %195
                        1203 1222 1274; %210
                        1091 1185 1056; %225
                        1187 1 1; %240 (a 1 porque sale del mapa)
                        1152 1 1; %255
                        1082 1058 1; %270
                        1451 1070 1121; %285
                        1130 1353 2040; %300
                        1299 1977 2875; %315
                        1060 1614 2162; %330
                        1055 1621 2673; %345
                        1125 1059 1285 %360
                        ];
% Medidas DIRECTAS del mapa, haremos la conversión más adelante
distancia_obstaculos_cm = [0 0 0; %15
                        0 0 0; %30
                        0 0 0; %45
                        0 0 0; %60
                        0 0 0; %75
                        0 0 0; %90
                        0 0 0; %105
                        0 0 0; %120
                        0 0 0; %135
                        0 0 0; %150
                        0 0 0; %165
                        0 0 0; %180
                        0 0 0; %195
                        7 12.5 14.5; %210
                        5 8 16.5; %225
                        6.5 9999 9999; %240 (a 9999 porque sale del mapa)
                        5.3 9999 9999; %255
                        5.3 14 9999; %270
                        11.2 13.5 14.5; %285
                        9 13.3 14.6; %300
                        10 14.5 17.3; %315
                        9 12 22; %330
                        6.8 14.4 16.4; %345
                        6.5 10.5 13 %360
                        ];

%% Funciones

  % Función para obtener el alpha
  % elevacion_antena [=] m, distancia_obst [=] m, elevacion_obst [=] m
  function alpha = calcAlpha(elevacion_antena, distancia_obst, elevacion_obst)
  % alpha [=] mrad
     alpha = (1/9) * ( 1.5 * 1/( distancia_obst/1852 ) * 3.281 * ( elevacion_obst - elevacion_antena ) - distancia_obst/1852 );
  end

  % Función para obtener la distancia a la que llega, como máximo, la
  % cobertura para un nivel de vuelo dado
  % alpha [=] mrad, altitud_vuelo [=] ft, elevacion_antena [=] m
  function distancia = calcDistancia(alpha, altitud_vuelo, elevacion_antena)
  % distancia [=] NM
     p = [2/3  6*alpha -(altitud_vuelo-elevacion_antena*3.281)];
     distancia = max(roots(p));
  end

  % Función para obtener el alpha cuando no hay obstáculos, a partir del
  % horizonte radio teórico.
  % elevacion_antena_m [=] m
  function mar = calcAlphaMar(elevacion_antena_m)
  % mar [=] mrad
     elevacion_antena = elevacion_antena_m*3.281; % conversión a ft

     % Resuelve el sistema que indican los apuntes de Moodle.
     syms D_t alpha_0
     eqn1 = 0 == (2/3) * D_t^2 + 6*alpha_0*D_t + elevacion_antena;
     eqn2 = elevacion_antena == (2/3) * (2*D_t)^2 + 6*alpha_0*2*D_t + elevacion_antena;
     sol = solve([eqn1,eqn2], [D_t alpha_0]);
     alpha = double(sol.alpha_0);
     
     H = (2/3) * 0^2 + 6*min(alpha)*0 + elevacion_antena;
     if ( H > 0 )
         mar = min(alpha);
     else
         mar = max(alpha);
     end
  end


%% Cálculos

% Ahora sí, pasamos la lectura directa del mapa (cm) a metros
distancia_obstaculos = distancia_obstaculos_cm .* (1000*5/1.6);

% bucle para calcular las distancias
% Seguramente sea más eficiente operando con matrices
for i = 1 : height(elevacion_obstaculos) %filas
    for j = 1 : width(elevacion_obstaculos) %columnas
        if(elevacion_obstaculos(i, j) == 0)
            dist(i, j) = calcDistancia(calcAlphaMar(elevacion_antena), altitud_vuelo, elevacion_antena);
        else
            dist(i, j) = calcDistancia(calcAlpha(elevacion_antena, distancia_obstaculos(i,j), elevacion_obstaculos(i,j)), altitud_vuelo, elevacion_antena);
        end
    end
end


% Buscamos la distancia limitante
limitante = min(dist, [], 2);
% Esto solo sirve para dibujarlo en el mapa. Conversión NM --> cm del mapa
limitante_cm = limitante .* ( 1.852*1.6/5);

% Esto sirve meramente para comprobar rápidamente los números.
fmt=['Lmts (NM) = ' repmat('%f, ',1,numel(limitante))];
fprintf(fmt, limitante);

fmt=['Lmts (cm) = ' repmat('%f, ',1,numel(limitante_cm))];
fprintf(fmt, limitante_cm);


%% Gráfica
% Usamos una figura con ejes polares, no la "típica" de Matlab.
figure
pax = polaraxes;
radiales_rad = deg2rad(radiales);
radiales_rad(size(radiales_rad)+1) = radiales_rad(1); % Sirve para cerrar la figura
limitante(size(limitante)+1) = limitante(1); % Ídem. Desconocemos si existen métodos más elegante.
polarplot(radiales_rad,limitante)
pax.ThetaDir = "clockwise"; % Hay que indicárselo explícitamente, sale al contrario si no.
pax.ThetaZeroLocation = 'top';
title('Cobertura VOR')
pax.GridColor = 'red';

